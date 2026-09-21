# Kanji Beginner

[![CI](https://github.com/DinhNam99/kanji_app/actions/workflows/ci.yml/badge.svg)](https://github.com/DinhNam99/kanji_app/actions/workflows/ci.yml)

A simple, offline-first Flutter app for learning basic Japanese kanji.

For beginners: pick a topic, reveal each kanji (reading + meaning), and
self-assess. Your progress is stored on-device — no account, no backend,
works fully offline.

## Features

- **10 beginner topics, 196 curated kanji** (`assets/topics.json`) — numbers,
  time, nature, people, places, school, daily life, body, directions, and
  other basics.
- **Learn** — each card hides its meaning/reading until you tap to reveal it.
  One tap on **I Remember** marks a kanji as learned; **Review Again** keeps
  it in circulation without ever downgrading progress.
- **Review** — a one-pass queue of everything not yet learned
  (learning first, then never-seen), so nothing slips through between lessons.
- **Progress** — per-topic and overall counts, all tracked locally.
- **Offline-first** — static content ships in the bundle
  (`assets/kanji.json`, ~10k usable records for future expansion, and the
  curated `assets/topics.json`).

## Getting started

```sh
flutter pub get
flutter run
```

Run the test suite (unit + integration widget tests):

```sh
flutter test
```

For an HTML coverage report (LCOV + HTML, written to the gitignored `coverage/`):

```sh
./scripts/test_coverage.sh          # run tests, then write coverage/html/index.html
./scripts/test_coverage.sh --open   # ...and open it in a browser
```

## CI/CD

GitHub Actions automates the checks and packaging (no signing secrets required):

- **CI** (`.github/workflows/ci.yml`) — on every PR to `main` and every push to
  `main`: `flutter pub get`, a non-blocking `dart format` check, `flutter analyze`,
  and `flutter test --coverage` (the coverage report is uploaded as an artifact).
- **Release** (`.github/workflows/release.yml`) — on a `v*` tag (or manual
  `workflow_dispatch`): builds a release **APK**, **AAB**, and an unsigned **iOS**
  app, then attaches them to a GitHub Release. Android builds use the debug
  signing config for now; configure a keystore before publishing to stores.

The toolchain is pinned to Flutter `3.24.4` to match local development.

## How progress works

Progress is kept **separately from static content** in
`SharedPreferences` under the key `progress_v1` (a JSON map; unlearned
kanji are simply absent). The learning model:

| State      | Meaning                                  |
| ---------- | ---------------------------------------- |
| `UNLEARNED`| Never seen (absent from storage)         |
| `LEARNING` | Revealed once; tap **I Remember** to learn |
| `LEARNED`  | Known; removed from the review queue     |

Revealing a card auto-stamps it `LEARNING`. **Review Again** never
downgrades a kanji.

## Structure

```
lib/
  core/        Kana utilities + tolerant JSON parsers
  data/        ContentRepository (assets) + SharedPreferences progress store
  domain/      Models + pure progress engine (state transitions, queueing)
  controllers/ ChangeNotifier controllers (AppController, ProgressController)
  ui/          Screens and widgets (Material 3, Navigator 1.0 named routes)
```

No state-management packages, no code generation, no backend — plain
`ChangeNotifier` + `ListenableBuilder` throughout.

## The data files

- `assets/kanji.json` — the full 13,108-record kanji dataset (read-only
  reference). ~3,000 malformed/partial records are skipped at load with a
  visible notice rather than crashing the app.
- `assets/topics.json` — the curated beginner curriculum. Every kanji and
  every curated reading override is verified to exist in `kanji.json`; a
  unit test (`test/data/content_repository_test.dart`) enforces this on every
  run, so the curriculum can never drift from the dataset.