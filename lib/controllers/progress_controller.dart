import 'package:flutter/foundation.dart';

import '../data/progress/progress_store.dart';
import '../domain/models/kanji_state.dart';
import '../domain/models/topic.dart';
import '../domain/progress/progress_engine.dart';

/// Holds the in-memory user progress state and persists it.
///
/// ChangeNotifier so screens can rebuild on any write.
class ProgressController extends ChangeNotifier {
  ProgressController({required ProgressStore store}) : _store = store;

  final ProgressStore _store;

  Map<String, KanjiState> _states = {};
  bool _initialized = false;

  bool get isInitialized => _initialized;

  /// Loads persistent state and prunes entries for kanji no longer in the
  /// curriculum (removed from JSON).
  Future<void> init(Set<String> allCharacters) async {
    final raw = await _store.load();
    final states = <String, KanjiState>{
      for (final entry in raw.entries)
        if (allCharacters.contains(entry.key))
          entry.key: KanjiState.fromValue(entry.value),
    };
    _states = states;
    _initialized = true;
    notifyListeners();
  }

  KanjiState stateOf(String character) =>
      _states[character] ?? KanjiState.unlearned;

  /// Auto-stamp on first reveal: UNLEARNED → LEARNING.
  void markSeen(String character) {
    final next = ProgressEngine.markSeen(stateOf(character));
    if (next == stateOf(character)) return;
    _states[character] = next;
    notifyListeners();
    _persist();
  }

  /// Applies a self-assessment (I Remember / Review Again).
  void assess(String character, Assessment assessment) {
    final next = ProgressEngine.applyAssessment(stateOf(character), assessment);
    if (next == stateOf(character)) return;
    _states[character] = next;
    notifyListeners();
    _persist();
  }

  /// Clears all user progress. Static content is untouched.
  Future<void> reset() async {
    _states.clear();
    await _store.clear();
    notifyListeners();
  }

  ProgressCounts topicCounts(Topic topic) => ProgressEngine.countsFor(
        topic.kanji.map((e) => e.char),
        _states,
      );

  ProgressCounts overallCounts(Set<String> allCharacters) =>
      ProgressEngine.overallCounts(allCharacters, _states);

  List<String> reviewQueue(Set<String> allCharacters) =>
      ProgressEngine.reviewQueue(allCharacters, _states);

  /// Characters for a topic that still need work, in topic order.
  List<String> topicReviewQueue(Topic topic) =>
      ProgressEngine.reviewQueue(topic.kanji.map((e) => e.char), _states);

  void _persist() {
    final snapshot = <String, int>{
      for (final entry in _states.entries)
        if (entry.value != KanjiState.unlearned) entry.key: entry.value.value,
    };
    // Fire-and-forget; the in-memory state is already authoritative for UI.
    _store.save(snapshot).ignore();
  }
}