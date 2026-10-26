import 'dart:math';

import '../models/topic.dart';

enum TapOutcome { correct, wrong, ignored }

/// One pond layout: the words on the pads and which pad hides the frog.
class Round {
  const Round(this.pads, this.frogIndex);

  final List<VocabWord> pads;
  final int frogIndex;

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
    round = Round(pads, choices[_random.nextInt(choices.length)]);
    tried.clear();
    roundSolved = false;
  }
}
