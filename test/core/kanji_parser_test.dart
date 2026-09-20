import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_app/core/json/kanji_parser.dart';

const validRecord = '''
{
  "一": {
    "strokes": 1,
    "grade": 1,
    "freq": 2,
    "jlpt_old": 4,
    "jlpt_new": 5,
    "meanings": ["One", "One Radical (no.1)"],
    "readings_on": ["いち", "いつ"],
    "readings_kun": ["ひと-", "ひと.つ"]
  }
}
''';

void main() {
  group('KanjiParser', () {
    test('parses a valid record with markers intact', () {
      final result = KanjiParser.parse(validRecord);
      expect(result.skippedRecords, 0);
      final kanji = result.kanjiByChar['一'];
      expect(kanji, isNotNull);
      expect(kanji!.character, '一');
      expect(kanji.grade, 1);
      expect(kanji.jlptNew, 5);
      expect(kanji.meanings.first, 'One');
      expect(kanji.cleanedKunReadings, ['ひと', 'ひと']);
    });

    test('skips a record with no meaning', () {
      const raw = '{"日": {"strokes": 4, "readings_on": ["にち"]}}';
      final result = KanjiParser.parse(raw);
      expect(result.skippedRecords, 1);
      expect(result.kanjiByChar, isEmpty);
    });

    test('skips a record with no readable reading', () {
      const raw = '{"日": {"strokes": 4, "meanings": ["Day"]}}';
      final result = KanjiParser.parse(raw);
      expect(result.skippedRecords, 1);
      expect(result.kanjiByChar, isEmpty);
    });

    test('skips a record that is not an object', () {
      const raw = '{"日": "not-an-object"}';
      final result = KanjiParser.parse(raw);
      expect(result.skippedRecords, 1);
    });

    test('skipping one record does not kill the rest', () {
      const raw = '''
        {
          "日": "bad",
          "月": {"strokes": 4, "meanings": ["Moon"], "readings_on": ["げつ"]}
        }
      ''';
      final result = KanjiParser.parse(raw);
      expect(result.skippedRecords, 1);
      expect(result.kanjiByChar.containsKey('月'), isTrue);
    });

    test('throws FormatException on non-JSON', () {
      expect(() => KanjiParser.parse('not json'), throwsFormatException);
    });
  });
}