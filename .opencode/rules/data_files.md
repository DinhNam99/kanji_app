# Data Files Rules

> From `AGENTS.md` → "Data files". Governs the two bundled JSON assets and the curriculum.

## Asset ownership

- `assets/kanji.json` (~5.5MB, 13,108 records, ~3,039 skipped) — **read-only reference dataset**. Do NOT edit, "clean up", or prune it.
- `assets/topics.json` (10 topics, 196 kanji) — the **editable curriculum**. Add/remove kanji here and only here.

## Curriculum integrity (non-negotiable)

- Every topic `char` **must exist** in `kanji.json`.
- Every curated topic `reading` **must match** a dataset reading (compared after `unifyReading` normalization).
- Run **`flutter test test/data/content_repository_test.dart`** before committing any `topics.json` change — it enforces both rules on every `flutter test` run.

## Parser tolerance rules

- Segregated parsers may **skip malformed records and continue** — they must never crash the app on one bad record.
- Warning logs are **capped at 3 per parser** (`warnings.take(3)`); a positive-case exception is a genuinely malformed root JSON object, which throws `FormatException`.
- Records without a meaning or without a usable reading are skipped and counted (`skippedRecords`).

## Reading markers (dataset conventions — see `lib/core/kana_util.dart`)

| Marker | Meaning | Handling |
|---|---|---|
| trailing `-` | okurigana boundary (`ひと-` → `ひと`) | stripped |
| `.` | base/okurigana split (`ひと.つ` → `ひと`) | `cleanReading`: base only; `unifyReading`: join |
| leading `-` | compound-only (`-び`) | skipped (null) |
| leading `!` / `*` | WaniKani "not used in words" | stripped |

- `cleanReading` — display form; `unifyReading` — verification-only, never displayed to users.

## References

- Pipeline + validation details: `.opencode/docs/data_logic.md`.