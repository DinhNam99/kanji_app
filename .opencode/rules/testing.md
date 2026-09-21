# Testing Rules

> From `AGENTS.md` → "Testing gotchas". Follow these when writing or debugging tests.

## Non-negotiable patterns

- Widget tests **load the real bundled assets and real SharedPreferences** — never fake the repository or store.
- **Real async (asset bundle + prefs) must run inside `tester.runAsync`**, then `pumpAndSettle()`. Use the helpers in `test/helpers.dart`:
  - `pumpApp(tester)` — seeds `SharedPreferences.setMockInitialValues({})`, loads a real controller, pumps `KanjiApp`, settles, returns the controller.
  - `await tester.runAsync(createLoadedController)` for controller-only work.
- `SharedPreferences.setMockInitialValues({})` is required before any prefs access (already inside `pumpApp`; add it in any test touching prefs directly).

## Persistence & settling

- Progress writes are **fire-and-forget** (`_store.save(...).ignore()`); in-memory state is authoritative.
- Assert on `controller.progress.*`, not raw prefs.
- After `assess`/`markSeen`/`reset`, **settle (`pumpAndSettle`)** before asserting persistence round-trips so the async write drains.

## Interpretation

- Full test output prints dataset-load logs (`Skipped "X": no reading`) — **expected noise**, not failures.
- Full suite: ~56 tests, ~5s.
- Keep `flutter analyze` clean.

## Focused runs

```sh
flutter test                                  # full suite
flutter test test/domain/progress_engine_test.dart     # engine logic
flutter test test/data/content_repository_test.dart     # curriculum integrity
flutter test test/widgets/app_flow_test.dart            # one widget area
```

## Coverage expectations

- New `ProgressEngine` transition → unit test in `test/domain/progress_engine_test.dart`.
- New parser tolerance case → `test/core/*_parser_test.dart`.
- New screen/route → `test/widgets/`.
- Theme/font wiring → `test/theme_test.dart`.

## References

- Patterns in depth: `.opencode/docs/testing.md`.