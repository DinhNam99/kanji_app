# AGENTS.md

Flutter app (Dart 3.5.4 / Flutter 3.24.4 stable): **Kanji Beginner** — offline-first beginner kanji learner. Single package, no monorepo, no backend, no CI. Plain `ChangeNotifier` + `InheritedWidget` throughout — **no state-management packages (no provider/riverpod/bloc), no codegen (no build_runner, `flutter pub get` is all that's ever needed), no integration_test/ directory.**

## Commands

```sh
flutter pub get        # after changing pubspec.yaml only
flutter analyze        # must stay clean (default flutter_lints)
flutter test           # full suite: ~55 tests, ~5s, loads real assets
flutter test test/domain/progress_engine_test.dart   # focused run
flutter run            # dev app
```

## Git workflow

- Never commit directly on `main`. Every change (feature or bug fix) starts from a new branch off `main`.
- Branch naming: `feature/[desc]` for new features, `bug/[desc]` for bug fixes (e.g. `feature/topic-search`, `bug/progress-reset-overflow`).

## Architecture map

- `lib/main.dart` — entrypoint; constructs `AppController` with the **real** `ContentRepository` + `SharedPreferencesProgressStore` and `await`s `controller.load()` before `runApp` (5.5MB JSON is parsed synchronously at startup).
- `lib/app.dart` — material root; home switches on `AppStatus` (loading/error/ready); **flat Navigator 1.0 named-route table** (`/topic`, `/learning`, `/review`, `/progress`, `/settings`). Adds new screens here.
- `lib/app_scope.dart` — `InheritedWidget` exposing the single `AppController`. `AppScope.of(context)` subscribes to rebuilds; `AppScope.read(context)` does not (use in `initState`).
- Layers: `core/` (kana utils + tolerant JSON parsers) · `data/` (asset content repo + SharedPreferences progress store) · `domain/` (models + `ProgressEngine`, **pure Dart, no Flutter/IO imports**) · `controllers/` (`ChangeNotifier`s) · `ui/` (screens/widgets).
- Screens are const constructors; navigation data travels via `ModalRoute.of(context)!.settings.arguments! as Topic` — keep that convention for new screens (`Navigator.pushNamed(context, '/x', arguments: obj)`).

## Testing gotchas (important)

- Widget tests **load the real bundled assets and real SharedPreferences**, not fakes. Use the helpers in `test/helpers.dart`: `pumpApp(tester)` or `await tester.runAsync(createLoadedController)` — real async (asset bundle + prefs) **must** run inside `tester.runAsync`, then `pumpAndSettle()`.
- `SharedPreferences.setMockInitialValues({})` is required before prefs access (already in `pumpApp`).
- Progress writes are fire-and-forget (`_store.save(...).ignore()`); in-memory state is authoritative — settle after assessing/persisting in tests.
- Full test output prints dataset-load logs (`Skipped "X": no reading`) — expected noise, not failures.

## Progress model

- `KanjiState` is an int enum: `unlearned(0) / learning(1) / learned(2)`, persisted under SharedPreferences key `progress_v1` as a JSON map. **Absence ⇒ unlearned** — only non-zero states are written.
- `ProgressEngine` (in `domain/progress/progress_engine.dart`) is an `abstract final class` of pure statics: `markSeen` (UNLEARNED→LEARNING), `applyAssessment` (Review Again **never downgrades**), `reviewQueue` (LEARNING before UNLEARNED, stable within state). Keep it Flutter/IO-free.
- New state transitions belong in `ProgressEngine`, not in controllers/UI.

## Data files

- `assets/kanji.json` (~5.5MB, 13,108 records, ~3,039 skipped at load) — read-only reference dataset. Tolerant parsing skips malformed records rather than crashing; warning logs are capped at 3 per parser. Don't "clean up" the dataset casually.
- `assets/topics.json` (10 topics, 196 kanji) — the editable curriculum. Add kanji here, not to `kanji.json`.
- **Every topic `char` must exist in `kanji.json` and every curated `reading` must match a dataset reading** — enforced at runtime by `test/data/content_repository_test.dart` (runs on every `flutter test`). Change `topics.json` → run `flutter test test/data/content_repository_test.dart` before committing.
- Reading markers in dataset content (see `lib/core/kana_util.dart`): trailing `-` = okurigana boundary, `.` = base/okurigana split, leading `-` = compound-only (skipped), leading `!`/`*` = WaniKani "not used in words" (skipped). `cleanReading` strips these for display; `unifyReading` is verification-only.