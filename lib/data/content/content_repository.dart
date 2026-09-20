import 'package:flutter/services.dart';

import '../../core/json/kanji_parser.dart';
import '../../core/json/topic_parser.dart';
import '../../domain/models/kanji.dart';
import '../../domain/models/topic.dart';

/// Everything the app needs from the bundled static content.
class LoadedContent {
  const LoadedContent({
    required this.kanjiByChar,
    required this.topics,
    required this.warnings,
    required this.skippedRecords,
  });

  final Map<String, Kanji> kanjiByChar;
  final List<Topic> topics;
  final List<String> warnings;
  final int skippedRecords;

  /// Every kanji currently in the curriculum (the "available" set used for
  /// overall progress).
  Set<String> get allCharacters => {
        for (final topic in topics)
          for (final entry in topic.kanji) entry.char,
      };

  Kanji? kanjiFor(String char) => kanjiByChar[char];

  Topic? topicById(String id) {
    for (final topic in topics) {
      if (topic.id == id) return topic;
    }
    return null;
  }
}

/// Loads and parses the bundled static content (`kanji.json` + `topics.json`).
class ContentRepository {
  ContentRepository({AssetBundle? bundle}) : _bundle = bundle;

  final AssetBundle? _bundle;

  AssetBundle get bundle => _bundle ?? rootBundle;

  Future<LoadedContent> load({void Function(String)? log}) async {
    final kanjiRaw = await bundle.loadString('assets/kanji.json');
    // The parsers collect warnings themselves; we only log a short summary
    // here so thousands of skipped-record messages never flood the console.
    final kanjiResult = KanjiParser.parse(kanjiRaw);

    final topicsRaw = await bundle.loadString('assets/topics.json');
    final topicResult = TopicParser.parse(
      topicsRaw,
      kanjiResult,
      kanjiResult.kanjiByChar,
    );

    if (log != null) {
      for (final w in kanjiResult.warnings.take(3)) {
        log(w);
      }
      for (final w in topicResult.warnings.take(3)) {
        log(w);
      }
      log('Content: ${kanjiResult.kanjiByChar.length} kanji loaded '
          '(${kanjiResult.skippedRecords} skipped), '
          '${topicResult.topics.length} topics '
          '(${topicResult.warnings.length} topic warnings).');
    }

    return LoadedContent(
      kanjiByChar: kanjiResult.kanjiByChar,
      topics: topicResult.topics,
      warnings: [...kanjiResult.warnings, ...topicResult.warnings],
      skippedRecords: kanjiResult.skippedRecords,
    );
  }
}