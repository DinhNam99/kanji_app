import 'dart:async';

import 'package:kanji_app/core/sound_effects.dart';

/// Suite-wide setup, run before every test file's `main`.
///
/// The audioplayers plugin has no platform implementation under `flutter test`,
/// so route sound effects to a no-op by default. Tests that assert sound
/// wiring install their own [SoundEffects.debugPlayOverride].
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  SoundEffects.debugPlayOverride = (_) {};
  await testMain();
}
