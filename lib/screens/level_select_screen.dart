import 'package:flutter/material.dart';

import '../app.dart';
import '../models/topic.dart';
import '../widgets/lily_pad.dart';
import '../widgets/pond_background.dart';
import 'game_screen.dart';

/// Shows the levels of one topic as lily pads; later ones unlock with stars.
class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key, required this.topic});

  final Topic topic;

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  Future<void> _play(int levelIndex) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => GameScreen(topic: widget.topic, levelIndex: levelIndex),
    ));
    setState(() {}); // Refresh stars and unlocked levels.
  }

  @override
  Widget build(BuildContext context) {
    final topic = widget.topic;
    final progress = AppScope.of(context).progress;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: Text('${topic.icon} ${topic.title}'),
      ),
      body: PondBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 24,
                runSpacing: 24,
                alignment: WrapAlignment.center,
                children: [
                  for (var i = 0; i < topic.levels.length; i++)
                    _LevelButton(
                      number: i + 1,
                      level: topic.levels[i],
                      stars: progress.stars(topic.id, i),
                      unlocked: progress.isUnlocked(topic.id, i),
                      onTap: () => _play(i),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LevelButton extends StatelessWidget {
  const _LevelButton({
    required this.number,
    required this.level,
    required this.stars,
    required this.unlocked,
    required this.onTap,
  });

  final int number;
  final LevelConfig level;
  final int stars;
  final bool unlocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const size = 120.0;
    return Opacity(
      opacity: unlocked ? 1 : 0.5,
      child: GestureDetector(
        onTap: unlocked ? onTap : null,
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: const Size.square(size),
                  painter: LilyPadPainter(dimmed: !unlocked),
                ),
                Text(
                  unlocked ? '$number' : '🔒',
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 4)],
                  ),
                ),
              ],
            ),
            Text(
              '${'⭐' * stars}${'☆' * (3 - stars)}',
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
            Text(
              '${level.pads} lá sen · ${level.showWord ? 'nhìn chữ' : 'chỉ nghe'}',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
