import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/unit.dart';
import 'settings_service.dart';

class AIService {
  String? apiKey;
  String? model;
  String? apiType;
  String? apiEndpoint;
  bool _isInitialized = false;
  final SettingsService _settingsService = SettingsService();

  AIService() {
    _loadEnv();
  }

  Future<void> _loadEnv() async {
    if (_isInitialized) return;

    // First, try to load from settings (user preferences)
    apiKey = await _settingsService.getGeminiApiKey();
    model = await _settingsService.getGeminiModel();
    apiType = await _settingsService.getApiType();
    apiEndpoint = await _settingsService.getApiEndpoint();

    // If not found in settings, try to load from .env file
    if (apiKey == null || apiKey!.isEmpty) {
      try {
        await dotenv.load(fileName: ".env");
        apiKey = dotenv.env['GEMINI_API_KEY'] ?? dotenv.env['API_KEY'];
        model = dotenv.env['GEMINI_MODEL'] ?? dotenv.env['MODEL'];
        apiType = dotenv.env['API_TYPE'];
        apiEndpoint = dotenv.env['API_ENDPOINT'];
      } catch (e) {
        apiKey = '';
        model = 'gemini-2.0-flash-exp';
        apiType = 'gemini';
      }
    }

    // Set defaults
    apiType ??= 'gemini';
    
    _isInitialized = true;
  }

  Future<Unit> generateUnit(String keywords, String level, int numExercises) async {
    await _loadEnv();

    if (apiKey == null || apiKey!.isEmpty) {
      throw Exception('API key not found. Please check your settings.');
    }

    final modelName = model ?? 'gemini-2.0-flash-exp';
    final type = apiType ?? 'gemini';

    // Retry configuration - Gemini free tier: 15 RPM (requests per minute)
    const maxRetries = 5;
    const initialDelaySeconds = 5;
    
    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        return await _makeApiRequest(keywords, level, numExercises, modelName, type);
      } catch (e) {
        if (e.toString().contains('rate limit') || e.toString().contains('429')) {
          if (attempt < maxRetries - 1) {
            // Exponential backoff: 5s, 10s, 20s, 40s, 80s
            final delaySeconds = initialDelaySeconds * (1 << attempt);
            print('Rate limit hit. Retrying in $delaySeconds seconds... (Attempt ${attempt + 1}/$maxRetries)');
            await Future.delayed(Duration(seconds: delaySeconds));
            continue;
          } else {
            throw Exception('Rate limit exceeded after $maxRetries attempts. Please wait a few minutes and try again.');
          }
        }
        rethrow;
      }
    }
    
    throw Exception('Failed to generate unit after $maxRetries attempts');
  }

  Future<Unit> _makeApiRequest(String keywords, String level, int numExercises, String modelName, String type) async {

    final prompt = '''
Generate a dictation unit for English learners. The unit should include the following keywords: $keywords.

Requirements:
- Level: $level
- Number of exercises: $numExercises
- Each exercise should be a natural English sentence
- Include hints for each exercise
- Include Japanese translation for each exercise

Output format: JSON with the following structure:
{
  "unit_id": "auto_generated",
  "title": "Generated Unit",
  "level": "$level",
  "description": "AI generated unit for $keywords",
  "exercises": [
    {
      "id": 1,
      "text": "Example sentence",
      "hint": "Hint for the sentence",
      "japanese": "日本語訳",
      "difficulty": "easy/medium/hard"
    }
  ],
  "settings": {
    "voice": "en-US",
    "speed": 1.0,
    "repeat_allowed": 3
  }
}
''';

    http.Response response;

    if (type == 'openai') {
      // OpenAI Compatible API format
      final endpoint = apiEndpoint ?? 'http://localhost:11434/v1/chat/completions';
      final requestBody = jsonEncode({
        'model': modelName,
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
      });

      response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: requestBody,
      );
    } else {
      // Google Gemini API format
      final url = 'https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$apiKey';
      final requestBody = jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ]
      });

      response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String text;

      // Extract text based on API type
      if (type == 'openai') {
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          text = data['choices'][0]['message']['content'];
        } else {
          throw Exception('No content generated by AI service');
        }
      } else {
        if (data['candidates'] != null && data['candidates'].isNotEmpty) {
          text = data['candidates'][0]['content']['parts'][0]['text'];
        } else {
          throw Exception('No content generated by AI service');
        }
      }

      // Extract JSON from the response, removing markdown code blocks if present
      String cleanedText = text.trim();
      if (cleanedText.startsWith('```json')) {
        cleanedText = cleanedText.substring(7);
      } else if (cleanedText.startsWith('```')) {
        cleanedText = cleanedText.substring(3);
      }
      if (cleanedText.endsWith('```')) {
        cleanedText = cleanedText.substring(0, cleanedText.length - 3);
      }
      cleanedText = cleanedText.trim();

      final jsonStart = cleanedText.indexOf('{');
      final jsonEnd = cleanedText.lastIndexOf('}') + 1;
      if (jsonStart == -1 || jsonEnd == -1) {
        throw Exception('Invalid response format from AI service');
      }

      final jsonStr = cleanedText.substring(jsonStart, jsonEnd);
      final unitJson = jsonDecode(jsonStr);
      unitJson['unit_id'] = 'ai_generated_${DateTime.now().millisecondsSinceEpoch}';
      return Unit.fromJson(unitJson);
    } else if (response.statusCode == 400) {
      throw Exception('Invalid request. Please check your input.');
    } else if (response.statusCode == 401) {
      throw Exception('API key is invalid or expired.');
    } else if (response.statusCode == 403) {
      throw Exception('API access forbidden. Check your API key permissions.');
    } else if (response.statusCode == 429) {
      throw Exception('API rate limit exceeded (429). Retrying...');
    } else if (response.statusCode >= 500) {
      throw Exception('AI service is temporarily unavailable. Please try again later.');
    } else {
      throw Exception('Failed to generate unit (HTTP ${response.statusCode}).');
    }
  }
}
