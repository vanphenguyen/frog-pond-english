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
  bool _webVoicePicked = false;

  Future<void> _ensureSetup() => _setup ??= () async {
        await _tts.setLanguage('en-US');
        // Slow and slightly high-pitched so young children can follow.
        // The web engine uses 1.0 as normal speed, mobile engines use 0.5.
        await _tts.setSpeechRate(kIsWeb ? 0.8 : 0.4);
        await _tts.setPitch(1.1);
      }();

  /// Browsers load their voice list in the background, so at the first call
  /// there may be no English voice yet. Without one the browser falls back to
  /// the phone's own language (Vietnamese), so keep trying until one is set.
  Future<void> _ensureWebVoice() async {
    if (!kIsWeb || _webVoicePicked) return;
    // Wait up to a second so even the very first hint gets the English voice.
    for (var attempt = 0; attempt < 10; attempt++) {
      final voices = await _tts.getVoices;
      final voice = pickEnglishVoice(voices is List ? voices : const []);
      if (voice != null) {
        await _tts.setVoice(voice);
        _webVoicePicked = true;
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
  }

  @override
  Future<void> speak(String text) async {
    try {
      await _ensureSetup();
      await _ensureWebVoice();
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

/// Picks a natural English voice from the platform's voice list
/// (maps with `name` and `locale`), or null when there is none yet.
Map<String, String>? pickEnglishVoice(List<dynamic> voices) {
  final english = <Map<String, String>>[];
  for (final v in voices) {
    if (v is! Map) continue;
    final name = '${v['name'] ?? ''}';
    final locale = '${v['locale'] ?? ''}';
    if (!locale.toLowerCase().replaceAll('_', '-').startsWith('en')) continue;
    if (_noveltyVoices.contains(name)) continue;
    english.add({'name': name, 'locale': locale});
  }
  if (english.isEmpty) return null;
  for (final preferred in _preferredVoices) {
    for (final v in english) {
      if (v['name']!.contains(preferred)) return v;
    }
  }
  bool isUs(Map<String, String> v) =>
      v['locale']!.toLowerCase().replaceAll('_', '-') == 'en-us';
  return english.firstWhere(isUs, orElse: () => english.first);
}

/// Clear, friendly voices on iPhone/Mac, Chrome and Windows.
const _preferredVoices = [
  'Samantha',
  'Google US English',
  'Microsoft Aria',
  'Microsoft Jenny',
];

/// Apple's joke voices (singing, whispering, robots): confusing for children.
const _noveltyVoices = {
  'Albert',
  'Bad News',
  'Bahh',
  'Bells',
  'Boing',
  'Bubbles',
  'Cellos',
  'Deranged',
  'Good News',
  'Hysterical',
  'Jester',
  'Organ',
  'Pipe Organ',
  'Superstar',
  'Trinoids',
  'Whisper',
  'Wobble',
  'Zarvox',
};

/// Records what would be spoken; used in tests.
class SilentSpeechService implements SpeechService {
  final List<String> spoken = [];

  @override
  Future<void> speak(String text) async => spoken.add(text);

  @override
  Future<void> stop() async {}
}
