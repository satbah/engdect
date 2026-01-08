import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _showJapaneseKey = 'show_japanese_translation';
  static const String _geminiApiKeyKey = 'gemini_api_key';
  static const String _geminiModelKey = 'gemini_model';
  static const String _apiTypeKey = 'api_type';
  static const String _apiEndpointKey = 'api_endpoint';

  Future<bool> getShowJapaneseTranslation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_showJapaneseKey) ?? false;
  }

  Future<void> setShowJapaneseTranslation(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showJapaneseKey, value);
  }

  Future<String?> getGeminiApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_geminiApiKeyKey);
  }

  Future<void> setGeminiApiKey(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_geminiApiKeyKey, value);
  }

  Future<String?> getGeminiModel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_geminiModelKey);
  }

  Future<void> setGeminiModel(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_geminiModelKey, value);
  }

  Future<String?> getApiType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiTypeKey);
  }

  Future<void> setApiType(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiTypeKey, value);
  }

  Future<String?> getApiEndpoint() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiEndpointKey);
  }

  Future<void> setApiEndpoint(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiEndpointKey, value);
  }
}
