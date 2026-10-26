import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/topic.dart';

/// Loads the topics listed in `assets/topics/index.json`, in that order.
class TopicRepository {
  TopicRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  static const _dir = 'assets/topics';

  final AssetBundle _bundle;

  Future<List<Topic>> loadAll() async {
    final index =
        jsonDecode(await _bundle.loadString('$_dir/index.json')) as Map;
    return [
      for (final file in (index['topics'] as List).cast<String>())
        Topic.fromJson(
          jsonDecode(await _bundle.loadString('$_dir/$file'))
              as Map<String, dynamic>,
        ),
    ];
  }
}
