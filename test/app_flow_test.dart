import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frog_pond_english/app.dart';
import 'package:frog_pond_english/models/topic.dart';
import 'package:frog_pond_english/screens/game_screen.dart';
import 'package:frog_pond_english/services/progress_store.dart';
import 'package:frog_pond_english/services/speech_service.dart';
import 'package:frog_pond_english/widgets/lily_pad.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _topic = Topic(
  id: 'fruits',
  title: 'Fruits',
  titleVi: 'Trái cây',
  icon: '🍎',
  clue: 'The frog is under the {word}!',
  words: [
    VocabWord(word: 'apple', picture: '🍎', vi: 'quả táo'),
    VocabWord(word: 'pear', picture: '🍐', vi: 'quả lê'),
  ],
  levels: [
    LevelConfig(pads: 2, rounds: 1),
    LevelConfig(pads: 2, rounds: 1, showWord: false),
  ],
);

void main() {
  testWidgets('find the frog, earn stars and unlock the next level',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final progress = await ProgressStore.load();
    final speech = SilentSpeechService();
    await tester.pumpWidget(FrogPondApp(
      topics: const [_topic],
      progress: progress,
      speech: speech,
    ));

    await tester.tap(find.text('Fruits'));
    await tester.pumpAndSettle();
    expect(find.text('🔒'), findsOneWidget);

    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();
    // Which exact sentence (the long one or a short one) is random, so
    // just check it names the target word.
    final clue = speech.spoken.last;
    expect(clue.contains('apple') || clue.contains('pear'), isTrue);

    final state = tester.state(find.byType(GameScreen));
    // The target word is written on the banner in level 1.
    final target = clue.contains('apple') ? 'apple' : 'pear';
    expect(find.text(target), findsOneWidget);
    final other = target == 'apple' ? '🍐' : '🍎';

    // A wrong tap says the tapped word.
    await tester.tap(find.descendant(
      of: find.byType(LilyPadTile),
      matching: find.text(other),
    ));
    await tester.pumpAndSettle();
    expect(speech.spoken.last, endsWith('Try again!'));

    await tester.tap(find.descendant(
      of: find.byType(LilyPadTile),
      matching: find.text(target == 'apple' ? '🍎' : '🍐'),
    ));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(state.mounted, isTrue);
    expect(find.text('Great job! 🎉'), findsOneWidget);
    expect(progress.stars('fruits', 0), 2);

    await tester.tap(find.text('Chọn màn'));
    await tester.pumpAndSettle();
    expect(find.text('🔒'), findsNothing);
  });

  testWidgets('listen-only level hides the word until found', (tester) async {
    SharedPreferences.setMockInitialValues({'stars.fruits.0': 3});
    final speech = SilentSpeechService();
    await tester.pumpWidget(FrogPondApp(
      topics: const [_topic],
      progress: await ProgressStore.load(),
      speech: speech,
    ));
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.push(MaterialPageRoute<void>(
      builder: (_) => GameScreen(topic: _topic, levelIndex: 1, random: Random(0)),
    ));
    await tester.pumpAndSettle();
    expect(find.text('👂 Listen!'), findsOneWidget);
    expect(find.text('apple'), findsNothing);
    expect(find.text('pear'), findsNothing);
  });
}
