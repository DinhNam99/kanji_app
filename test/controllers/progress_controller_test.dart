import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_app/controllers/progress_controller.dart';
import 'package:kanji_app/data/progress/progress_store.dart';
import 'package:kanji_app/domain/models/kanji_state.dart';
import 'package:kanji_app/domain/models/topic.dart';
import 'package:kanji_app/domain/progress/progress_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

Topic _topic(List<String> chars) => Topic(
      id: 't',
      name: 'T',
      description: 'd',
      kanji: [for (final c in chars) TopicKanji(char: c)],
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  ProgressController controller() =>
      ProgressController(store: SharedPreferencesProgressStore());

  test('init prunes entries not in the curriculum', () async {
    SharedPreferences.setMockInitialValues({
      'progress_v1': '{"一": 2, "鬼": 2}',
    });
    final c = controller();
    await c.init({'一', '二'});
    expect(c.stateOf('一'), KanjiState.learned);
    expect(c.stateOf('鬼'), KanjiState.unlearned);
  });

  test('markSeen moves UNLEARNED to LEARNING and notifies', () async {
    final c = controller();
    await c.init({'一'});
    var notified = 0;
    c.addListener(() => notified++);
    c.markSeen('一');
    expect(c.stateOf('一'), KanjiState.learning);
    expect(notified, 1);
    // Marking again is a no-op.
    c.markSeen('一');
    expect(notified, 1);
  });

  test('assess moves LEARNING to LEARNED on remembered', () async {
    final c = controller();
    await c.init({'一'});
    c.markSeen('一');
    c.assess('一', Assessment.remembered);
    expect(c.stateOf('一'), KanjiState.learned);
  });

  test('assess reviewAgain keeps the state', () async {
    final c = controller();
    await c.init({'一'});
    c.markSeen('一');
    c.assess('一', Assessment.reviewAgain);
    expect(c.stateOf('一'), KanjiState.learning);
  });

  test('topicCounts and overallCounts reflect state', () async {
    final c = controller();
    await c.init({'一', '二', '三'});
    c.markSeen('一');
    c.assess('一', Assessment.remembered);
    c.markSeen('二');
    final topicCounts = c.topicCounts(_topic(['一', '二', '三']));
    expect(topicCounts.learned, 1);
    expect(topicCounts.learning, 1);
    final overall = c.overallCounts({'一', '二', '三'});
    expect(overall.learned, 1);
    expect(overall.fraction, closeTo(1 / 3, 1e-9));
  });

  test('reviewQueue orders LEARNING before UNLEARNED', () async {
    final c = controller();
    await c.init({'一', '二', '三'});
    c.markSeen('一'); // learning
    final queue = c.reviewQueue({'一', '二', '三'});
    expect(queue.first, '一');
    expect(queue.toSet(), {'一', '二', '三'});
  });

  test('reset clears state and persists', () async {
    final c = controller();
    await c.init({'一'});
    c.markSeen('一');
    c.assess('一', Assessment.remembered);
    await c.reset();
    expect(c.stateOf('一'), KanjiState.unlearned);

    // Persisted value is gone too.
    final store = SharedPreferencesProgressStore();
    expect(await store.load(), isEmpty);
  });
}