# OpenCode Memory — kanji_app

Durable session memory for this repo. Pairs with `AGENTS.md` (rules/commands) — this file records **context and history**; `AGENTS.md` is authoritative for workflow rules.

**Deep-dive docs live in `.opencode/docs/`**: `architecture.md` (wiring, layers, navigation), `state_management.md` (ChangeNotifier/InheritedWidget, progress model, persistence), `data_logic.md` (asset pipeline, tolerant parsers, reading markers, curriculum rules), `testing.md` (real-asset test patterns).

**Normative instructions live in `.opencode/rules/`**: `git_workflow.md`, `architecture.md`, `state_management.md`, `data_files.md`, `testing.md`, `graphify.md` — imperative rule sets derived from AGENTS.md, one per technical domain.

## Project at a glance

- **Kanji Beginner** — offline-first beginner kanji learner. Flutter 3.24.4 / Dart 3.5.4, single package, no backend, no CI.
- Repo: **private** `DinhNam99/kanji_app`. All PR-based work belongs on `feature/*` branches off `main` — never commit directly on `main`.
- Architecture: `lib/main.dart` (entry) → `AppController` (`ChangeNotifier`, real `ContentRepository` + `SharedPreferencesProgressStore`, `await controller.load()` before `runApp`) → `lib/app.dart` (flat Navigator 1.0 routes `/topic`, `/learning`, `/review`, `/progress`, `/settings`). State via `ChangeNotifier` + `InheritedWidget` only — **no provider/riverpod/bloc, no codegen**.
- Domain: `KanjiState` enum (0=unlearned/1=learning/2=learned) persisted as JSON map under `progress_v1`; absence ⇒ unlearned. `ProgressEngine` (pure Dart, no Flutter/IO) owns all state transitions.
- Data: `assets/kanji.json` (~5.5MB, 13,108 records, ~3,039 skipped, read-only) + `assets/topics.json` (10 topics / 196 kanji, editable curriculum). `test/data/content_repository_test.dart` enforces topic chars/readings exist in the dataset — run it after touching `topics.json`.

## Work session log

### Issue #4 / PR #5 — Noto Sans JP font (MERGED)
- Render all Japanese text with bundled **Noto Sans JP**, set app-wide via `ThemeData(fontFamily:)` in `buildTheme()`.
- **Key decision:** bundle *static* weight files (w400/500/600/700) instead of the ~9MB variable font — automatic `FontWeight → wght` mapping for variable fonts only landed in Flutter 3.41, and this app pins 3.24.4.
- Changes: `pubspec.yaml` `fonts:` block (`NotoSansJP` family — Regular + Medium 500 + SemiBold 600 + Bold 700) · `lib/app.dart` `buildTheme()` sets `fontFamily: 'NotoSansJP'` (line ~59) **and** AppBar `titleTextStyle` (line ~67, found via regression test — AppBar uses the style verbatim, so the family was missing there) · new `test/theme_test.dart` guarding the wiring.
- Verification: `flutter analyze` clean, `flutter test` 56/56 (55 existing + 1 new), PR opened and **merged** (`7814da0`).
- **Follow-ups after merge (on `main`):** `5ebccc0 "More NotoSansJP font"` added the *full* pack (variable font + all 9 static weights, ~56MB) into git — it is tracked now, though only the 4 used weights are registered in `pubspec.yaml` (unused weights are dead weight; consider pruning later). `f4976ff "Add Graph for Project"` added the graphify skill/plugin + `graphify-out/`.

### PR #3 — App icon (merged, `c13af4a`)
- `flutter_launcher_icons` single source of truth at `assets/icons/japan.png` (+ opaque 1024×1024 `japan_flat.png` for iOS alpha). Regenerate with `dart run flutter_launcher_icons`. See `pubspec.yaml` `flutter_launcher_icons:` block (android `ic_launcher`, minSdk 21).

## Gotchas & environment

- **Private repo access:** unauthenticated GitHub API returns 404. Get a PAT with `git credential fill` (`protocol=https`, `host=github.com`; username is `46918592`) and use it for `curl` API calls. `gh` CLI is **not installed**; the `github` MCP server may also be unavailable — fall back to curl.
- **Widget tests** load real bundled assets + real SharedPreferences. Use `test/helpers.dart`: `pumpApp(tester)`/`createLoadedController` inside `tester.runAsync`, then `pumpAndSettle()`. `SharedPreferences.setMockInitialValues({})` is required before prefs access (already in `pumpApp`).
- Progress saves are fire-and-forget; in-memory state is authoritative.
- Full test output includes dataset-load noise lines (`Skipped "X": no reading`) — expected, not failures.
- **Git hygiene:** full font pack is now tracked, but if anyone re-downloads the pack, avoid stray `git add -A` that sweeps in unrelated files. Nothing currently untracked; working tree clean.
- After Dart/code changes, keep the graph current: `graphify update .` (AST-only, no API cost, per new AGENTS.md section). `.opencode/memory.md` is a doc, not code — no update needed for it.

## Next steps (when relevant)

- Device-level Android/iOS font rendering verification (no emulator/device available here) — manual `flutter run` check.
- Consider pruning the unused tracked font weights (Black/ExtraBold/ExtraLight/Light/Thin + variable) to slim the repo/bundle; only 4 are registered.