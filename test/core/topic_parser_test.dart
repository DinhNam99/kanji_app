import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_app/core/json/kanji_parser.dart';
import 'package:kanji_app/core/json/topic_parser.dart';

const kanjiJson = '''
{
  "一": {"strokes": 1, "meanings": ["One"], "readings_on": ["いち"], "readings_kun": ["ひと-"]},
  "二": {"strokes": 2, "meanings": ["Two"], "readings_on": ["に"], "readings_kun": ["ふた"]},
  "日": {"strokes": 4, "meanings": ["Day"], "readings_on": ["にち"], "readings_kun": ["ひ"]}
}
''';

KanjiParseResult kanjiResult() => KanjiParser.parse(kanjiJson);

void main() {
  group('TopicParser', () {
    test('parses topics and keeps usable kanji', () {
      const topics = '''
        {
          "topics": [
            {"id": "n", "name": "Numbers", "description": "d",
             "kanji": [{"char": "一"}, {"char": "二"}]}
          ]
        }
      ''';
      final result = TopicParser.parse(topics, kanjiResult(), kanjiResult().kanjiByChar);
      expect(result.topics, hasLength(1));
      expect(result.topics.first.kanji, hasLength(2));
      expect(result.topics.first.name, 'Numbers');
    });

    test('drops references to kanji missing from the dataset', () {
      const topics = '''
        {
          "topics": [
            {"id": "t", "name": "T", "kanji": [{"char": "一"}, {"char": "羅"}]}
          ]
        }
      ''';
      final result = TopicParser.parse(topics, kanjiResult(), kanjiResult().kanjiByChar);
      expect(result.topics.first.kanji.map((e) => e.char), ['一']);
    });

    test('skips duplicate topic ids', () {
      const topics = '''
        {
          "topics": [
            {"id": "a", "name": "A", "kanji": [{"char": "一"}]},
            {"id": "a", "name": "A2", "kanji": [{"char": "二"}]}
          ]
        }
      ''';
      final result = TopicParser.parse(topics, kanjiResult(), kanjiResult().kanjiByChar);
      expect(result.topics, hasLength(1));
    });

    test('throws when there is no topics list', () {
      expect(
        () => TopicParser.parse('{"other": 1}', kanjiResult(), kanjiResult().kanjiByChar),
        throwsFormatException,
      );
    });

    test('warns when a curated reading is not in the dataset', () {
      const topics = '''
        {
          "topics": [
            {"id": "t", "name": "T", "kanji": [{"char": "一", "reading": "にち"}]}
          ]
        }
      ''';
      final warnings = <String>[];
      TopicParser.parse(
        topics,
        kanjiResult(),
        kanjiResult().kanjiByChar,
        log: warnings.add,
      );
      expect(
        warnings.any((w) => w.contains('reading') && w.contains('にち')),
        isTrue,
      );
    });

    test('accepts a curated reading that exists in the dataset', () {
      const topics = '''
        {
          "topics": [
            {"id": "t", "name": "T", "kanji": [{"char": "一", "reading": "いち"}]}
          ]
        }
      ''';
      final warnings = <String>[];
      final result = TopicParser.parse(
        topics,
        kanjiResult(),
        kanjiResult().kanjiByChar,
        log: warnings.add,
      );
      expect(
        warnings.any((w) => w.contains('reading')),
        isFalse,
      );
      expect(result.topics.first.kanji.first.reading, 'いち');
    });
  });
}