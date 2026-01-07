import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class TTSService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> speak(String text, {String? voice, double? speed}) async {
    try {
      // Use gTTS API to generate audio
      final url = Uri.parse(
        'https://translate.google.com/translate_tts?ie=UTF-8&client=tw-ob&q=${Uri.encodeComponent(text)}&tl=${voice ?? 'en'}&ttsspeed=${speed ?? 1.0}',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        // Save to temporary file
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/tts_audio.mp3');
        await file.writeAsBytes(response.bodyBytes);

        // Play the audio
        await _audioPlayer.play(DeviceFileSource(file.path));
      } else {
        throw Exception('Failed to generate TTS audio');
      }
    } catch (e) {
      print('TTS Error: $e');
    }
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> resume() async {
    await _audioPlayer.resume();
  }
}