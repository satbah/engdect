import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _showJapaneseKey = 'show_japanese_translation';

  Future<bool> getShowJapaneseTranslation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_showJapaneseKey) ?? false;
  }

  Future<void> setShowJapaneseTranslation(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showJapaneseKey, value);
  }
}