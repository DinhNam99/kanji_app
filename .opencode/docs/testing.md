# Testing

> Full suite: `flutter test` (~56 tests, ~5s). The suite loads the **real bundled assets and real SharedPreferences** — no fake repositories, no mock store. This doc explains why that matters and the patterns that keep it green.

## Two kinds of tests

| Kind | What they touch | Typical files |
|---|---|---|
| Pure unit | `ProgressEngine`, parsers, `kana_util`, models — no widget tree | `test/domain/progress_engine_test.dart`, `test/core/kana_util_test.dart`, `test/core/kanji_parser_test.dart`, `test/core/topic_parser_test.dart` |
| Widget | Full app flows with real assets + real prefs | `test/widgets/*_test.dart`, `test/theme_test.dart` |
| Boundaries | Store round-trips, content-repo integrity | `test/data/progress_store_test.dart`, `test/data/content_repository_test.dart` |

Focused runs:

```sh
flutter test test/domain/progress_engine_test.dart        # engine only
flutter test test/data/content_repository_test.dart        # curriculum integrity (run before committing topics.json changes)
flutter test test/widgets/app_flow_test.dart               # one widget area
```

## The golden rule: real async must run in `tester.runAsync`

Asset loading (`rootBundle`) and `SharedPreferences.getInstance()` are **real async** operations. Inside a `testWidgets` body, they only complete inside `tester.runAsync(...)`; otherwise the test hangs or times out. Always follow with `pumpAndSettle()`.

## Helpers — `test/helpers.dart`

```dart
Future<AppController> pumpApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});               // required before any prefs access
  final controller = (await tester.runAsync(createLoadedController))!;
  await tester.pumpWidget(KanjiApp(controller: controller));
  await tester.pumpAndSettle();
  return controller;
}
```

- `createLoadedController()` — builds `AppController` with **real** `ContentRepository()` + `SharedPreferencesProgressStore()` and awaits `load()`.
- `pumpApp(tester)` — seeds empty prefs, loads the controller inside `runAsync`, pumps the real app, settles. Returns the controller for asserting state.
- `SharedPreferences.setMockInitialValues({})` is mandatory before any prefs read — it's already inside `pumpApp`, but add it to tests that touch prefs directly.

## Fire-and-forget persistence

`ProgressController._persist()` writes with `_store.save(snapshot).ignore()` — the store write is unawaited and not joined to the frame. In tests that means:

- In-memory state is authoritative: assert on `controller.progress.stateOf(...)`, not on prefs.
- After `assess(...)`/`markSeen(...)`/`reset()`, `await tester.pumpAndSettle()` (or run inside `runAsync`) before asserting on persisted round-trips — the async write needs the event loop to drain.

## Expected noise (not failures)

Full-suite output prints dataset-load logs, e.g. `Skipped "X": no reading`. These come from `KanjiParser` warning logs (capped at 3 per parser, then a summary line). Tolerate them.

## Where new behavior needs coverage

- New `ProgressEngine` transition → unit test in `test/domain/progress_engine_test.dart`.
- New parser tolerance/skip case → `test/core/*_parser_test.dart`.
- New screen/route → `test/widgets/` (verify via `pumpApp` + navigation).
- Theme/font wiring → `test/theme_test.dart` (guards `fontFamily` on `textTheme` and `appBarTheme.titleTextStyle`).

## Related docs

- [`state_management.md`](state_management.md) — the in-memory-authoritative design that drives the settle-after-write pattern.
- [`data_logic.md`](data_logic.md) — the dataset integrity rules enforced by `content_repository_test.dart`.