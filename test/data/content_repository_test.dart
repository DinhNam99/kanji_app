import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_app/core/kana_util.dart';
import 'package:kanji_app/data/content/content_repository.dart';

/// Loads the real bundled assets. This is the ground-truth check that keeps
/// `topics.json` honest against `kanji.json`.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ContentRepository repository;

  setUpAll(() {
    repository = ContentRepository();
  });

  test('bundled kanji.json parses into a large map', () async {
    final content = await repository.load();
    expect(content.kanjiByChar.length, greaterThan(10000));
  });

  test('topics.json yields exactly the curated topics', () async {
    final content = await repository.load();
    expect(content.topics, hasLength(10));
  });

  test('every curated kanji exists in the dataset and is usable', () async {
    final content = await repository.load();
    final all = content.allCharacters;
    expect(all, hasLength(196));
    for (final char in all) {
      final kanji = content.kanjiFor(char);
      expect(kanji, isNotNull, reason: 'Missing kanji: $char');
      expect(kanji!.meanings, isNotEmpty, reason: 'No meaning: $char');
      expect(kanji.cleanedKunReadings.isNotEmpty ||
              kanji.cleanedOnReadings.isNotEmpty,
          isTrue,
          reason: 'No readable readings: $char');
    }
  });

  test('topic ids are unique and topics reference only known kanji', () async {
    final content = await repository.load();
    final ids = content.topics.map((t) => t.id).toSet();
    expect(ids, hasLength(content.topics.length));
    for (final topic in content.topics) {
      for (final entry in topic.kanji) {
        expect(content.kanjiByChar.containsKey(entry.char), isTrue,
            reason: 'Topic "${topic.id}" references missing "${entry.char}"');
      }
    }
  });

  test('every curated reading override is a real dataset reading', () async {
    final content = await repository.load();
    final bad = <String>[];
    for (final topic in content.topics) {
      for (final entry in topic.kanji) {
        final reading = entry.reading;
        if (reading == null) continue;
        final kanji = content.kanjiFor(entry.char)!;
        // Compare in normalized form: okurigana joined, markers stripped.
        final valid = <String>{
          for (final r in [...kanji.readingsKun, ...kanji.readingsOn])
            if (unifyReading(r) != null) unifyReading(r)!,
        };
        if (!valid.contains(unifyReading(reading))) {
          bad.add('${entry.char} -> $reading');
        }
      }
    }
    expect(bad, isEmpty, reason: 'Readings not in dataset: $bad');
  });
}