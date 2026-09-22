import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_app/app.dart';
import 'package:kanji_app/domain/progress/progress_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers.dart';

void main() {
  testWidgets('learning a kanji advances the card and persists across restarts',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final controller = (await tester.runAsync(createLoadedController))!;
    await tester.pumpWidget(KanjiApp(controller: controller));
    await tester.pumpAndSettle();

    // Home → topic detail.
    await tester.tap(find.text('Numbers'));
    await tester.pumpAndSettle();
    expect(find.text('Start'), findsOneWidget);

    // Start the learning session.
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    expect(find.text('Numbers · 1/14'), findsOneWidget);
    expect(find.text('一'), findsOneWidget);

    // Reveal the card.
    await tester.tap(find.text('一'));
    await tester.pumpAndSettle();
    expect(find.text('One'), findsOneWidget); // meaning revealed

    // Self-assess "I Remember" → advances to card 2.
    await tester.tap(find.text('I Remember'));
    await tester.pumpAndSettle();
    expect(find.text('Numbers · 2/14'), findsOneWidget);
    expect(find.text('二'), findsOneWidget);

    // Leave mid-session with confirmation.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Leave session?'), findsOneWidget);
    await tester.tap(find.text('Leave'));
    await tester.pumpAndSettle();

    // Back on the topic detail: 1 of 14 learned.
    expect(find.text('Learned'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);

    // Simulate an app restart with a fresh controller: progress must have
    // been persisted to SharedPreferences. A new Key forces a fresh
    // Navigator/route stack (standard pumpWidget reuses the element tree).
    final restarted = (await tester.runAsync(createLoadedController))!;
    await tester.pumpWidget(
      KanjiApp(key: UniqueKey(), controller: restarted),
    );
    await tester.pumpAndSettle();
    expect(find.text('1 of 196 kanji learned'), findsOneWidget);
  });

  testWidgets('reset from settings clears progress', (tester) async {
    final controller = await pumpApp(tester);

    // Mark one kanji as learned before visiting settings.
    final content = controller.content!;
    controller.progress.markSeen(content.allCharacters.first);
    controller.progress
        .assess(content.allCharacters.first, Assessment.remembered);
    await tester.pumpAndSettle();
    expect(find.text('1 of 196 kanji learned'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset all progress'));
    await tester.pumpAndSettle();
    expect(find.text('Reset all progress?'), findsOneWidget);
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();

    // Back on home, progress is cleared.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('0 of 196 kanji learned'), findsOneWidget);
    expect(find.text('Progress reset.'), findsOneWidget);

    // Developer-facing dataset diagnostics no longer live on Home (issue #10).
    expect(find.textContaining('kanji records were skipped'), findsNothing);
  });
}