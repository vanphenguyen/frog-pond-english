import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'data/topic_repository.dart';
import 'services/progress_store.dart';
import 'services/speech_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final topics = await TopicRepository().loadAll();
  final progress = await ProgressStore.load();
  runApp(FrogPondApp(
    topics: topics,
    progress: progress,
    speech: TtsSpeechService(),
  ));
}
