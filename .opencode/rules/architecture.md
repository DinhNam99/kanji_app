# Architecture Rules

> From `AGENTS.md` → "Architecture map".

## Hard constraints (never violate)

- **No state-management packages** — no provider, riverpod, bloc, or equivalents. Plain `ChangeNotifier` + `InheritedWidget`.
- **No codegen** — no `build_runner`; `flutter pub get` is the only pub workflow.
- **No `integration_test/` directory.**
- Domain layer stays **pure Dart** — `ProgressEngine` must have no Flutter/IO imports (models may use `package:flutter/foundation.dart` only for `@immutable`).

## Layer rules

- `core/` — kana utils + tolerant JSON parsers. Parsers must **skip malformed records, never crash**; warning logs capped at 3 per parser.
- `data/` — asset content repo + SharedPreferences progress store. Only layer touching `rootBundle` / SharedPreferences.
- `domain/` — models + `ProgressEngine` (pure statics, no side effects).
- `controllers/` — `ChangeNotifier`s; orchestrate data/domain.
- `ui/` — screens/widgets.

## Navigation & widget rules

- **Screens are const constructors.** Data travels via route arguments:
  - Sender: `Navigator.pushNamed(context, '/topic', arguments: topic)`.
  - Receiver: `final topic = ModalRoute.of(context)!.settings.arguments! as Topic;`
- **Add new screens to the route table in `lib/app.dart`** — flat Navigator 1.0 named routes (`/topic`, `/learning`, `/review`, `/progress`, `/settings`).
- Screen accessibility: `AppScope.of(context)` (subscribes — use in `build`); `AppScope.read(context)` (no dependency — usable in `initState`).

## Where logic belongs

- New state transitions → `ProgressEngine`, **never** in controllers/UI.
- New persistence/IO → `data/` behind an interface (`ProgressStore`, `ContentRepository`).
- Startup wiring (`main.dart`): construct `AppController` with the real repo + store, `await controller.load()` before `runApp`.

## References

- Full wiring diagram: `.opencode/docs/architecture.md`.