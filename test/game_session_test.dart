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

  test('clue replaces the word placeholder', () {
    final topic = _topic();
    expect(topic.clueFor(topic.words.first), 'Find w0');
  });
}
