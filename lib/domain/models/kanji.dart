import 'package:flutter/foundation.dart';

import '../../core/kana_util.dart';

/// One kanji record from `assets/kanji.json`.
///
/// Fields mirror the source schema exactly; null-able fields (`grade`,
/// `freq`, `jlpt_*`, `wk_*`) are null for large portions of the dataset.
@immutable
class Kanji {
  const Kanji({
    required this.character,
    required this.strokes,
    required this.meanings,
    required this.readingsOn,
    required this.readingsKun,
    this.grade,
    this.freq,
    this.jlptOld,
    this.jlptNew,
    this.wkLevel,
    this.wkMeanings = const [],
    this.wkReadingsOn = const [],
    this.wkReadingsKun = const [],
    this.wkRadicals = const [],
  });

  final String character;
  final int strokes;
  final int? grade;
  final int? freq;
  final int? jlptOld;
  final int? jlptNew;
  final List<String> meanings;
  final List<String> readingsOn;
  final List<String> readingsKun;
  final int? wkLevel;
  final List<String> wkMeanings;
  final List<String> wkReadingsOn;
  final List<String> wkReadingsKun;
  final List<String> wkRadicals;

  /// Primary English gloss (first meaning; may contain dataset noise like
  /// "One Radical (no.1)"). Null only for records that failed validation.
  String? get primaryMeaning => meanings.isEmpty ? null : meanings.first;

  /// Kun readings cleaned for display (okurigana stripped, compound-only
  /// forms filtered).
  List<String> get cleanedKunReadings =>
      readingsKun.map(cleanReading).whereType<String>().toList();

  /// On readings cleaned for display.
  List<String> get cleanedOnReadings =>
      readingsOn.map(cleanReading).whereType<String>().toList();

  /// Default display reading: first usable kun reading, else first on
  /// reading, else the last resort: any raw reading that cleans.
  String? get defaultReading {
    final kun = cleanedKunReadings;
    if (kun.isNotEmpty) return kun.first;
    final on = cleanedOnReadings;
    if (on.isNotEmpty) return on.first;
    return null;
  }

  factory Kanji.fromJson(String character, Map<String, dynamic> json) {
    int asInt(Object? value) => value is num ? value.toInt() : 0;
    List<String> asStrings(Object? value) =>
        value is List ? value.whereType<String>().toList() : const [];

    return Kanji(
      character: character,
      strokes: asInt(json['strokes']),
      grade: _nullableInt(json['grade']),
      freq: _nullableInt(json['freq']),
      jlptOld: _nullableInt(json['jlpt_old']),
      jlptNew: _nullableInt(json['jlpt_new']),
      meanings: asStrings(json['meanings']),
      readingsOn: asStrings(json['readings_on']),
      readingsKun: asStrings(json['readings_kun']),
      wkLevel: _nullableInt(json['wk_level']),
      wkMeanings: asStrings(json['wk_meanings']),
      wkReadingsOn: asStrings(json['wk_readings_on']),
      wkReadingsKun: asStrings(json['wk_readings_kun']),
      wkRadicals: asStrings(json['wk_radicals']),
    );
  }

  static int? _nullableInt(Object? value) => value is num ? value.toInt() : null;
}