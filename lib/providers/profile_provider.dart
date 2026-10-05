import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores personal info, medical history, emergency contact and settings locally.
class ProfileProvider extends ChangeNotifier {
  static const fields = [
    'name', 'age', 'gender', 'height', 'weight', // personal
    'blood', 'conditions', 'allergies', 'medications', // medical
    'ecName', 'ecPhone', 'ecRelation', // emergency
  ];

  late SharedPreferences _prefs;
  final Map<String, String> data = {};
  bool darkMode = false;
  bool notifications = true;
  int stepGoal = 8000;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    for (final f in fields) {
      data[f] = _prefs.getString(f) ?? '';
    }
    darkMode = _prefs.getBool('darkMode') ?? false;
    notifications = _prefs.getBool('notifications') ?? true;
    stepGoal = _prefs.getInt('stepGoal') ?? 8000;
  }

  String get name => data['name']!.isEmpty ? 'there' : data['name']!;

  Future<void> setField(String key, String value) async {
    data[key] = value.trim();
    await _prefs.setString(key, value.trim());
    notifyListeners();
  }

  Future<void> setDark(bool v) async {
    darkMode = v;
    await _prefs.setBool('darkMode', v);
    notifyListeners();
  }

  Future<void> setNotifications(bool v) async {
    notifications = v;
    await _prefs.setBool('notifications', v);
    notifyListeners();
  }

  Future<void> setStepGoal(int v) async {
    stepGoal = v;
    await _prefs.setInt('stepGoal', v);
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _prefs.clear();
    await load();
    notifyListeners();
  }
}
