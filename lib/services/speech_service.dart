import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Speaks English words and sentences to the child.
abstract class SpeechService {
  Future<void> speak(String text);
  Future<void> stop();
}

/// Uses the device's built-in text-to-speech engine.
class TtsSpeechService implements SpeechService {
  final FlutterTts _tts = FlutterTts();
  Future<void>? _setup;

  Future<void> _ensureSetup() => _setup ??= () async {
        await _tts.setLanguage('en-US');
        // Slow and slightly high-pitched so young children can follow.
        // The web engine uses 1.0 as normal speed, mobile engines use 0.5.
        await _tts.setSpeechRate(kIsWeb ? 0.8 : 0.4);
        await _tts.setPitch(1.1);
      }();

  @override
  Future<void> speak(String text) async {
    try {
      await _ensureSetup();
      await _tts.stop();
      await _tts.speak(text);
    } catch (e) {
      // A missing TTS engine must never crash the game.
      debugPrint('TTS failed: $e');
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }
}

/// Records what would be spoken; used in tests.
class SilentSpeechService implements SpeechService {
  final List<String> spoken = [];

  @override
  Future<void> speak(String text) async => spoken.add(text);

  @override
  Future<void> stop() async {}
}
