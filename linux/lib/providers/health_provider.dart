import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/status.dart';

/// Holds live vitals/activity, and manages the BLE wearable connection.
///
/// Heart rate and battery are read from the standard BLE Heart Rate (0x180D)
/// and Battery (0x180F) services when a real device is connected. Other
/// metrics are simulated until you map your device's custom characteristics.
class HealthProvider extends ChangeNotifier {
  static const maxPoints = 30;
  final _rng = Random();
  Timer? _timer;

  // ---- Vitals ----
  double heartRate = 72;
  double spo2 = 98;
  double systolic = 118;
  double diastolic = 78;
  double temperature = 36.7;

  final List<double> hrHistory = [];
  final List<double> spo2History = [];
  final List<double> sysHistory = [];
  final List<double> diaHistory = [];
  final List<double> tempHistory = [];

  // ---- Activity ----
  int steps = 0;
  int activeSeconds = 0;
  double get distanceKm => steps * 0.00075;
  double get calories => steps * 0.04 + activeSeconds / 60 * 2;
  int get activeMinutes => activeSeconds ~/ 60;

  // ---- Device ----
  bool scanning = false;
  bool connected = false;
  bool demoMode = false;
  String deviceName = '—';
  int battery = 0;
  DateTime? lastSync;
  String? error;
  List<ScanResult> scanResults = [];
  BluetoothDevice? _device;
  bool _realHr = false;
  StreamSubscription? _scanSub, _hrSub, _connSub;

  void start() {
    _tick();
    _timer ??= Timer.periodic(const Duration(seconds: 3), (_) => _tick());
  }

  double _walk(double v, double step, double lo, double hi) =>
      (v + (_rng.nextDouble() - 0.5) * 2 * step).clamp(lo, hi).toDouble();

  void _tick() {
    if (!_realHr) heartRate = _walk(heartRate, 3, 58, 105);
    spo2 = _walk(spo2, 0.6, 94, 100);
    systolic = _walk(systolic, 2, 105, 135);
    diastolic = _walk(diastolic, 1.5, 68, 88);
    temperature = _walk(temperature, 0.05, 36.3, 37.2);
    steps += _rng.nextInt(9);
    activeSeconds += _rng.nextInt(4);

    void add(List<double> l, double v) {
      l.add(double.parse(v.toStringAsFixed(1)));
      if (l.length > maxPoints) l.removeAt(0);
    }

    add(hrHistory, heartRate);
    add(spo2History, spo2);
    add(sysHistory, systolic);
    add(diaHistory, diastolic);
    add(tempHistory, temperature);
    notifyListeners();
  }

  void addSteps(int n) {
    steps += n;
    activeSeconds += n ~/ 2;
    notifyListeners();
  }

  // ---- Derived ----
  List<Status> get statuses => [
        hrStatus(heartRate),
        spo2Status(spo2),
        bpStatus(systolic, diastolic),
        tempStatus(temperature),
      ];

  int healthScore(int stepGoal) {
    double score = 100;
    for (final s in statuses) {
      if (s.level == Level.warn) score -= 8;
      if (s.level == Level.bad) score -= 20;
    }
    final ratio = (steps / max(stepGoal, 1)).clamp(0.0, 1.0);
    score -= (1 - ratio) * 15;
    return score.clamp(0, 100).round();
  }

  // ---- BLE ----
  Future<bool> _ensurePermissions() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;
    final res = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
    return res.values.every((s) => s.isGranted || s.isLimited);
  }

  Future<void> scan() async {
    error = null;
    if (!await _ensurePermissions()) {
      error = 'Bluetooth permissions were denied.';
      notifyListeners();
      return;
    }
    try {
      if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
        error = 'Please turn Bluetooth on.';
        notifyListeners();
        return;
      }
      scanning = true;
      scanResults = [];
      notifyListeners();
      await _scanSub?.cancel();
      _scanSub = FlutterBluePlus.scanResults.listen((r) {
        scanResults = r.where((e) => e.device.platformName.isNotEmpty).toList()
          ..sort((a, b) => b.rssi.compareTo(a.rssi));
        notifyListeners();
      });
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 8));
      await FlutterBluePlus.isScanning.where((s) => s == false).first;
    } catch (e) {
      error = 'Scan failed: $e';
    }
    scanning = false;
    notifyListeners();
  }

  Future<void> connect(BluetoothDevice d) async {
    error = null;
    try {
      await d.connect(timeout: const Duration(seconds: 15));
      _device = d;
      connected = true;
      demoMode = false;
      deviceName = d.platformName.isEmpty ? d.remoteId.str : d.platformName;
      lastSync = DateTime.now();
      notifyListeners();

      _connSub?.cancel();
      _connSub = d.connectionState.listen((s) {
        if (s == BluetoothConnectionState.disconnected && connected && !demoMode) {
          _reset();
          notifyListeners();
        }
      });

      final services = await d.discoverServices();
      for (final s in services) {
        if (s.uuid == Guid('180D')) {
          for (final c in s.characteristics) {
            if (c.uuid == Guid('2A37')) {
              await c.setNotifyValue(true);
              _hrSub = c.lastValueStream.listen(_parseHr);
            }
          }
        }
        if (s.uuid == Guid('180F')) {
          for (final c in s.characteristics) {
            if (c.uuid == Guid('2A19')) {
              final v = await c.read();
              if (v.isNotEmpty) battery = v.first;
            }
          }
        }
      }
      notifyListeners();
    } catch (e) {
      error = 'Connection failed: $e';
      _reset();
      notifyListeners();
    }
  }

  void _parseHr(List<int> v) {
    if (v.length < 2) return;
    final is16 = (v[0] & 0x01) == 1;
    final bpm = is16 && v.length >= 3 ? (v[1] | (v[2] << 8)) : v[1];
    if (bpm > 0) {
      _realHr = true;
      heartRate = bpm.toDouble();
      notifyListeners();
    }
  }

  void connectDemo() {
    demoMode = true;
    connected = true;
    deviceName = 'HealthSync Band (Demo)';
    battery = 40 + _rng.nextInt(55);
    lastSync = DateTime.now();
    error = null;
    notifyListeners();
  }

  Future<void> disconnect() async {
    try {
      await _device?.disconnect();
    } catch (_) {}
    _reset();
    notifyListeners();
  }

  void _reset() {
    _hrSub?.cancel();
    _connSub?.cancel();
    _device = null;
    connected = false;
    demoMode = false;
    _realHr = false;
    deviceName = '—';
    battery = 0;
  }

  Future<void> syncData() async {
    if (!connected) return;
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!demoMode && _device != null) {
      try {
        for (final s in await _device!.discoverServices()) {
          if (s.uuid == Guid('180F')) {
            for (final c in s.characteristics) {
              if (c.uuid == Guid('2A19')) {
                final v = await c.read();
                if (v.isNotEmpty) battery = v.first;
              }
            }
          }
        }
      } catch (_) {}
    }
    lastSync = DateTime.now();
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scanSub?.cancel();
    _hrSub?.cancel();
    _connSub?.cancel();
    super.dispose();
  }
}
