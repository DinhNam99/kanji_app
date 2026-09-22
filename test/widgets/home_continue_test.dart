import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_app/domain/progress/progress_engine.dart';

import '../helpers.dart';

/// Home "Continue" CTA (issue #10, P2.1): resumes the first topic with
/// unlearned kanji, lands on the first not-yet-learned card, and disappears
/// once everything has been seen.
void main() {
  testWidgets('Continue opens the first topic with unlearned kanji',
      (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Numbers · 1/14'), findsOneWidget);
    expect(find.text('一'), findsOneWidget);
  });

  testWidgets('Continue resumes mid-topic at the first unlearned card',
      (tester) async {
    final controller = await pumpApp(tester);
    final topic = controller.content!.topics.first;
    for (final entry in topic.kanji.take(3)) {
      controller.progress.markSeen(entry.char);
      controller.progress.assess(entry.char, Assessment.remembered);
    }
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Numbers · 4/14'), findsOneWidget);
    // The card shown is the first one that isn't learned yet.
    expect(find.text(topic.kanji[3].char), findsOneWidget);
  });

  testWidgets('Continue hides once every topic has been seen', (tester) async {
    final controller = await pumpApp(tester);
    for (final topic in controller.content!.topics) {
      for (final entry in topic.kanji) {
        controller.progress.markSeen(entry.char);
      }
    }
    await tester.pumpAndSettle();

    expect(find.text('Continue'), findsNothing);
  });
}
