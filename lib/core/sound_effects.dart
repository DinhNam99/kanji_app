import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Short UI sound effects (GitHub issue #6).
///
/// Playback is fire-and-forget: a missing audio device or a failed decode must
/// never block the UI or crash the app, so calls return immediately and any
/// error is discarded. Sounds are bundled assets under `assets/sounds/`.
abstract final class SoundEffects {
  /// Card reveal ("Tap for reading").
  static const appearSound = 'assets/sounds/appear.mp3';

  /// Positive self-assessment ("I Remember").
  static const rememberSound = 'assets/sounds/remember.mp3';

  static final AudioPlayer _player = AudioPlayer();

  /// Plays [appearSound] when an unrevealed kanji card is tapped.
  static void playAppear() => _play(appearSound);

  /// Plays [rememberSound] when the user taps "I Remember".
  static void playRemember() => _play(rememberSound);

  /// Test seam. When set, playback is routed here instead of the platform
  /// player, which has no implementation under `flutter test`. Production
  /// leaves this null.
  @visibleForTesting
  static void Function(String asset)? debugPlayOverride;

  static void _play(String asset) {
    final override = debugPlayOverride;
    if (override != null) {
      override(asset);
      return;
    }
    // `AssetSource` resolves against AudioCache's default `assets/` prefix, so
    // the leading `assets/` is stripped from the pubspec-registered key.
    // `lowLatency` is the plugin's recommended mode for short sound effects.
    _player
        .play(
          AssetSource(asset.replaceFirst('assets/', '')),
          mode: PlayerMode.lowLatency,
        )
        .ignore();
  }
}
