# OpenCode Memory — kanji_app

Durable session memory for this repo. Pairs with `AGENTS.md` (rules/commands) — this file records **context and history**; `AGENTS.md` is authoritative for workflow rules.

**Deep-dive docs live in `.opencode/docs/`**: `architecture.md` (wiring, layers, navigation), `state_management.md` (ChangeNotifier/InheritedWidget, progress model, persistence), `data_logic.md` (asset pipeline, tolerant parsers, reading markers, curriculum rules), `testing.md` (real-asset test patterns).

**Normative instructions live in `.opencode/rules/`**: `git_workflow.md`, `architecture.md`, `state_management.md`, `data_files.md`, `testing.md`, `graphify.md` — imperative rule sets derived from AGENTS.md, one per technical domain.

## Project at a glance

- **Kanji Beginner** — offline-first beginner kanji learner. Flutter 3.24.4 / Dart 3.5.4, single package, no backend. **CI:** GitHub Actions runs `flutter analyze` + `flutter test` on PRs (pinned 3.24.4, `ci.yml` from PR #8) plus a tag-based `release.yml`.
- Repo: **private** `DinhNam99/kanji_app`. All PR-based work belongs on `feature/*` branches off `main` — never commit directly on `main`.
- Architecture: `lib/main.dart` (entry) → `AppController` (`ChangeNotifier`, real `ContentRepository` + `SharedPreferencesProgressStore`, `await controller.load()` before `runApp`) → `lib/app.dart` (flat Navigator 1.0 routes `/topic`, `/learning`, `/review`, `/progress`, `/settings`). State via `ChangeNotifier` + `InheritedWidget` only — **no provider/riverpod/bloc, no codegen**.
- Domain: `KanjiState` enum (0=unlearned/1=learning/2=learned) persisted as JSON map under `progress_v1`; absence ⇒ unlearned. `ProgressEngine` (pure Dart, no Flutter/IO) owns all state transitions.
- Data: `assets/kanji.json` (~5.5MB, 13,108 records, ~3,039 skipped, read-only) + `assets/topics.json` (10 topics / 196 kanji, editable curriculum). `test/data/content_repository_test.dart` enforces topic chars/readings exist in the dataset — run it after touching `topics.json`.

## Work session log

### Issue #10 / PR #11 — Home screen UI/UX polish (OPEN — awaiting review)
- Plan: `~/.opencode/plan/home-ui-ux-improvement.md` (P1–P3). Branch `feature/home-ui-polish` off `main` (`3799cf0`).
- **P1 fixes:** overall card reuses the shared `ProgressBar` (invisible-track bug: track color equaled card bg), detail line `X in progress · Y not started` under the learned headline, heading "Learn" → "Overall Progress", dataset-skipped banner moved Home → **Settings > Diagnostics**, user-friendly empty-topics copy.
- **P2:** `AppController.resumeTopic` (first topic with unlearned kanji) powers a filled **Continue** CTA → `/learning` with plain `Topic` route args; `LearningScreen._index` now initializes to the first **non-learned** card so Continue/topic CTA resume mid-topic (falls back to card 1). Review CTA redesigned (tonal + `history` icon when due; plain + check + "All caught up!" when none — deliberately **kept tappable** so the review screen's empty state stays reachable). `TopicTile` → `TopicCard` (curriculum numbering, `learned/total`, completion badge, "N in progress" line, single semantic node, 2-col grid ≥600dp viewport). Home content capped to a centered 600dp column.
- Tests: **64/64** (59 existing + 5 new in `home_continue_test.dart` / `topic_card_test.dart`); pinned strings updated, never deleted. Commits `5504056` feat · `c36b4d1` test · `8acc365` graphify. PR: https://github.com/DinhNam99/kanji_app/pull/11 (Closes #10).
- **Durable gotcha:** a `tester.ensureSemantics()` handle must be disposed **inside the test body** — `addTearDown(handle.dispose)` runs *after* Flutter's `_endOfTestVerifications` (invoked inside `binding.runTest`) and fails with "A SemanticsHandle was active at the end of the test". Flutter's own framework tests call `handle.dispose()` at the end of the body.
- Also: the grid delegate class is `SliverGridDelegateWithFixedCrossAxisCount` (there is no `…WithCrossAxisCount`).

### Issue #4 / PR #5 — Noto Sans JP font (MERGED)
- Render all Japanese text with bundled **Noto Sans JP**, set app-wide via `ThemeData(fontFamily:)` in `buildTheme()`.
- **Key decision:** bundle *static* weight files (w400/500/600/700) instead of the ~9MB variable font — automatic `FontWeight → wght` mapping for variable fonts only landed in Flutter 3.41, and this app pins 3.24.4.
- Changes: `pubspec.yaml` `fonts:` block (`NotoSansJP` family — Regular + Medium 500 + SemiBold 600 + Bold 700) · `lib/app.dart` `buildTheme()` sets `fontFamily: 'NotoSansJP'` (line ~59) **and** AppBar `titleTextStyle` (line ~67, found via regression test — AppBar uses the style verbatim, so the family was missing there) · new `test/theme_test.dart` guarding the wiring.
- Verification: `flutter analyze` clean, `flutter test` 56/56 (55 existing + 1 new), PR opened and **merged** (`7814da0`).
- **Follow-ups after merge (on `main`):** `5ebccc0 "More NotoSansJP font"` added the *full* pack (variable font + all 9 static weights, ~56MB) into git — it is tracked now, though only the 4 used weights are registered in `pubspec.yaml` (unused weights are dead weight; consider pruning later). `f4976ff "Add Graph for Project"` added the graphify skill/plugin + `graphify-out/`.

### PR #3 — App icon (merged, `c13af4a`)
- `flutter_launcher_icons` single source of truth at `assets/icons/japan.png` (+ opaque 1024×1024 `japan_flat.png` for iOS alpha). Regenerate with `dart run flutter_launcher_icons`. See `pubspec.yaml` `flutter_launcher_icons:` block (android `ic_launcher`, minSdk 21).

## Gotchas & environment

- **GitHub access:** the `github` MCP server is authenticated as `DinhNam99` — use it for issues/PRs (`create_issue`, `create_pull_request`, …). Unauthenticated REST returns 404 on the private repo; `gh` CLI is **not installed**; the MCP token can't read check-runs (403 on that endpoint). Git pushes work over normal credentials.
- **Widget tests** load real bundled assets + real SharedPreferences. Use `test/helpers.dart`: `pumpApp(tester)`/`createLoadedController` inside `tester.runAsync`, then `pumpAndSettle()`. `SharedPreferences.setMockInitialValues({})` is required before prefs access (already in `pumpApp`).
- Progress saves are fire-and-forget; in-memory state is authoritative.
- Full test output includes dataset-load noise lines (`Skipped "X": no reading`) — expected, not failures.
- **Git hygiene:** full font pack is now tracked, but if anyone re-downloads the pack, avoid stray `git add -A` that sweeps in unrelated files. Untracked: `graphify-out/2026-09-2*/` dated backups (gitignore rule proposed, no decision yet) — stage `graphify-out` paths explicitly, never `git add graphify-out/`.
- After Dart/code changes, keep the graph current: `graphify update .` (AST-only, no API cost, per new AGENTS.md section). `.opencode/memory.md` is a doc, not code — no update needed for it.

## Next steps (when relevant)

- Device-level Android/iOS font rendering verification (no emulator/device available here) — manual `flutter run` check.
- Consider pruning the unused tracked font weights (Black/ExtraBold/ExtraLight/Light/Thin + variable) to slim the repo/bundle; only 4 are registered.