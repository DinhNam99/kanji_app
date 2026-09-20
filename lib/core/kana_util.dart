/// Hiragana and reading helpers shared by parsers, validators and UI.
///
/// Readings in `kanji.json` follow the standard `kanji-data` conventions:
/// - a trailing `-` marks the okurigana boundary (`ひと-` → `ひと`)
/// - a `.` separates the base reading from okurigana (`ひと.つ` → `ひと`)
/// - a leading `-` means the reading only occurs in compounds (`-び`) → skipped
/// - a leading `!` (WaniKani data) marks "not used in words" → skipped
library;

/// True for a string of hiragana (incl. the long-vowel mark / iteration marks).
bool isHiraganaReading(String s) {
  if (s.isEmpty) return false;
  final code = RegExp(r'^[ぁ-ゟー]+$');
  return code.hasMatch(s);
}

/// Normalises a raw dataset reading for display and validation:
/// strips markers, splits off okurigana, returns null for compound-only forms.
String? cleanReading(String raw) {
  var s = raw;
  if (s.startsWith('!') || s.startsWith('*')) s = s.substring(1);
  if (s.startsWith('-')) return null; // compound-only reading (e.g. -び)
  if (s.endsWith('-')) s = s.substring(0, s.length - 1);
  // ひと.つ → ひと (base reading only); keep okurigana removed.
  s = s.split('.').first;
  return s.isEmpty ? null : s;
}

/// Same as [cleanReading] but keeps okurigana for word-formed readings
/// (`た.べる` → `たべる`). Used only for curated override verification.
String? unifyReading(String raw) {
  var s = raw;
  if (s.startsWith('!') || s.startsWith('*')) s = s.substring(1);
  if (s.startsWith('-')) return null;
  if (s.endsWith('-')) s = s.substring(0, s.length - 1);
  s = s.replaceAll('.', '');
  return s.isEmpty ? null : s;
}