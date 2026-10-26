import 'dart:math';

import 'package:flutter/material.dart';

import '../app.dart';
import '../game/game_session.dart';
import '../models/topic.dart';
import '../services/speech_service.dart';
import '../widgets/lily_pad.dart';
import '../widgets/pond_background.dart';

enum _ResultChoice { replay, next, levels }

/// The pond: listen to the clue and tap the lily pad hiding the frog.
class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.topic,
    required this.levelIndex,
    this.random,
  });

  final Topic topic;
  final int levelIndex;

  /// Fixed randomness for tests.
  final Random? random;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late int _levelIndex = widget.levelIndex;
  late GameSession _session;
  late SpeechService _speech;
  List<int> _shakes = [];

  /// Changes every round so the pads are rebuilt fresh, without animating
  /// the previous round's frog away.
  int _roundSerial = 0;

  LevelConfig get _level => widget.topic.levels[_levelIndex];

  @override
  void initState() {
    super.initState();
    _startLevel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _speech = AppScope.of(context).speech;
  }

  void _startLevel() {
    _session = GameSession(
      topic: widget.topic,
      level: _level,
      random: widget.random,
    );
    _shakes = List.filled(_level.pads, 0);
    _roundSerial++;
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakClue());
  }

  void _speakClue() {
    if (!mounted) return;
    _speech.speak(_session.round.clue);
  }

  Future<void> _onTap(int index) async {
    final word = _session.round.pads[index].word;
    switch (_session.tap(index)) {
      case TapOutcome.ignored:
        return;
      case TapOutcome.wrong:
        setState(() => _shakes[index]++);
        _speech.speak('$word. Try again!');
      case TapOutcome.correct:
        setState(() {});
        _speech.speak('Yes! $word! Great job!');
        await Future<void>.delayed(const Duration(milliseconds: 1800));
        if (!mounted) return;
        if (_session.isLastRound) {
          await _finishLevel();
        } else {
          setState(() {
            _session.nextRound();
            _shakes = List.filled(_level.pads, 0);
            _roundSerial++;
          });
          _speakClue();
        }
    }
  }

  Future<void> _finishLevel() async {
    final stars = _session.stars;
    await AppScope.of(context)
        .progress
        .saveStars(widget.topic.id, _levelIndex, stars);
    _speech.speak('Well done! You found all the frogs!');
    if (!mounted) return;
    final hasNext = _levelIndex + 1 < widget.topic.levels.length;
    final choice = await showDialog<_ResultChoice>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ResultDialog(
        stars: stars,
        mistakes: _session.mistakes,
        hasNext: hasNext,
      ),
    );
    if (!mounted) return;
    switch (choice) {
      case _ResultChoice.replay:
        setState(_startLevel);
      case _ResultChoice.next:
        setState(() {
          _levelIndex++;
          _startLevel();
        });
      case _ResultChoice.levels || null:
        Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PondBackground(
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(
                session: _session,
                onClose: () => Navigator.of(context).pop(),
                onRepeat: _speakClue,
              ),
              _ClueBanner(
                session: _session,
                showWord: _level.showWord,
                onTap: _speakClue,
              ),
              Expanded(child: _buildPond()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPond() {
    final round = _session.round;
    final count = round.pads.length;
    final cols = count <= 4 ? 2 : (count <= 9 ? 3 : 4);
    final rows = (count / cols).ceil();
    return LayoutBuilder(builder: (context, constraints) {
      final cellW = constraints.maxWidth / cols;
      final cellH = constraints.maxHeight / rows;
      final padSize = min(cellW, cellH) * 0.82;
      return Stack(
        children: [
          for (var i = 0; i < count; i++)
            Positioned(
              // Small fixed offsets so the pads do not look like a grid.
              left: (i % cols) * cellW +
                  (cellW - padSize) / 2 +
                  ((i * 37) % 11 - 5) * cellW / 100,
              top: (i ~/ cols) * cellH +
                  (cellH - padSize) / 2 +
                  ((i * 53) % 13 - 6) * cellH / 100,
              child: LilyPadTile(
                key: ValueKey('pad-$_roundSerial-$i'),
                size: padSize,
                picture: round.pads[i].picture,
                label: _session.tried.contains(i) ||
                        (_session.roundSolved && i == round.frogIndex)
                    ? round.pads[i].word
                    : null,
                dimmed: _session.tried.contains(i),
                hasFrog: _session.roundSolved && i == round.frogIndex,
                shakeCount: _shakes[i],
                onTap: () => _onTap(i),
              ),
            ),
        ],
      );
    });
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.session,
    required this.onClose,
    required this.onRepeat,
  });

  final GameSession session;
  final VoidCallback onClose;
  final VoidCallback onRepeat;

  @override
  Widget build(BuildContext context) {
    final done = session.roundNumber - (session.roundSolved ? 0 : 1);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            iconSize: 32,
            color: Colors.white,
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Thoát',
            onPressed: onClose,
          ),
          Expanded(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              children: [
                for (var r = 0; r < session.level.rounds; r++)
                  Opacity(
                    opacity: r < done ? 1 : 0.35,
                    child: const Text('🐸', style: TextStyle(fontSize: 22)),
                  ),
              ],
            ),
          ),
          IconButton(
            iconSize: 32,
            color: Colors.white,
            icon: const Icon(Icons.volume_up_rounded),
            tooltip: 'Nghe lại',
            onPressed: onRepeat,
          ),
        ],
      ),
    );
  }
}

class _ClueBanner extends StatelessWidget {
  const _ClueBanner({
    required this.session,
    required this.showWord,
    required this.onTap,
  });

  final GameSession session;
  final bool showWord;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final target = session.round.target;
    final solved = session.roundSolved;
    final String main;
    if (solved) {
      main = target.vi == null ? target.word : '${target.word} = ${target.vi}';
    } else {
      main = showWord ? target.word : '👂 Listen!';
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black26)],
        ),
        child: Column(
          children: [
            Text(
              solved ? 'You found it! 🎉' : 'Where is the frog? 🔊',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            Text(
              main,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1B5E20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultDialog extends StatelessWidget {
  const _ResultDialog({
    required this.stars,
    required this.mistakes,
    required this.hasNext,
  });

  final int stars;
  final int mistakes;
  final bool hasNext;

  @override
  Widget build(BuildContext context) {
    void choose(_ResultChoice c) => Navigator.of(context).pop(c);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: const Text('Great job! 🎉', textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${'⭐' * stars}${'☆' * (3 - stars)}',
            style: const TextStyle(fontSize: 44),
          ),
          Text(mistakes == 0 ? 'Không sai lần nào!' : 'Số lần chọn sai: $mistakes'),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => choose(_ResultChoice.levels),
          child: const Text('Chọn màn'),
        ),
        TextButton(
          onPressed: () => choose(_ResultChoice.replay),
          child: const Text('Chơi lại'),
        ),
        if (hasNext)
          FilledButton(
            onPressed: () => choose(_ResultChoice.next),
            child: const Text('Màn tiếp ➜'),
          ),
      ],
    );
  }
}
