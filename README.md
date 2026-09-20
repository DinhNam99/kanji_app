# Kanji Beginner

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