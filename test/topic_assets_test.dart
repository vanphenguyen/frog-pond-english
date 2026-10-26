import 'package:flutter_test/flutter_test.dart';
import 'package:frog_pond_english/data/topic_repository.dart';

/// Guards the JSON files in assets/topics: run after adding words or levels.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('all topic files load and are valid', () async {
    final topics = await TopicRepository().loadAll();
    expect(topics, isNotEmpty);

    final ids = topics.map((t) => t.id).toList();
    expect(ids.toSet(), hasLength(ids.length), reason: 'duplicate topic id');
    for (final topic in topics) {
      expect(topic.validate(), isEmpty, reason: topic.id);
    }
  });
}
