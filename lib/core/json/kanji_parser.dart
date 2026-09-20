import 'dart:convert';

import '../../core/kana_util.dart';
import '../../domain/models/kanji.dart';

/// Result of parsing the raw kanji dataset.
class KanjiParseResult {
  const KanjiParseResult({
    required this.kanjiByChar,
    required this.skippedRecords,
    required this.warnings,
  });

  final Map<String, Kanji> kanjiByChar;
  final int skippedRecords;
  final List<String> warnings;
}

/// Tolerant parser for `assets/kanji.json`.
///
/// A single malformed record must never crash the app: it is skipped and
/// counted. A record is considered unusable only when it has no meaning or
/// no readable reading.
abstract final class KanjiParser {
  static KanjiParseResult parse(String rawJson, {void Function(String)? log}) {
    final warnings = <String>[];
    void warn(String m) {
      warnings.add(m);
      log?.call(m);
    }

    Map<String, dynamic> root;
    try {
      root = jsonDecode(rawJson) as Map<String, dynamic>;
    } catch (e) {
      throw FormatException('kanji.json is not a valid JSON object: $e');
    }

    final kanjiByChar = <String, Kanji>{};
    var skipped = 0;
    root.forEach((char, value) {
      if (value is! Map<String, dynamic>) {
        skipped++;
        warn('Skipped "$char": record is not an object');
        return;
      }
      final kanji = Kanji.fromJson(char, value);
      final hasMeaning = kanji.meanings.isNotEmpty;
      final hasReading =
          kanji.cleanedKunReadings.isNotEmpty ||
          kanji.cleanedOnReadings.isNotEmpty ||
          (kanji.readingsOn.isNotEmpty &&
              kanji.readingsOn.every(isHiraganaReading));
      if (!hasMeaning || !hasReading) {
        skipped++;
        warn('Skipped "$char": ${hasMeaning ? 'no reading' : 'no meaning'}');
        return;
      }
      kanjiByChar[char] = kanji;
    });

    return KanjiParseResult(
      kanjiByChar: kanjiByChar,
      skippedRecords: skipped,
      warnings: warnings,
    );
  }
}