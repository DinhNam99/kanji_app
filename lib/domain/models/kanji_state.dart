import 'package:flutter/foundation.dart';

/// Learning state of a single kanji.
///
/// Stored as an int (0/1/2) so the progress map stays compact in JSON.
enum KanjiState {
  unlearned(0),
  learning(1),
  learned(2);

  const KanjiState(this.value);

  final int value;

  static KanjiState fromValue(int value) {
    switch (value) {
      case 1:
        return KanjiState.learning;
      case 2:
        return KanjiState.learned;
      default:
        return KanjiState.unlearned;
    }
  }

  String get label => switch (this) {
        KanjiState.unlearned => 'New',
        KanjiState.learning => 'Learning',
        KanjiState.learned => 'Learned',
      };
}

/// Serializable summary of progress over a set of kanji.
@immutable
class ProgressCounts {
  const ProgressCounts({required this.total, required this.learned, required this.learning});

  /// Total kanji in scope (denominator).
  final int total;

  /// Kanji marked [KanjiState.learned].
  final int learned;

  /// Kanji in [KanjiState.learning] (seen but not yet learned).
  final int learning;

  /// `learned/total`, 0.0 when total is 0 to avoid division by zero.
  double get fraction => total == 0 ? 0.0 : learned / total;

  bool get isEmpty => total == 0;
}