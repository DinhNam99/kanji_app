import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_app/domain/progress/progress_engine.dart';
import 'package:kanji_app/domain/models/kanji_state.dart';

void main() {
  group('markSeen', () {
    test('UNLEARNED -> LEARNING on first reveal', () {
      expect(
        ProgressEngine.markSeen(KanjiState.unlearned),
        KanjiState.learning,
      );
    });

    test('is idempotent for learning/learned', () {
      expect(ProgressEngine.markSeen(KanjiState.learning), KanjiState.learning);
      expect(ProgressEngine.markSeen(KanjiState.learned), KanjiState.learned);
    });
  });

  group('applyAssessment', () {
    test('remembered progresses', () {
      expect(
        ProgressEngine.applyAssessment(KanjiState.unlearned, Assessment.remembered),
        KanjiState.learning,
      );
      expect(
        ProgressEngine.applyAssessment(KanjiState.learning, Assessment.remembered),
        KanjiState.learned,
      );
      expect(
        ProgressEngine.applyAssessment(KanjiState.learned, Assessment.remembered),
        KanjiState.learned,
      );
    });

    test('reviewAgain never downgrades', () {
      expect(
        ProgressEngine.applyAssessment(KanjiState.unlearned, Assessment.reviewAgain),
        KanjiState.unlearned,
      );
      expect(
        ProgressEngine.applyAssessment(KanjiState.learning, Assessment.reviewAgain),
        KanjiState.learning,
      );
      expect(
        ProgressEngine.applyAssessment(KanjiState.learned, Assessment.reviewAgain),
        KanjiState.learned,
      );
    });
  });

  group('countsFor', () {
    test('counts learned/learning across characters', () {
      final states = <String, KanjiState>{
        '一': KanjiState.learned,
        '二': KanjiState.learning,
      };
      final counts = ProgressEngine.countsFor(['一', '二', '三'], states);
      expect(counts.total, 3);
      expect(counts.learned, 1);
      expect(counts.learning, 1);
      expect(counts.fraction, closeTo(1 / 3, 1e-9));
    });

    test('empty set has zero fraction, no division by zero', () {
      final counts = ProgressEngine.countsFor([], <String, KanjiState>{});
      expect(counts.total, 0);
      expect(counts.fraction, 0);
      expect(counts.isEmpty, isTrue);
    });

    test('missing states count as unlearned', () {
      final counts = ProgressEngine.countsFor(['日'], <String, KanjiState>{});
      expect(counts.learned, 0);
      expect(counts.learning, 0);
    });
  });

  group('reviewQueue', () {
    test('orders LEARNING before UNLEARNED and excludes LEARNED', () {
      final states = <String, KanjiState>{
        'a1': KanjiState.learned,
        'a2': KanjiState.learning,
        'a3': KanjiState.unlearned,
        'a4': KanjiState.learning,
      };
      final queue = ProgressEngine.reviewQueue(['a1', 'a2', 'a3', 'a4'], states);
      expect(queue, ['a2', 'a4', 'a3']);
    });

    test('empty when everything is learned', () {
      final queue = ProgressEngine.reviewQueue(
        ['a'],
        {'a': KanjiState.learned},
      );
      expect(queue, isEmpty);
    });
  });
}