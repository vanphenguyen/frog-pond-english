import 'package:flutter_test/flutter_test.dart';
import 'package:frog_pond_english/services/speech_service.dart';

void main() {
  test('no voices loaded yet gives no pick', () {
    expect(pickEnglishVoice([]), isNull);
    expect(
      pickEnglishVoice([
        {'name': 'Linh', 'locale': 'vi-VN'},
      ]),
      isNull,
    );
  });

  test('prefers a known natural voice over the first English one', () {
    final voice = pickEnglishVoice([
      {'name': 'Linh', 'locale': 'vi-VN'},
      {'name': 'Bubbles', 'locale': 'en-US'},
      {'name': 'Daniel', 'locale': 'en-GB'},
      {'name': 'Samantha', 'locale': 'en-US'},
    ]);
    expect(voice, {'name': 'Samantha', 'locale': 'en-US'});
  });

  test('falls back to American, then any English, skipping joke voices', () {
    expect(
      pickEnglishVoice([
        {'name': 'Zarvox', 'locale': 'en-US'},
        {'name': 'Daniel', 'locale': 'en-GB'},
        {'name': 'Fred', 'locale': 'en_US'},
      ]),
      {'name': 'Fred', 'locale': 'en_US'},
    );
    expect(
      pickEnglishVoice([
        {'name': 'Karen', 'locale': 'en-AU'},
      ]),
      {'name': 'Karen', 'locale': 'en-AU'},
    );
  });
}
