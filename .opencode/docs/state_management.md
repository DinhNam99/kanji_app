# State Management

> Hard constraint (from `AGENTS.md`): **plain `ChangeNotifier` + `InheritedWidget` only** — no provider/riverpod/bloc, no codegen. `flutter pub get` is the only pub workflow. New state logic must never end up in controllers/UI.

## Data flow at a glance

```
AppController (root ChangeNotifier)
 ├── content: LoadedContent?      ← immutable static data (ContentRepository)
 ├── status: AppStatus            ← loading / ready / error
 └── progress: ProgressController (ChangeNotifier)
        └── _states: Map<String, KanjiState>
              ↓  persist (fire-and-forget)
        SharedPreferencesProgressStore (key 'progress_v1', JSON)
```

Rebuild wiring: `KanjiApp` subscribes to `AppController` via `AnimatedBuilder` (in `lib/app.dart`) so a notify at any level rebuilds the `MaterialApp`. Screens use `AppScope.of(context)` to read the controller and rebuild; `AppScope.read(context)` for one-shot reads (see [`architecture.md`](architecture.md)).

## `AppController` — `lib/controllers/app_controller.dart`

- `enum AppStatus { loading, ready, error }`.
- Owns `status`, `errorMessage`, `content` (`LoadedContent?`), and `progress` (`ProgressController`).
- `load()`: sets `loading` + notifies → `await _contentRepository.load(log: debugPrint)` → `await progress.init(loaded.allCharacters)` → `ready`; on exception sets `errorMessage`, `status = error`. Both paths end in `notifyListeners()`.
- `init` takes `allCharacters` — the **curriculum** set (union of topic chars), which is the source of truth for "overall" progress counts.

## `ProgressController` — `lib/controllers/progress_controller.dart`

In-memory `Map<String, KanjiState>`; `_initialized` flag.

- `init(Set<String> allCharacters)` — loads from store and **prunes** entries whose char is no longer in the curriculum (removed from `topics.json`).
- `stateOf(char)` — missing ⇒ `KanjiState.unlearned` (absence-means-unlearned invariant everywhere).
- `markSeen(char)` — auto-stamp on first reveal; delegates to `ProgressEngine.markSeen`; no-op if unchanged; `notifyListeners()` + `_persist()`.
- `assess(char, assessment)` — self-assessment (Remembered / Review Again); delegates to `ProgressEngine.applyAssessment`.
- `reset()` — clears memory **and** store (`await _store.clear()`).
- Read helpers delegate to the engine: `topicCounts`, `overallCounts`, `reviewQueue`, `topicReviewQueue`.
- `_persist()` — writes a **minimal** snapshot (only non-unlearned entries) to the store, **fire-and-forget** (`_store.save(snapshot).ignore()`). In-memory state is authoritative for the UI; a slow disk write must never block a frame.

## `ProgressEngine` — `lib/domain/progress/progress_engine.dart`

`abstract final class` of pure statics — **zero Flutter/IO imports**, directly unit-tested (`test/domain/progress_engine_test.dart`).

| Function | Behavior |
|---|---|
| `markSeen(current)` | UNLEARNED → LEARNING; otherwise unchanged. |
| `applyAssessment(current, assessment)` | `remembered`: UNLEARNED→LEARNING, LEARNING→LEARNED, LEARNED stays. `reviewAgain`: **never downgrades** — same state returned. |
| `countsFor(chars, states)` | `ProgressCounts(total, learned, learning)` over a given set. |
| `overallCounts(chars, states)` | Alias of `countsFor` for the full curriculum. |
| `reviewQueue(chars, states)` | Weakest-first: all LEARNING (in input order) then all UNLEARNED (in input order); LEARNED excluded. Stable ordering within a state. |

All of these take `states` as a parameter — the engine is a pure function of (characters, state map).

## Progress model — `lib/domain/models/kanji_state.dart`

- `enum KanjiState { unlearned(0), learning(1), learned(2) }` — int `value` is the persisted form (compact JSON).
- `fromValue(int)` — unknown/legacy values coerce to `unlearned`.
- `label` — "New" / "Learning" / "Learned" (UI copy).
- `ProgressCounts` — `total`, `learned`, `learning`; `fraction = learned/total` (0.0 when `total == 0`); `isEmpty` when `total == 0`.

## Persistence — `lib/data/progress/progress_store.dart`

- `abstract interface class ProgressStore { load(); save(Map<String,int>); clear(); }` — the boundary for swapping storage in tests.
- `SharedPreferencesProgressStore` — default key **`progress_v1`**; state is a single JSON-encoded `{char: int}` map.
- `save` drops UNLEARNED(0) entries (`_minimal`) — absence ⇒ unlearned, keeps payload tiny (~200-char curriculum).
- `load` is tolerant: non-string-key/non-num records dropped, `FormatException` (corrupted JSON) → empty store — the app must never crash on bad persisted data.
- Content (`kanji.json`) is never written by this store — user state is strictly separate from static content.

## Rules enforced by design

1. New transitions → `ProgressEngine` (pure statics) + a unit test.
2. Glyph/card/UI state that's cosmetic stays in widgets; learning state is always in `ProgressController`.
3. Never call `_store.save(...)` inline with `await` on a hot path — go through `_persist()` (fire-and-forget).

## Related docs

- [`architecture.md`](architecture.md) — layering + rebuild wiring via `AnimatedBuilder`/`AppScope`.
- [`testing.md`](testing.md) — why tests settle after `assess`/`markSeen`, mock prefs, fire-and-forget caveats.