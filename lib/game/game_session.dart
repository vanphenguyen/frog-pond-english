import 'dart:math';

import '../models/topic.dart';

enum TapOutcome { correct, wrong, ignored }

/// One pond layout: the words on the pads, which pad hides the frog and
/// the sentence that asks for it.
class Round {
  const Round(this.pads, this.frogIndex, this.clue);

  final List<VocabWord> pads;
  final int frogIndex;
  final String clue;

  VocabWord get target => pads[frogIndex];
}

/// Rules of one level, independent of any UI so it can be unit tested.
class GameSession {
  GameSession({required this.topic, required this.level, Random? random})
      : _random = random ?? Random(),
        _pool = topic.wordsForLevel(level) {
    _startRound();
  }

  final Topic topic;
  final LevelConfig level;
  final Random _random;
  final List<VocabWord> _pool;
  String? _clueTemplate;

  late Round round;

  /// 1-based number of the current round.
  int roundNumber = 1;
  int mistakes = 0;
  bool roundSolved = false;

  /// Pads already tapped by mistake in the current round.
  final Set<int> tried = {};

  bool get isLastRound => roundNumber >= level.rounds;
  bool get isFinished => roundSolved && isLastRound;
  int get stars => starsFor(mistakes, level.rounds);

  /// Frogs left in the top-bar counter: starts at [LevelConfig.rounds] and
  /// drops by one for every wrong tap, never below 0 (a wrong tap past the
  /// last frog just keeps the counter at 0, it does not end the level).
  int get livesRemaining => max(0, level.rounds - mistakes);

  static int starsFor(int mistakes, int rounds) {
    if (mistakes == 0) return 3;
    if (mistakes <= max(1, rounds ~/ 2)) return 2;
    return 1;
  }

  TapOutcome tap(int index) {
    if (roundSolved || tried.contains(index)) return TapOutcome.ignored;
    if (index == round.frogIndex) {
      roundSolved = true;
      return TapOutcome.correct;
    }
    tried.add(index);
    mistakes++;
    return TapOutcome.wrong;
  }

  void nextRound() {
    assert(roundSolved && !isLastRound, 'nextRound called too early');
    roundNumber++;
    _startRound();
  }

  void _startRound() {
    final previous = roundNumber > 1 ? round.target : null;
    final pads = ([..._pool]..shuffle(_random)).take(level.pads).toList();
    // Avoid asking for the same word twice in a row when possible.
    final choices = [
      for (var i = 0; i < pads.length; i++)
        if (!identical(pads[i], previous)) i,
    ];
    final frogIndex = choices[_random.nextInt(choices.length)];
    round = Round(pads, frogIndex, topic.clueFor(pads[frogIndex], _nextClue()));
    tried.clear();
    roundSolved = false;
  }

  /// Picks a random sentence out of the full clue and the short ones,
  /// without using the same one twice in a row. The first round of a level
  /// is not special-cased to the long sentence anymore: with many levels in
  /// a row that made "Where is the frog?" the first thing heard every
  /// single time, which children found repetitive.
  String _nextClue() {
    final pool = [topic.clue, ...topic.shortClues];
    final choices = [
      for (final c in pool)
        if (c != _clueTemplate) c,
    ];
    final options = choices.isEmpty ? pool : choices;
    return _clueTemplate = options[_random.nextInt(options.length)];
  }
}
