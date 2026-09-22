import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  testWidgets('home renders title, overall progress and all topics',
      (tester) async {
    await pumpApp(tester);

    expect(find.text('Kanji Beginner'), findsOneWidget);
    expect(find.text('0 of 196 kanji learned'), findsOneWidget);
    expect(find.text('Overall Progress'), findsOneWidget);
    expect(find.text('0 in progress · 196 not started'), findsOneWidget);

    // Primary CTA resumes the first topic with unlearned kanji.
    expect(find.text('Continue'), findsOneWidget);

    // Review CTA says nothing to review yet (top card, visible now).
    expect(find.text('196 kanji to review'), findsOneWidget);

    // The topic list is a lazy ListView, so scroll each topic into view
    // before asserting it exists.
    final scrollable = find.byType(Scrollable).first;
    for (final name in [
      'Numbers',
      'Time',
      'Nature & Weather',
      'People & Family',
      'Places & Home',
      'School & Study',
      'Daily Life',
      'Body & Feelings',
      'Directions & Position',
      'Other Basic Kanji',
    ]) {
      await tester.scrollUntilVisible(find.text(name), 200,
          scrollable: scrollable);
      expect(find.text(name), findsOneWidget, reason: 'Missing topic $name');
    }
  });

  testWidgets('progress screen shows per-topic breakdown', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.insights_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('By topic'), findsOneWidget);
    expect(find.text('0 of 196 kanji learned'), findsOneWidget);
  });

  testWidgets('settings screen exposes reset', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Reset all progress'), findsOneWidget);

    // Dataset diagnostics moved here from Home (issue #10, P1.4).
    expect(find.text('Diagnostics'), findsOneWidget);
    expect(find.textContaining('kanji records were skipped'), findsOneWidget);
  });
}