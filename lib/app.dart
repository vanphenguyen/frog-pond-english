import 'package:flutter/material.dart';

import 'models/topic.dart';
import 'screens/home_screen.dart';
import 'services/progress_store.dart';
import 'services/speech_service.dart';

/// Shared services, available to every screen via [AppScope.of].
class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.topics,
    required this.progress,
    required this.speech,
    required super.child,
  });

  final List<Topic> topics;
  final ProgressStore progress;
  final SpeechService speech;

  static AppScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!;

  @override
  bool updateShouldNotify(AppScope oldWidget) =>
      topics != oldWidget.topics ||
      progress != oldWidget.progress ||
      speech != oldWidget.speech;
}

class FrogPondApp extends StatelessWidget {
  const FrogPondApp({
    super.key,
    required this.topics,
    required this.progress,
    required this.speech,
  });

  final List<Topic> topics;
  final ProgressStore progress;
  final SpeechService speech;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      topics: topics,
      progress: progress,
      speech: speech,
      child: MaterialApp(
        title: 'Frog Pond English',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3FA34D)),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
