import 'package:flutter/material.dart';
import '../models/unit.dart';
import '../services/ai_service.dart';
import 'practice_screen.dart';

class AiInputScreen extends StatefulWidget {
  const AiInputScreen({super.key});

  @override
  State<AiInputScreen> createState() => _AiInputScreenState();
}

class _AiInputScreenState extends State<AiInputScreen> {
  final _keywordController = TextEditingController();
  String _selectedLevel = 'beginner';
  int _numExercises = 10;
  bool _isGenerating = false;

  final _levels = ['beginner', 'intermediate', 'advanced'];

  Future<void> _generateUnit() async {
    if (_keywordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter keywords')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      final aiService = AIService();
      final unit = await aiService.generateUnit(
        _keywordController.text.trim(),
        _selectedLevel,
        _numExercises,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PracticeScreen(mode: 'ai_generated', generatedUnit: unit),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate AI Unit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create Custom Practice Unit',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _keywordController,
              decoration: const InputDecoration(
                labelText: 'Keywords (e.g., "business meeting, presentation")',
                border: OutlineInputBorder(),
                helperText: 'Enter keywords related to the practice content',
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedLevel,
              decoration: const InputDecoration(
                labelText: 'Difficulty Level',
                border: OutlineInputBorder(),
              ),
              items: _levels.map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Text(level.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLevel = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Number of exercises:'),
                const SizedBox(width: 10),
                DropdownButton<int>(
                  value: _numExercises,
                  items: [5, 10, 15, 20].map((num) {
                    return DropdownMenuItem(
                      value: num,
                      child: Text('$num'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _numExercises = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isGenerating ? null : _generateUnit,
                child: _isGenerating
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 10),
                          Text('Generating...'),
                        ],
                      )
                    : const Text('Generate Unit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String error) {
    String title = 'Generation Failed';
    String message = error;
    String details = '';

    // エラーメッセージを解析してわかりやすいメッセージに変換
    if (error.contains('API key not found')) {
      title = 'API Key Error';
      message = 'API key is not configured properly.';
      details = 'Please check your .env file and ensure GEMINI_API_KEY is set correctly.';
    } else if (error.contains('API key is invalid')) {
      title = 'Invalid API Key';
      message = 'The API key is invalid or expired.';
      details = 'Please check your Gemini API key and update it in the .env file.';
    } else if (error.contains('API access forbidden')) {
      title = 'Access Forbidden';
      message = 'API access is forbidden.';
      details = 'Your API key may not have the required permissions or may be restricted.';
    } else if (error.contains('rate limit exceeded')) {
      title = 'Rate Limit Exceeded';
      message = 'Too many requests.';
      details = 'Please wait a few minutes before trying again.';
    } else if (error.contains('temporarily unavailable')) {
      title = 'Service Unavailable';
      message = 'AI service is temporarily unavailable.';
      details = 'Please try again later. The service may be experiencing issues.';
    } else if (error.contains('Invalid request')) {
      title = 'Invalid Request';
      message = 'The request format is invalid.';
      details = 'Please check your input and try again.';
    } else if (error.contains('HTTP')) {
      // HTTPエラーの詳細を抽出
      final httpMatch = RegExp(r'HTTP (\d+):').firstMatch(error);
      if (httpMatch != null) {
        final statusCode = httpMatch.group(1);
        title = 'HTTP Error $statusCode';
        message = 'Server returned error code $statusCode.';
        details = 'Full error: $error';
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message),
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  const Text(
                    'Details:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    details,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
                const SizedBox(height: 10),
                const Text(
                  'Debug Info:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  error,
                  style: TextStyle(fontSize: 10, color: Colors.grey[500], fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _keywordController.dispose();
    super.dispose();
  }
}