import 'package:flutter_test/flutter_test.dart';
import 'package:kanji_app/data/progress/progress_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('default store is empty', () async {
    final store = SharedPreferencesProgressStore();
    expect(await store.load(), isEmpty);
  });

  test('save/load round-trips non-zero states only', () async {
    final store = SharedPreferencesProgressStore();
    await store.save({'一': 2, '二': 1, '三': 0});
    final loaded = await store.load();
    // Unlearned (0) entries are dropped — absence means unlearned.
    expect(loaded, {'一': 2, '二': 1});
  });

  test('after clear the store is empty', () async {
    final store = SharedPreferencesProgressStore();
    await store.save({'一': 2});
    await store.clear();
    expect(await store.load(), isEmpty);
  });

  test('corrupted payload falls back to empty', () async {
    SharedPreferences.setMockInitialValues({
      'progress_v1': 'this is not json',
    });
    final store = SharedPreferencesProgressStore();
    expect(await store.load(), isEmpty);
  });

  test('out-of-range values are clamped to a known state', () async {
    SharedPreferences.setMockInitialValues({
      'progress_v1': '{"一": 99}',
    });
    final store = SharedPreferencesProgressStore();
    final loaded = await store.load();
    expect(loaded, {'一': 0}); // clamped to unlearned
  });
}