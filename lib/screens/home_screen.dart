import 'package:flutter/material.dart';

import '../app.dart';
import '../models/topic.dart';
import '../widgets/pond_background.dart';
import 'level_select_screen.dart';

/// Lists the vocabulary topics.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _open(Topic topic) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => LevelSelectScreen(topic: topic),
    ));
    setState(() {}); // Refresh star totals.
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return Scaffold(
      body: PondBackground(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 24),
              const Text('🐸', style: TextStyle(fontSize: 72)),
              const Text(
                'Frog Pond English',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 6, color: Colors.black26)],
                ),
              ),
              const Text(
                'Tìm chú ếch, học tiếng Anh!',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(16),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    for (final topic in scope.topics)
                      _TopicCard(
                        topic: topic,
                        stars: scope.progress.totalStars(topic),
                        onTap: () => _open(topic),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.topic,
    required this.stars,
    required this.onTap,
  });

  final Topic topic;
  final int stars;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(topic.icon, style: const TextStyle(fontSize: 48)),
            Text(
              topic.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            Text(topic.titleVi, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 4),
            Text('⭐ $stars / ${topic.levels.length * 3}'),
          ],
        ),
      ),
    );
  }
}
