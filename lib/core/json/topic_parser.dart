import 'dart:convert';

import '../../domain/models/kanji.dart';
import '../../domain/models/topic.dart';
import 'kanji_parser.dart';

/// Result of parsing the curated topics file.
class TopicParseResult {
  const TopicParseResult({required this.topics, required this.warnings});

  final List<Topic> topics;
  final List<String> warnings;
}

/// Tolerant parser for `assets/topics.json`, with cross-checks against the
/// parsed kanji dataset (drops references to kanji that do not exist).
abstract final class TopicParser {
  static TopicParseResult parse(
    String rawJson,
    KanjiParseResult kanjiResult,
    Map<String, Kanji> kanjiByChar, {
    void Function(String)? log,
  }) {
    final warnings = <String>[];
    void warn(String m) {
      warnings.add(m);
      log?.call(m);
    }

    Map<String, dynamic> root;
    try {
      root = jsonDecode(rawJson) as Map<String, dynamic>;
    } catch (e) {
      throw FormatException('topics.json is not a valid JSON object: $e');
    }

    final rawTopics = root['topics'];
    if (rawTopics is! List) {
      throw const FormatException('topics.json has no "topics" list');
    }

    final topics = <Topic>[];
    final seenIds = <String>{};
    for (final raw in rawTopics) {
      if (raw is! Map<String, dynamic>) {
        warn('Skipped a non-object topic entry');
        continue;
      }
      try {
        final topic = Topic.fromJson(raw);
        if (!seenIds.add(topic.id)) {
          warn('Duplicate topic id "${topic.id}" skipped');
          continue;
        }
        final validated = validateTopic(topic, kanjiByChar, warn);
        topics.add(validated);
      } on FormatException catch (e) {
        warn('Skipped topic: ${e.message}');
      }
    }

    return TopicParseResult(topics: topics, warnings: warnings);
  }
}