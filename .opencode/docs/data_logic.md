# Data & Dataset Logic

> The app is offline-first: everything the user sees comes from two bundled JSON assets. This doc covers the load pipeline, the tolerant parsers, the reading-marker conventions, and the curriculum validation rule.

## The two assets

| File | Size / shape | Role |
|---|---|---|
| `assets/kanji.json` | ~5.5MB, 13,108 records (~3,039 skipped at load) | **Read-only reference dataset** (kanji-data schema). Authoritative source of readings/meanings. Don't "clean up" casually. |
| `assets/topics.json` | 10 topics, 196 kanji | **Editable curriculum.** Add kanji here, never to `kanji.json`. |

## Load pipeline — `lib/data/content/content_repository.dart`

```
ContentRepository.load({log})
  ├─ bundle.loadString('assets/kanji.json')  → KanjiParser.parse(raw)
  ├─ bundle.loadString('assets/topics.json') → TopicParser.parse(raw, kanjiResult, kanjiByChar)
  └─ → LoadedContent { kanjiByChar, topics, warnings, skippedRecords }
```

- `ContentRepository({AssetBundle? bundle})` — defaults to `rootBundle`; tests can inject a bundle.
- Logging: only the **first 3 warnings per parser** are logged (via `log`), plus a one-line summary (`N kanji loaded (M skipped), T topics`), so thousands of skipped-record messages never flood the console.
- `LoadedContent.allCharacters` — union of topic chars, the "available" set for overall progress.
- `kanjiFor(char)` / `topicById(id)` — O(n) lookups (fine at this dataset size).

## `KanjiParser` — `lib/core/json/kanji_parser.dart`

- Root must decode to a JSON object, else `FormatException` (a genuinely broken file is an error, not a skip).
- A record is **skipped** (counted, warned) when: value is not an object, **or** no meanings, **or** no usable reading (no cleaned kun/on reading AND on-readings aren't all hiragana).
- Result: `KanjiParseResult { kanjiByChar, skippedRecords, warnings }`.

## `Kanji` model — `lib/domain/models/kanji.dart`

- Mirrors the source schema: `character`, `strokes`, `meanings`, `readingsOn`, `readingsKun`, plus nullable `grade`, `freq`, `jlptOld`, `jlptNew` and WaniKani (`wk*`) fields (null for large parts of the dataset).
- `cleanedKunReadings` / `cleanedOnReadings` — raw readings passed through `cleanReading` (markers stripped, compound-only/null dropped).
- `defaultReading` — first clean kun reading, else first clean on reading, else `null`.

## `TopicParser` → `Topic.validateTopic` — `lib/core/json/topic_parser.dart` + `lib/domain/models/topic.dart`

- `topics.json` must have a `topics` list; each entry parsed by `Topic.fromJson` (tolerant: malformed entries skipped, throws only if a topic ends up with no usable kanji; duplicate topic ids skipped).
- `validateTopic(topic, kanjiByChar, log)` enforces the **curriculum integrity rules**:
  1. **Duplicate char in a topic** → skipped with warning.
  2. **Char not present in `kanji.json`** → entry dropped with warning.
  3. **Curated `reading` must match a dataset reading** — the reading is `unifyReading`-normalized and checked against every `readingsKun`/`readingsOn` entry (also unified); mismatch → warning (entry kept).
- `TopicKanji.readingFor(kanji)` — curated reading, falling back to `kanji.defaultReading` when absent.

## Reading markers — `lib/core/kana_util.dart`

Conventions from kanji-data that the app must decode:

| Marker | Meaning | Handler |
|---|---|---|
| trailing `-` | okurigana boundary (`ひと-` → `ひと`) | stripped by `cleanReading`/`unifyReading` |
| `.` | base/okurigana split (`ひと.つ` → `ひと`) | `cleanReading` keeps base `ひと`; `unifyReading` joins (`ひとつ`) |
| leading `-` | compound-only reading (`-び`) | **skipped** → null |
| leading `!` / `*` | WaniKani "not used in words" | stripped, kept |

- `cleanReading(raw)` — display form: strips markers, drops okurigana. Returns `null` for compound-only.
- `unifyReading(raw)` — verification-only: same stripping but **keeps** okurigana joined (`た.べる` → `たべる`); used by `validateTopic` and topic-override checks. Never shown to users.
- `isHiraganaReading(s)` — `^[ぁ-ゟー]+$` (hiragana incl. long-vowel/iteration marks); used by the parser's reading-usability check.

## Editing the curriculum (workflow)

1. Edit **`assets/topics.json` only** — never `kanji.json`.
2. Every `char` must exist in `kanji.json`; every curated `reading` must match a dataset reading (validated by `validateTopic`).
3. **Before committing**, run `flutter test test/data/content_repository_test.dart` — this enforces rules 1–2 on every `flutter test` run.

## Related docs

- [`architecture.md`](architecture.md) — where the parsers sit in the layer map.
- [`testing.md`](testing.md) — why parser/validation tests load the real assets.