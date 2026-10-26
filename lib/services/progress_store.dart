import 'package:shared_preferences/shared_preferences.dart';

import '../models/topic.dart';

/// Best star count per level, saved on the device only.
class ProgressStore {
  ProgressStore(this._prefs);

  static Future<ProgressStore> load() async =>
      ProgressStore(await SharedPreferences.getInstance());

  final SharedPreferences _prefs;

  String _key(String topicId, int level) => 'stars.$topicId.$level';

  int stars(String topicId, int level) => _prefs.getInt(_key(topicId, level)) ?? 0;

  /// Keeps the best result: replaying a level never lowers its stars.
  Future<void> saveStars(String topicId, int level, int value) async {
    if (value > stars(topicId, level)) {
      await _prefs.setInt(_key(topicId, level), value);
    }
  }

  /// The first level is always open; the next opens after earning a star.
  bool isUnlocked(String topicId, int level) =>
      level == 0 || stars(topicId, level - 1) > 0;

  int totalStars(Topic topic) => [
        for (var i = 0; i < topic.levels.length; i++) stars(topic.id, i),
      ].fold(0, (a, b) => a + b);
}
