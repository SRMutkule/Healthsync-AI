import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/health_provider.dart';
import '../widgets/common.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({super.key});

  String _ago(DateTime? d) {
    if (d == null) return 'Never';
    final s = DateTime.now().difference(d);
    if (s.inSeconds < 60) return 'Just now';
    if (s.inMinutes < 60) return '${s.inMinutes} min ago';
    return '${s.inHours} h ago';
  }

  @override
  Widget build(BuildContext context) {
    final h = context.watch<HealthProvider>();
    final t = Theme.of(context).textTheme;

    return ListView(padding: const EdgeInsets.all(16), children: [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(h.connected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                  size: 32, color: h.connected ? Colors.blue : Colors.grey),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(h.connected ? 'Connected' : 'Not connected', style: t.titleLarge),
                  Text('Device: ${h.deviceName}'),
                ]),
              ),
            ]),
            const Divider(height: 28),
            Row(children: [
              const Icon(Icons.battery_full),
              const SizedBox(width: 8),
              Text(h.connected ? 'Battery: ${h.battery}%' : 'Battery: —'),
            ]),
            if (h.connected) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(value: h.battery / 100),
            ],
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.sync),
              const SizedBox(width: 8),
              Text('Last sync: ${_ago(h.lastSync)}'),
            ]),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: h.connected ? () => h.syncData() : null,
                  icon: const Icon(Icons.sync),
                  label: const Text('Sync Data'),
                ),
              ),
              if (h.connected) ...[
                const SizedBox(width: 8),
                OutlinedButton(onPressed: h.disconnect, child: const Text('Disconnect')),
              ],
            ]),
          ]),
        ),
      ),
      if (h.error != null)
        Card(
          color: Theme.of(context).colorScheme.errorContainer,
          child: ListTile(leading: const Icon(Icons.error_outline), title: Text(h.error!)),
        ),
      const SectionTitle('BLE Connection'),
      Row(children: [
        Expanded(
          child: FilledButton.tonalIcon(
            onPressed: h.scanning ? null : h.scan,
            icon: h.scanning
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.search),
            label: Text(h.scanning ? 'Scanning…' : 'Scan for devices'),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: h.connected ? null : h.connectDemo,
          icon: const Icon(Icons.science),
          label: const Text('Demo band'),
        ),
      ]),
      const SizedBox(height: 8),
      if (h.scanResults.isEmpty && !h.scanning)
        const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('No devices found yet. Wear your band and tap Scan.')),
        ),
      for (final r in h.scanResults)
        Card(
          child: ListTile(
            leading: const Icon(Icons.watch),
            title: Text(r.device.platformName),
            subtitle: Text('${r.device.remoteId}  •  RSSI ${r.rssi} dBm'),
            trailing: FilledButton(
              onPressed: h.connected ? null : () => h.connect(r.device),
              child: const Text('Connect'),
            ),
          ),
        ),
      Padding(
        padding: const EdgeInsets.all(8),
        child: Text(
          'Real devices must expose the standard Heart Rate (0x180D) and Battery (0x180F) services. Other vitals are simulated.',
          style: t.bodySmall,
          textAlign: TextAlign.center,
        ),
      ),
    ]);
  }
}
