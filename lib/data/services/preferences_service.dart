import 'package:shared_preferences/shared_preferences.dart';

/// Key-value storage. Failures (private mode, blocked storage) are swallowed:
/// reads return null and writes are skipped.
class PreferencesService {
  Future<String?> getString(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (_) {
      return null;
    }
  }

  Future<void> setString(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (_) {}
  }
}
