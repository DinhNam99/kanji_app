import 'package:flutter/foundation.dart';

import '../../core/kana_util.dart';
import 'kanji.dart';

/// A single kanji entry inside a [Topic].
///
/// [`char`] must exist in the static kanji dataset. [`reading`] is the
/// curated display reading (usually a beginner-appropriate reading chosen
/// from the dataset's on/kun readings); when absent the app falls back to
/// [Kanji.defaultReading].
@immutable
class TopicKanji {
  const TopicKanji({required this.char, this.reading});

  final String char;
  final String? reading;

  factory TopicKanji.fromJson(Map<String, dynamic> json) {
    final char = json['char'];
    if (char is! String || char.isEmpty) {
      throw const FormatException('Topic kanji entry missing "char"');
    }
    final reading = json['reading'];
    return TopicKanji(
      char: char,
      reading: reading is String && reading.isNotEmpty ? reading : null,
    );
  }

  /// Display reading for this kanji in this topic context.
  String? readingFor(Kanji kanji) => reading ?? kanji.defaultReading;
}

/// A curated group of kanji (from `assets/topics.json`).
@immutable
class Topic {
  const Topic({
    required this.id,
    required this.name,
    required this.description,
    required this.kanji,
  });

  final String id;
  final String name;
  final String description;
  final List<TopicKanji> kanji;

  factory Topic.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final description = json['description'];
    final rawKanji = json['kanji'];
    if (id is! String || id.isEmpty) {
      throw const FormatException('Topic missing "id"');
    }
    if (name is! String || name.isEmpty) {
      throw FormatException('Topic "$id" missing "name"');
    }
    if (rawKanji is! List || rawKanji.isEmpty) {
      throw FormatException('Topic "$id" has no kanji');
    }

    final items = <TopicKanji>[];
    for (final raw in rawKanji) {
      if (raw is Map<String, dynamic>) {
        try {
          items.add(TopicKanji.fromJson(raw));
        } on FormatException {
          // Skip malformed entries; keep the rest of the topic.
          continue;
        }
      }
    }
    if (items.isEmpty) {
      throw const FormatException('Topic has no usable kanji');
    }
    return Topic(
      id: id,
      name: name,
      description: description is String ? description : '',
      kanji: items,
    );
  }
}

/// Validates that a topic's kanji are well-formed and reference existing
/// kanji. Returns the filtered topic plus a list of warnings.
Topic validateTopic(Topic topic, Map<String, Kanji> kanjiByChar,
    void Function(String warning) log) {
  final seen = <String>{};
  final items = <TopicKanji>[];
  for (final entry in topic.kanji) {
    if (!seen.add(entry.char)) {
      log('Topic "${topic.id}": duplicate kanji "${entry.char}" skipped');
      continue;
    }
    final kanji = kanjiByChar[entry.char];
    if (kanji == null) {
      log('Topic "${topic.id}": kanji "${entry.char}" not in dataset, skipped');
      continue;
    }
    if (entry.reading != null) {
      final known = <String>{
        for (final r in [...kanji.readingsKun, ...kanji.readingsOn])
          if (unifyReading(r) != null) unifyReading(r)!,
      };
      final clean = unifyReading(entry.reading!);
      if (clean == null || !known.contains(clean)) {
        log('Topic "${topic.id}": reading "${entry.reading}" for "${entry.char}" '
            'not found among dataset readings');
      }
    }
    items.add(entry);
  }
  return Topic(
    id: topic.id,
    name: topic.name,
    description: topic.description,
    kanji: items,
  );
}