/// Data model for a vocabulary topic, loaded from `assets/topics/<id>.json`.
///
/// Adding words or levels only needs a JSON change; see docs/GAME_DESIGN.md.
library;

class VocabWord {
  const VocabWord({required this.word, required this.picture, this.vi});

  factory VocabWord.fromJson(Map<String, dynamic> json) => VocabWord(
        word: json['word'] as String,
        picture: json['picture'] as String,
        vi: json['vi'] as String?,
      );

  /// English word that is spoken and shown, e.g. "apple".
  final String word;

  /// Emoji or short text drawn on the lily pad, e.g. "🍎" or "3".
  final String picture;

  /// Vietnamese meaning, shown to the child after the frog is found.
  final String? vi;
}

class LevelConfig {
  const LevelConfig({
    required this.pads,
    required this.rounds,
    this.showWord = true,
    this.words,
  });

  factory LevelConfig.fromJson(Map<String, dynamic> json) => LevelConfig(
        pads: json['pads'] as int,
        rounds: json['rounds'] as int,
        showWord: json['showWord'] as bool? ?? true,
        words: (json['words'] as List<dynamic>?)?.cast<String>(),
      );

  /// Number of lily pads on the pond.
  final int pads;

  /// Number of frogs to find before the level ends.
  final int rounds;

  /// Whether the target word is written on screen (false = listening only).
  final bool showWord;

  /// Optional subset of the topic's words; null means all of them.
  final List<String>? words;
}

class Topic {
  const Topic({
    required this.id,
    required this.title,
    required this.titleVi,
    required this.icon,
    required this.clue,
    this.shortClues = defaultShortClues,
    required this.words,
    required this.levels,
  });

  factory Topic.fromJson(Map<String, dynamic> json) => Topic(
        id: json['id'] as String,
        title: json['title'] as String,
        titleVi: json['titleVi'] as String? ?? '',
        icon: json['icon'] as String,
        clue: json['clue'] as String? ?? defaultClue,
        shortClues: (json['shortClues'] as List<dynamic>?)?.cast<String>() ??
            defaultShortClues,
        words: [
          for (final w in json['words'] as List<dynamic>)
            VocabWord.fromJson(w as Map<String, dynamic>),
        ],
        levels: [
          for (final l in json['levels'] as List<dynamic>)
            LevelConfig.fromJson(l as Map<String, dynamic>),
        ],
      );

  static const defaultClue = 'Where is the frog? It is under the {word}!';
  static const defaultShortClues = [
    'Find the {word}!',
    'Can you find the {word}?',
    'Where is the {word}?',
    'Now, the {word}!',
    'Look for the {word}!',
  ];

  final String id;
  final String title;
  final String titleVi;
  final String icon;

  /// Sentence spoken in the first round of a level; `{word}` is replaced.
  final String clue;

  /// Shorter sentences, one picked at random for each later round so the
  /// same words are not repeated every time.
  final List<String> shortClues;
  final List<VocabWord> words;
  final List<LevelConfig> levels;

  String clueFor(VocabWord target, [String? template]) =>
      (template ?? clue).replaceAll('{word}', target.word);

  List<VocabWord> wordsForLevel(LevelConfig level) {
    final subset = level.words;
    if (subset == null) return words;
    return words.where((w) => subset.contains(w.word)).toList();
  }

  /// Returns human-readable problems with this topic; empty means valid.
  List<String> validate() {
    final errors = <String>[];
    final seen = <String>{};
    for (final w in words) {
      if (!seen.add(w.word)) errors.add('$id: duplicate word "${w.word}"');
    }
    for (final c in [clue, ...shortClues]) {
      if (!c.contains('{word}')) errors.add('$id: clue "$c" has no {word}');
    }
    if (levels.isEmpty) errors.add('$id: has no levels');
    for (var i = 0; i < levels.length; i++) {
      final level = levels[i];
      final name = '$id level ${i + 1}';
      for (final w in level.words ?? const <String>[]) {
        if (!seen.contains(w)) errors.add('$name: unknown word "$w"');
      }
      if (level.pads < 2) errors.add('$name: needs at least 2 pads');
      if (level.rounds < 1) errors.add('$name: needs at least 1 round');
      final available = wordsForLevel(level).length;
      if (level.pads > available) {
        errors.add('$name: ${level.pads} pads but only $available words');
      }
    }
    return errors;
  }
}
