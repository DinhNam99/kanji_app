import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_app/domain/progress/progress_engine.dart';

import '../helpers.dart';

void main() {
  testWidgets('review flows through the not-learned queue', (tester) async {
    await pumpApp(tester);

    // Open review from the home CTA.
    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();
    expect(find.text('Review'), findsOneWidget); // app bar title

    // Queue is everything not learned: starts at 一.
    expect(find.text('1 / 196 to review'), findsOneWidget);
    expect(find.text('一'), findsOneWidget);

    // Reveal and assess.
    await tester.tap(find.text('一'));
    await tester.pumpAndSettle();
    expect(find.text('One'), findsOneWidget);

    await tester.tap(find.text('I Remember'));
    await tester.pumpAndSettle();
    expect(find.text('2 / 196 to review'), findsOneWidget);
    expect(find.text('二'), findsOneWidget);
  });

  testWidgets('review shows the empty state when everything is learned',
      (tester) async {
    final controller = await pumpApp(tester);

    // Learn every kanji first.
    final content = controller.content!;
    for (final char in content.allCharacters) {
      controller.progress.markSeen(char);
      controller.progress.assess(char, Assessment.remembered);
    }
    await tester.pumpAndSettle();

    // Home shows the distinct "all caught up" Review state (issue #10, P2.2).
    expect(find.text('All caught up!'), findsOneWidget);

    await tester.tap(find.text('Review'));
    await tester.pumpAndSettle();

    expect(
      find.text('Nothing to review — you have learned everything!'),
      findsOneWidget,
    );
  });
}