import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_app/domain/progress/progress_engine.dart';

import '../helpers.dart';

/// TopicCard behavior on Home (issue #10): single semantic node, in-progress
/// count, completion badge.
void main() {
  testWidgets('topic card is one button semantic node with name and progress',
      (tester) async {
    final semantics = tester.ensureSemantics();

    await pumpApp(tester);

    final label = find.bySemanticsLabel('Numbers, 0 of 14 learned');
    expect(label, findsOneWidget);
    expect(
      tester.getSemantics(label).hasFlag(SemanticsFlag.isButton),
      isTrue,
    );
    // Dispose inside the test body: Flutter's end-of-test semantics check runs
    // before package:test's addTearDown callbacks.
    semantics.dispose();
  });

  testWidgets('shows in-progress count and completion badge', (tester) async {
    final controller = await pumpApp(tester);
    final topic = controller.content!.topics.first;

    controller.progress.markSeen(topic.kanji.first.char);
    await tester.pumpAndSettle();
    // On the card only — the overview line reads "… in progress · … not
    // started", a different full string.
    expect(find.text('1 in progress'), findsOneWidget);

    for (final entry in topic.kanji) {
      controller.progress.markSeen(entry.char);
      controller.progress.assess(entry.char, Assessment.remembered);
    }
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.text('14/14'), findsOneWidget);
  });
}
