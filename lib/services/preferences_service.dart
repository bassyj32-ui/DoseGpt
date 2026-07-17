import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _keyHasSeenDisclaimer = 'hasSeenDisclaimer';

  static Future<bool> getHasSeenDisclaimer() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasSeenDisclaimer) ?? false;
  }

  static Future<void> setHasSeenDisclaimer(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasSeenDisclaimer, value);
  }
}
