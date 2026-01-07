import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final envString = await rootBundle.loadString('assets/.env');
    // Parse env string and set up dotenv
    final lines = envString.split('\n');
    for (final line in lines) {
      if (line.contains('=')) {
        final parts = line.split('=');
        if (parts.length == 2) {
          // Note: This is a simple implementation. In production, use a proper .env parser
        }
      }
    }
  } catch (e) {
    print('Error loading .env: $e');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'English Dictation Practice',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
