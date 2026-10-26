import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:frog_pond_english/game/game_session.dart';
import 'package:frog_pond_english/models/topic.dart';

Topic _topic({int pads = 3, int rounds = 3, int wordCount = 5}) => Topic(
      id: 'test',
      title: 'Test',
      titleVi: 'Thử',
      icon: '🧪',
      clue: 'Find {word}',
      words: [
        for (var i = 0; i < wordCount; i++)
          VocabWord(word: 'w$i', picture: '$i'),
      ],
      levels: [LevelConfig(pads: pads, rounds: rounds)],
    );

void main() {
  test('each round has distinct pads and the frog is on one of them', () {
    final topic = _topic(pads: 4);
    final session =
        GameSession(topic: topic, level: topic.levels.first, random: Random(1));
    final words = session.round.pads.map((w) => w.word).toSet();
    expect(words, hasLength(4));
    expect(session.round.frogIndex, inInclusiveRange(0, 3));
  });

  test('wrong taps count once per pad and correct tap solves the round', () {
    final topic = _topic();
    final session =
        GameSession(topic: topic, level: topic.levels.first, random: Random(2));
    final wrong = (session.round.frogIndex + 1) % 3;

    expect(session.tap(wrong), TapOutcome.wrong);
    expect(session.tap(wrong), TapOutcome.ignored);
    expect(session.mistakes, 1);
    expect(session.tap(session.round.frogIndex), TapOutcome.correct);
    expect(session.tap(wrong), TapOutcome.ignored);
    expect(session.roundSolved, isTrue);
  });

  test('plays through all rounds without repeating a target back to back', () {
    final topic = _topic(rounds: 20);
    final session =
        GameSession(topic: topic, level: topic.levels.first, random: Random(3));
    var previous = '';
    while (true) {
      expect(session.round.target.word, isNot(previous));
      previous = session.round.target.word;
      session.tap(session.round.frogIndex);
      if (session.isFinished) break;
      session.nextRound();
    }
    expect(session.roundNumber, 20);
    expect(session.stars, 3);
  });

  test('stars drop with mistakes', () {
    expect(GameSession.starsFor(0, 4), 3);
    expect(GameSession.starsFor(2, 4), 2);
    expect(GameSession.starsFor(3, 4), 1);
    expect(GameSession.starsFor(1, 1), 2);
  });

  test('frog counter grows with solved rounds, mistakes pull it back down', () {
    final topic = _topic(pads: 3, rounds: 3);
    final session =
        GameSession(topic: topic, level: topic.levels.first, random: Random(5));
    expect(session.livesRemaining, 0); // starts empty, not full

    // Round 1: one mistake, then solved. Earning the 1st frog cancels out
    // the 1 accumulated mistake, so the counter is still 0, not 1.
    session.tap((session.round.frogIndex + 1) % 3);
    expect(session.livesRemaining, 0);
    // Re-tapping the same wrong pad is ignored: not a new mistake.
    session.tap((session.round.frogIndex + 1) % 3);
    expect(session.livesRemaining, 0);
    session.tap(session.round.frogIndex);
    expect(session.livesRemaining, 0);
    session.nextRound();

    // Round 2: solved with no mistakes — the counter can finally grow.
    session.tap(session.round.frogIndex);
    expect(session.livesRemaining, 1);
    session.nextRound();

    // Round 3: a mistake here eats into the frog already earned, dipping
    // the counter back below what was shown a moment ago.
    session.tap((session.round.frogIndex + 1) % 3);
    expect(session.livesRemaining, 0);
    session.tap(session.round.frogIndex);
    expect(session.livesRemaining, 1); // 3 rounds done, 2 mistakes total
    expect(session.isFinished, isTrue);
  });

  Topic clueTopic() => Topic(
        id: 'test',
        title: 'Test',
        titleVi: 'Thử',
        icon: '🧪',
        clue: 'Where is {word}?',
        shortClues: const ['A {word}', 'B {word}', 'C {word}'],
        words: [for (var i = 0; i < 5; i++) VocabWord(word: 'w$i', picture: '$i')],
        levels: const [LevelConfig(pads: 3, rounds: 30)],
      );

  test('clue sentence varies round to round, never repeating immediately', () {
    final topic = clueTopic();
    final session =
        GameSession(topic: topic, level: topic.levels.first, random: Random(4));
    final templates = <String>[session.round.clue[0]];
    while (!session.isLastRound) {
      session.tap(session.round.frogIndex);
      session.nextRound();
      final clue = session.round.clue;
      expect(clue, contains(session.round.target.word));
      templates.add(clue[0]);
    }
    for (var i = 1; i < templates.length; i++) {
      expect(templates[i], isNot(templates[i - 1]));
    }
    // "Where is ...?" (W) and the 3 short ones (A, B, C) all get a turn.
    expect(templates.toSet(), {'W', 'A', 'B', 'C'});
  });

  test('a new level does not always open with the long sentence', () {
    // Starting level after level used to always speak the long "Where is
    // the frog?" sentence first — children found that repetitive. Across
    // many fresh levels (= fresh sessions) at least one should now open
    // with a short clue instead.
    final topic = clueTopic();
    final firstClues = [
      for (var seed = 0; seed < 30; seed++)
        GameSession(
          topic: topic,
          level: topic.levels.first,
          random: Random(seed),
        ).round.clue[0],
    ];
    expect(firstClues, contains(isNot('W')));
  });

  test('clue without the word placeholder is reported', () {
    final topic = Topic(
      id: 'bad',
      title: 'Bad',
      titleVi: '',
      icon: '❌',
      clue: 'Where is it?',
      words: [for (var i = 0; i < 3; i++) VocabWord(word: 'w$i', picture: '$i')],
      levels: const [LevelConfig(pads: 2, rounds: 1)],
    );
    expect(topic.validate(), [contains('has no {word}')]);
  });

  test('clue mentioning the frog is reported', () {
    // The frog only pops up as a reward for a correct tap; it is never one
    // of the pictures on a lily pad, so a clue naming it instead of the
    // word being taught misleads the child (see CHANGELOG, user feedback).
    final topic = Topic(
      id: 'bad',
      title: 'Bad',
      titleVi: '',
      icon: '❌',
      clue: 'Where is the frog? It is under the {word}!',
      words: [for (var i = 0; i < 3; i++) VocabWord(word: 'w$i', picture: '$i')],
      levels: const [LevelConfig(pads: 2, rounds: 1)],
    );
    expect(topic.validate(), [contains('mentions the frog')]);
  });

  test('clue replaces the word placeholder', () {
    final topic = _topic();
    expect(topic.clueFor(topic.words.first), 'Find w0');
  });
}
