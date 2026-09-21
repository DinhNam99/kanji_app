# State Management Rules

> From `AGENTS.md` → "Progress model". Governs the learning-state machine and its persistence.

## Canonical model

- `KanjiState` is an int enum: `unlearned(0)` / `learning(1)` / `learned(2)` (see `lib/domain/models/kanji_state.dart`).
- Persistence: SharedPreferences key **`progress_v1`**, single JSON map `{char: int}`.
- **Absence ⇒ unlearned.** Only non-zero states are ever written (`_persist()` in `ProgressController` drops UNLEARNED entries).

## State machine rules

- All transitions live in `ProgressEngine` (`lib/domain/progress/progress_engine.dart`) as pure statics — **no Flutter/IO imports, no side effects**.
- `markSeen`: UNLEARNED → LEARNING (first reveal auto-stamp).
- `applyAssessment`:
  - `remembered`: UNLEARNED→LEARNING, LEARNING→LEARNED, LEARNED stays.
  - `reviewAgain`: **never downgrades** — returns the same state.
- `reviewQueue`: LEARNING before UNLEARNED (weakest first), stable within a state; LEARNED excluded.
- **New transitions belong in `ProgressEngine`, not in controllers/UI** — and get a unit test in `test/domain/progress_engine_test.dart`.

## Controller rules

- `AppController` is the root `ChangeNotifier` (`AppStatus.loading/ready/error`); owns `content` + `progress`.
- `ProgressController` holds the in-memory `Map<String, KanjiState>`; load prunes entries for chars no longer in the curriculum.
- `stateOf(char)` must default to `unlearned` for missing keys.
- Persist through `_persist()` — **fire-and-forget** (`_store.save(...).ignore()`); the in-memory state is authoritative for the UI.
- `reset()` must clear both memory and the store.
- `ProgressStore` is an interface (`load`/`save`/`clear`) — tolerate corrupted payloads (bad JSON → empty store, never crash).

## References

- Full design + rationale: `.opencode/docs/state_management.md`.