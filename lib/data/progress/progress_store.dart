import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/kanji_state.dart';

/// Persistence boundary for user progress.
///
/// Implementations must survive app restarts. Content (`kanji.json`) is
/// never written here — user state is strictly separate.
abstract interface class ProgressStore {
  Future<Map<String, int>> load();
  Future<void> save(Map<String, int> state);
  Future<void> clear();
}

/// SharedPreferences-backed store.
///
/// The state is a single JSON-encoded map of character → state int. Only
/// entries whose state differs from the default (UNLEARNED) are stored, so
/// the payload stays tiny for the ~200-member curriculum.
class SharedPreferencesProgressStore implements ProgressStore {
  SharedPreferencesProgressStore({this.key = 'progress_v1'});

  final String key;

  @override
  Future<Map<String, int>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return <String, int>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return <String, int>{};
      final result = <String, int>{};
      decoded.forEach((char, value) {
        if (value is num) {
          result[char] = KanjiState.fromValue(value.toInt()).value;
        }
      });
      return result;
    } on FormatException {
      // Corrupted data: fall back to an empty store rather than crashing.
      return <String, int>{};
    }
  }

  @override
  Future<void> save(Map<String, int> state) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(_minimal(state)));
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  /// Drops UNLEARNED (0) entries — absence means unlearned.
  Map<String, int> _minimal(Map<String, int> state) => {
        for (final entry in state.entries)
          if (entry.value != KanjiState.unlearned.value) entry.key: entry.value,
      };
}