import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_app/core/sound_effects.dart';

import '../helpers.dart';

/// Verifies the issue #6 wiring: reveal → appear.mp3, "I Remember" →
/// remember.mp3, on both the Learning and Review screens. The platform player
/// is replaced by [SoundEffects.debugPlayOverride], so no audio is produced.
void main() {
  late List<String> played;

  setUp(() {
    played = <String>[];
    SoundEffects.debugPlayOverride = played.add;
  });

  tearDown(() {
    // Restore the suite-wide no-op from test/flutter_test_config.dart.
    SoundEffects.debugPlayOverride = (_) {};
  });

  Future<void> startLearning(WidgetTester tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Numbers'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
  }

  testWidgets('learning: reveal plays appear, "I Remember" plays remember',
      (tester) async {
    await startLearning(tester);
    expect(played, isEmpty);

    await tester.tap(find.text('一'));
    await tester.pumpAndSettle();
    expect(played, [SoundEffects.appearSound]);

    await tester.tap(find.text('I Remember'));
    await tester.pumpAndSettle();
    expect(played, [SoundEffects.appearSound, SoundEffects.rememberSound]);
  });

  testWidgets('learning: "Review Again" plays no remember sound',
      (tester) async {
    await startLearning(tester);

    await tester.tap(find.text('一'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review Again'));
    await tester.pumpAndSettle();

    expect(played, [SoundEffects.appearSound]);
  });

  testWidgets('review: reveal plays appear, "I Remember" plays remember',
      (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('一'));
    await tester.pumpAndSettle();
    expect(played, [SoundEffects.appearSound]);

    await tester.tap(find.text('I Remember'));
    await tester.pumpAndSettle();
    expect(played, [SoundEffects.appearSound, SoundEffects.rememberSound]);
  });
}
