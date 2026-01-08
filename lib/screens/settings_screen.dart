import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  bool _showJapaneseTranslation = false;
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _apiEndpointController = TextEditingController();
  bool _obscureApiKey = true;
  String _apiType = 'gemini';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _modelController.dispose();
    _apiEndpointController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final showJapanese = await _settingsService.getShowJapaneseTranslation();
    final apiKey = await _settingsService.getGeminiApiKey();
    final model = await _settingsService.getGeminiModel();
    final apiType = await _settingsService.getApiType();
    final apiEndpoint = await _settingsService.getApiEndpoint();
    setState(() {
      _showJapaneseTranslation = showJapanese;
      _apiKeyController.text = apiKey ?? '';
      _modelController.text = model ?? 'gemini-2.0-flash-exp';
      _apiType = apiType ?? 'gemini';
      _apiEndpointController.text = apiEndpoint ?? '';
    });
  }

  Future<void> _saveSettings() async {
    await _settingsService.setShowJapaneseTranslation(_showJapaneseTranslation);
    if (_apiKeyController.text.isNotEmpty) {
      await _settingsService.setGeminiApiKey(_apiKeyController.text);
    }
    if (_modelController.text.isNotEmpty) {
      await _settingsService.setGeminiModel(_modelController.text);
    }
    await _settingsService.setApiType(_apiType);
    if (_apiEndpointController.text.isNotEmpty) {
      await _settingsService.setApiEndpoint(_apiEndpointController.text);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AI Configuration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _apiType,
              decoration: const InputDecoration(
                labelText: 'API Type',
                helperText: 'Select the type of AI API to use',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'gemini', child: Text('Google Gemini')),
                DropdownMenuItem(value: 'openai', child: Text('OpenAI Compatible')),
              ],
              onChanged: (value) {
                setState(() {
                  _apiType = value ?? 'gemini';
                });
              },
            ),
            const SizedBox(height: 16),
            if (_apiType == 'openai')
              Column(
                children: [
                  TextField(
                    controller: _apiEndpointController,
                    decoration: const InputDecoration(
                      labelText: 'API Endpoint',
                      helperText: 'e.g., http://localhost:11434/v1/chat/completions (Ollama)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            TextField(
              controller: _apiKeyController,
              obscureText: _obscureApiKey,
              decoration: InputDecoration(
                labelText: _apiType == 'gemini' ? 'Gemini API Key' : 'API Key',
                helperText: _apiType == 'gemini' 
                    ? 'Get your key from https://makersuite.google.com/app/apikey'
                    : 'API key for authentication (if required)',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscureApiKey ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _obscureApiKey = !_obscureApiKey;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _modelController,
              decoration: InputDecoration(
                labelText: 'Model Name',
                helperText: _apiType == 'gemini'
                    ? 'e.g., gemini-2.0-flash-exp, gemini-1.5-flash'
                    : 'e.g., llama3.2, gpt-4, qwen2.5',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Display Options',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text('Show Japanese translation in results'),
              subtitle: const Text('Display Japanese translation alongside English text in the evaluation screen'),
              value: _showJapaneseTranslation,
              onChanged: (value) {
                setState(() {
                  _showJapaneseTranslation = value ?? false;
                });
              },
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSettings,
                child: const Text('Save Settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
