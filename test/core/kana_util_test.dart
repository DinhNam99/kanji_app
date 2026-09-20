import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_app/core/kana_util.dart';

void main() {
  group('cleanReading', () {
    test('strips okurigana boundary marker', () {
      expect(cleanReading('ひと-'), 'ひと');
    });

    test('splits base reading off okurigana', () {
      expect(cleanReading('ひと.つ'), 'ひと');
      expect(cleanReading('おお.きい'), 'おお');
    });

    test('drops compound-only readings', () {
      expect(cleanReading('-び'), isNull);
      expect(cleanReading('-うえ'), isNull);
    });

    test('drops WaniKani "not in words" marker', () {
      expect(cleanReading('!ひと'), 'ひと');
    });

    test('passes plain readings through', () {
      expect(cleanReading('やま'), 'やま');
      expect(cleanReading('いち'), 'いち');
    });

    test('returns null for empty input', () {
      expect(cleanReading(''), isNull);
    });
  });

  group('unifyReading', () {
    test('keeps okurigana for word-formed readings', () {
      expect(unifyReading('た.べる'), 'たべる');
      expect(unifyReading('あたら.しい'), 'あたらしい');
    });

    test('matches plain readings', () {
      expect(unifyReading('えん'), 'えん');
    });
  });

  group('isHiraganaReading', () {
    test('accepts hiragana', () {
      expect(isHiraganaReading('ひ'), isTrue);
      expect(isHiraganaReading('こんにちは'), isTrue);
      expect(isHiraganaReading('しゅう'), isTrue); // long-vowel mark
    });

    test('rejects non-hiragana', () {
      expect(isHiraganaReading('kanji'), isFalse);
      expect(isHiraganaReading(''), isFalse);
      expect(isHiraganaReading('一'), isFalse);
    });
  });
}