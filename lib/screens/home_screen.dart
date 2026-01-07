import 'package:flutter/material.dart';
import 'practice_screen.dart';
import 'settings_screen.dart';
import 'ai_input_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('English Dictation Practice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select Practice Mode',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PracticeScreen(mode: 'existing'),
                  ),
                );
              },
              child: const Text('Practice Existing Units'),
            ),
            const SizedBox(height: 10),
            const Text('Select from available practice units', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AiInputScreen(),
                  ),
                );
              },
              child: const Text('AI Generated Units'),
            ),
            const SizedBox(height: 10),
            const Text('Generate custom units with AI', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PracticeScreen(mode: 'random'),
                  ),
                );
              },
              child: const Text('Random Practice'),
            ),
            const SizedBox(height: 10),
            const Text('Practice random exercises from all units', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PracticeScreen(mode: 'choice'),
                  ),
                );
              },
              child: const Text('Choice-Based Practice'),
            ),
            const SizedBox(height: 10),
            const Text('Multiple choice format', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PracticeScreen(mode: 'listening'),
                  ),
                );
              },
              child: const Text('Listening Repeat Mode'),
            ),
            const SizedBox(height: 10),
            const Text('Audio-only listening practice', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}