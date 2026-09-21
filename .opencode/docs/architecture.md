# Architecture

> Source of truth: `AGENTS.md` → "Architecture map". This doc expands it with the concrete wiring, so a fresh session can reason about where to add anything.

## Stack

Flutter 3.24.4 / Dart 3.5.4. Single package, no backend, no CI, no monorepo. Planner-friendly: no state-management packages, no codegen — `flutter pub get` is all that's ever needed after `pubspec.yaml` changes.

## Entrypoint — `lib/main.dart`

```dart
WidgetsFlutterBinding.ensureInitialized();
final controller = AppController(
  contentRepository: ContentRepository(),
  progressStore: SharedPreferencesProgressStore(),
);
await controller.load();          // 5.5MB kanji.json parsed synchronously at startup
runApp(KanjiApp(controller: controller));
```

- Always the **real** `ContentRepository` + `SharedPreferencesProgressStore` — no fakes anywhere in the prod path.
- `load()` completes before `runApp`, so the splash only shows during asset read/parse (single blocking startup cost).

## Root widget — `lib/app.dart`

`KanjiApp` (StatelessWidget) builds:

```
AppScope(app: controller)
└── AnimatedBuilder(animation: controller)        // rebuilds MaterialApp on every notifyListeners
    └── MaterialApp
        ├── theme: buildTheme()                   // NotoSansJP, Material 3, seed 0xFF3949AB
        ├── home: switch (controller.status)
        │     loading → SplashScreen
        │     error   → ErrorScreen(message: controller.errorMessage, onRetry: controller.load)
        │     ready   → HomeScreen
        └── routes:                               // flat Navigator 1.0 table — add new screens here
              '/topic'    → TopicDetailScreen
              '/learning' → LearningScreen
              '/review'   → ReviewScreen
              '/progress' → ProgressScreen
              '/settings' → SettingsScreen
```

- `home` is driven by `AppStatus` (defined in `lib/controllers/app_controller.dart`).
- **AppBar font gotcha (issue #4):** AppBar uses `appBarTheme.titleTextStyle` verbatim, so `fontFamily: 'NotoSansJP'` must be repeated there — the global `ThemeData.fontFamily` does not apply. Guarded by `test/theme_test.dart`.

## AppScope — `lib/app_scope.dart`

The single `InheritedWidget` exposing the app controller:

| Method | Mechanism | Effect |
|---|---|---|
| `AppScope.of(context)` | `dependOnInheritedWidgetOfExactType` | Establishes dependency → widget rebuilds when controller notifies. Use in `build`. |
| `AppScope.read(context)` | `getInheritedWidgetOfExactType` | No dependency. Safe in `initState`/callbacks. |

`updateShouldNotify` returns `oldWidget.app != app` (the controller instance is stable for app lifetime, so effectively the AppScope never re-notifies on its own — rebuilds flow through `AnimatedBuilder`).

## Layer layout — `lib/`

| Layer | Contents | Constraints |
|---|---|---|
| `core/` | `kana_util.dart` (reading markers/cleaners), `json/kanji_parser.dart`, `json/topic_parser.dart` | Tolerant parsers: skip malformed records, never crash; warning logs capped at 3 per parser |
| `data/` | `content/content_repository.dart` (asset loading → `LoadedContent`), `progress/progress_store.dart` (`ProgressStore` interface + SharedPrefs impl) | Only layer touching `rootBundle` / SharedPreferences |
| `domain/` | `models/` (`Kanji`, `Topic`, `TopicKanji`, `KanjiState`, `ProgressCounts`), `progress/progress_engine.dart` | Pure logic. `ProgressEngine` has zero Flutter/IO imports; models use `package:flutter/foundation.dart` only for `@immutable` |
| `controllers/` | `app_controller.dart`, `progress_controller.dart` | `ChangeNotifier`s; hold state + orchestrate data/domain |
| `ui/` | `screens/`, `widgets/` | Screens are **const constructors**; receive data via route arguments |

### Dependency direction

```
ui → controllers → data (+ domain)     domain → core
ui → app_scope (InheritedWidget)
core ← used by domain/models + data parsers + ui (leaf, no deps)
```

Rule of thumb: **new state transitions → `ProgressEngine`** (never logic in controllers/UI); new persistence/IO → `data/`; new routes/screens → `app.dart` + `ui/`.

## Navigation convention (keep it for new screens)

```dart
// Sender (e.g. home_screen.dart):
Navigator.pushNamed(context, '/topic', arguments: topic);

// Receiver (e.g. topic_detail_screen.dart):
final topic = ModalRoute.of(context)!.settings.arguments! as Topic;
```

Typed arguments (`Topic` object), never string ids across screens. Pushes found in `home_screen.dart`, `progress_screen.dart`, `topic_detail_screen.dart`.

## Related docs

- [`state_management.md`](state_management.md) — controllers, app status, progress model, persistence.
- [`data_logic.md`](data_logic.md) — asset pipeline, tolerant parsers, reading markers, curriculum validation.
- [`testing.md`](testing.md) — how the suite exercises all of this with real assets.