import '../models/kanji_state.dart';

/// Assessment result a user gives on a kanji card.
enum Assessment { remembered, reviewAgain }

/// Pure, side-effect-free learning-state and progress logic.
///
/// Kept free of Flutter/IO so it can be unit-tested directly.
abstract final class ProgressEngine {
  /// Whether revealing a card the first time marks it as "seen".
  /// UNLEARNED → LEARNING.
  static KanjiState markSeen(KanjiState current) =>
      current == KanjiState.unlearned ? KanjiState.learning : current;

  /// Applies a self-assessment to the current state:
  ///
  /// - remembered: UNLEARNED→LEARNING, LEARNING→LEARNED, LEARNED stays.
  /// - reviewAgain: never downgrades; LEARNING/UNLEARNED stay put.
  static KanjiState applyAssessment(KanjiState current, Assessment assessment) {
    if (assessment == Assessment.reviewAgain) return current;
    switch (current) {
      case KanjiState.unlearned:
        return KanjiState.learning;
      case KanjiState.learning:
        return KanjiState.learned;
      case KanjiState.learned:
        return KanjiState.learned;
    }
  }

  /// Progress over a specific set of characters.
  static ProgressCounts countsFor(
    Iterable<String> characters,
    Map<String, KanjiState> states,
  ) {
    var total = 0;
    var learned = 0;
    var learning = 0;
    for (final c in characters) {
      total++;
      switch (states[c] ?? KanjiState.unlearned) {
        case KanjiState.learned:
          learned++;
        case KanjiState.learning:
          learning++;
        case KanjiState.unlearned:
          break;
      }
    }
    return ProgressCounts(total: total, learned: learned, learning: learning);
  }

  /// Overall progress across all available kanji.
  static ProgressCounts overallCounts(
    Iterable<String> allCharacters,
    Map<String, KanjiState> states,
  ) =>
      countsFor(allCharacters, states);

  /// Characters that still need review, weakest first:
  /// LEARNING before UNLEARNED, stable order within a state.
  static List<String> reviewQueue(
    Iterable<String> characters,
    Map<String, KanjiState> states,
  ) {
    final learning = <String>[];
    final unlearned = <String>[];
    for (final c in characters) {
      switch (states[c] ?? KanjiState.unlearned) {
        case KanjiState.learning:
          learning.add(c);
        case KanjiState.unlearned:
          unlearned.add(c);
        case KanjiState.learned:
          break;
      }
    }
    return [...learning, ...unlearned];
  }
}