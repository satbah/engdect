import 'package:flutter/material.dart';
import '../models/unit.dart';
import '../services/data_service.dart';
import '../services/tts_service.dart';
import '../services/settings_service.dart';

class PracticeScreen extends StatefulWidget {
  final String mode;
  final Unit? generatedUnit;

  const PracticeScreen({super.key, required this.mode, this.generatedUnit});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  final DataService _dataService = DataService();
  final TTSService _ttsService = TTSService();
  final SettingsService _settingsService = SettingsService();
  List<Unit> _units = [];
  Unit? _selectedUnit;
  int _currentExerciseIndex = 0;
  final TextEditingController _answerController = TextEditingController();
  bool _isLoading = true;
  int _correctAnswers = 0;
  List<Map<String, dynamic>> _results = [];
  bool _showResult = false;
  bool _isPlayingAudio = false;
  final FocusNode _answerFocusNode = FocusNode();
  bool _showJapaneseTranslation = false;
  List<Map<String, dynamic>> _randomExercises = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final showJapanese = await _settingsService.getShowJapaneseTranslation();
    setState(() {
      _showJapaneseTranslation = showJapanese;
    });
  }

  void _startRandomPractice() {
    if (_randomExercises.isNotEmpty) {
      // Create a virtual unit for random exercises
      final virtualUnit = Unit(
        unitId: 'random',
        title: 'Random Practice',
        level: 'mixed',
        description: 'Random exercises from all units',
        exercises: _randomExercises.map((e) => e['exercise'] as Exercise).toList(),
        settings: Settings(voice: 'en-US', speed: 1.0, repeatAllowed: 3),
      );
      _selectUnit(virtualUnit);
    }
  }

  void _startExercise() {
    if (_selectedUnit != null && _currentExerciseIndex < _selectedUnit!.exercises.length) {
      // Show loading for 3 seconds, then play audio
      setState(() {
        _isPlayingAudio = true;
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _isPlayingAudio = false;
          });
          // Focus on answer field before playing audio
          _answerFocusNode.requestFocus();
          _playAudio();
        }
      });
    }
  }

  Future<void> _loadData() async {
    if (widget.mode == 'ai_generated' && widget.generatedUnit != null) {
      // Save the generated unit first
      await _dataService.saveUnit(widget.generatedUnit!);
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('AI generated unit "${widget.generatedUnit!.title}" has been saved!'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      _selectUnit(widget.generatedUnit!);
      setState(() {
        _isLoading = false;
      });
    } else {
      _units = await _dataService.loadUnits();
      if (widget.mode == 'random') {
        // For random mode, prepare shuffled exercises
        _prepareRandomExercises();
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _prepareRandomExercises() {
    List<Map<String, dynamic>> allExercises = [];
    for (final unit in _units) {
      for (final exercise in unit.exercises) {
        allExercises.add({
          'exercise': exercise,
          'unit': unit,
        });
      }
    }
    allExercises.shuffle(); // Randomize order
    _randomExercises = allExercises;
  }

  void _selectUnit(Unit unit) {
    setState(() {
      _selectedUnit = unit;
      _currentExerciseIndex = 0;
      _correctAnswers = 0;
      _results = [];
      _showResult = false;
    });
    // Start exercise immediately for selected unit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startExercise();
    });
  }

  void _playAudio() {
    if (_selectedUnit != null) {
      final exercise = _selectedUnit!.exercises[_currentExerciseIndex];
      _ttsService.speak(
        exercise.text,
        voice: _selectedUnit!.settings.voice,
        speed: _selectedUnit!.settings.speed,
      );
    }
  }

  bool _checkAnswer(String userAnswer, String correctAnswer) {
    // Normalize answers: remove punctuation and extra spaces, convert to lowercase
    String normalize(String text) {
      return text.toLowerCase()
          .replaceAll(RegExp(r'[^\w\s]'), '') // Remove punctuation
          .replaceAll(RegExp(r'\s+'), ' ') // Normalize spaces
          .trim();
    }

    String normalizedUser = normalize(userAnswer);
    String normalizedCorrect = normalize(correctAnswer);

    // Exact match
    if (normalizedUser == normalizedCorrect) {
      return true;
    }

    // Word-level similarity (80% threshold)
    List<String> userWords = normalizedUser.split(' ');
    List<String> correctWords = normalizedCorrect.split(' ');
    int matches = 0;
    for (String word in userWords) {
      if (correctWords.contains(word)) {
        matches++;
      }
    }
    double similarity = matches / correctWords.length;
    return similarity >= 0.8;
  }

  void _submitAnswer() {
    if (_selectedUnit == null) return;

    final exercise = _selectedUnit!.exercises[_currentExerciseIndex];
    final userAnswer = _answerController.text.trim();
    final isCorrect = _checkAnswer(userAnswer, exercise.text);

    if (isCorrect) {
      _correctAnswers++;
    }

    _results.add({
      'exercise': exercise,
      'userAnswer': userAnswer,
      'isCorrect': isCorrect,
    });

    if (_currentExerciseIndex < _selectedUnit!.exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _answerController.clear();
        _isPlayingAudio = false;
      });
      // Start next exercise
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startExercise();
      });
    } else {
      // Finish practice
      setState(() {
        _showResult = true;
      });
    }
  }

  @override
  void dispose() {
    _answerController.dispose();
    _answerFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // For random mode, skip unit selection and start practice immediately
    if (widget.mode == 'random' && _selectedUnit == null && _randomExercises.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startRandomPractice();
      });
    }

    if (_selectedUnit == null && widget.mode != 'random') {
      return Scaffold(
        appBar: AppBar(title: Text('${widget.mode} Practice')),
        body: ListView.builder(
          itemCount: _units.length,
          itemBuilder: (context, index) {
            final unit = _units[index];
            return ListTile(
              title: Text(unit.title),
              subtitle: Text(unit.description),
              onTap: () => _selectUnit(unit),
            );
          },
        ),
      );
    }

    if (_showResult) {
      final accuracy = (_correctAnswers / _selectedUnit!.exercises.length * 100).round();
      return Scaffold(
        appBar: AppBar(title: const Text('Practice Results')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Practice Completed!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              Text(
                'Accuracy: $accuracy%',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                'Correct: $_correctAnswers / ${_selectedUnit!.exercises.length}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final result = _results[index];
                    final exercise = result['exercise'] as Exercise;
                    final userAnswer = result['userAnswer'] as String;
                    final isCorrect = result['isCorrect'] as bool;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Exercise ${index + 1}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text('Correct: ${exercise.text}'),
                            if (_showJapaneseTranslation && exercise.japanese != null)
                              Text('日本語訳: ${exercise.japanese}', style: const TextStyle(fontSize: 14, color: Colors.blue)),
                            Text('Your answer: $userAnswer'),
                            Text(
                              isCorrect ? '✓ Correct' : '✗ Incorrect',
                              style: TextStyle(
                                color: isCorrect ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      );
    }

    // Practice UI
    final exercise = _selectedUnit!.exercises[_currentExerciseIndex];

    return Scaffold(
      appBar: AppBar(title: Text(_selectedUnit!.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Exercise ${_currentExerciseIndex + 1} of ${_selectedUnit!.exercises.length}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            if (_isPlayingAudio)
              const CircularProgressIndicator()
            else
              const Text('Listen to the audio...'),
            const SizedBox(height: 10),
            Text(
              'Hint: ${exercise.hint}',
              style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _answerController,
              focusNode: _answerFocusNode,
              decoration: const InputDecoration(
                labelText: 'Type what you heard (press Enter to submit)',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _submitAnswer(),
            ),
          ],
        ),
      ),
    );
  }
}