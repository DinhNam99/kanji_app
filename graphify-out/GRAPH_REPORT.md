# Graph Report - kanji_app  (2026-09-21)

## Corpus Check
- 44 files · ~406,634 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 14 file(s) not represented in the graph (top: .ttf 10, (none) 3, .lock 1)

## Summary
- 391 nodes · 510 edges · 17 communities (14 shown, 3 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 7 edges (avg confidence: 0.88)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `4008467a`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- package:flutter/material.dart
- progress_controller.dart
- learning_screen.dart
- content_repository.dart
- kanji.dart
- kanji_card.dart
- app.dart
- Kanji Beginner
- topic.dart
- StatelessWidget
- kanji_state.dart
- @visibleForTesting
- progress_engine.dart
- topic_parser_test.dart
- kana_util.dart
- Japan Flag App Icon Flat Opaque Variant (iOS)
- graphify Section in AGENTS.md

## God Nodes (most connected - your core abstractions)
1. `AppController` - 6 edges
2. `Kanji Beginner` - 6 edges
3. `kanji_app Package` - 6 edges
4. `Kanji Beginner (README)` - 6 edges
5. `ProgressCounts` - 5 edges
6. `build` - 5 edges
7. `kanji.json Dataset` - 5 edges
8. `AppController` - 4 edges
9. `SharedPreferencesProgressStore` - 4 edges
10. `topics.json Curriculum` - 4 edges

## Surprising Connections (you probably didn't know these)
- `Kanji Beginner` --semantically_similar_to--> `Kanji Beginner (README)`  [INFERRED] [semantically similar]
  AGENTS.md → README.md
- `Progress Model` --conceptually_related_to--> `KanjiState`  [INFERRED]
  README.md → AGENTS.md
- `Progress Model` --conceptually_related_to--> `ProgressEngine`  [INFERRED]
  README.md → AGENTS.md
- `shared_preferences` --shares_data_with--> `SharedPreferencesProgressStore`  [INFERRED]
  pubspec.yaml → AGENTS.md
- `Kanji Beginner` --references--> `flutter_lints`  [EXTRACTED]
  AGENTS.md → analysis_options.yaml

## Import Cycles
- None detected.

## Communities (17 total, 3 thin omitted)

### Community 0 - "package:flutter/material.dart"
Cohesion: 0.06
Nodes (33): ../helpers.dart, ContentRepository, package:flutter/material.dart, package:flutter_test/flutter_test.dart, package:kanji_app/app.dart, package:kanji_app/controllers/app_controller.dart, package:kanji_app/controllers/progress_controller.dart, package:kanji_app/core/kana_util.dart (+25 more)

### Community 1 - "progress_controller.dart"
Cohesion: 0.06
Nodes (30): dart:convert, ../../domain/models/kanji_state.dart, ../../domain/progress/progress_engine.dart, assess, init, _initialized, isInitialized, markSeen (+22 more)

### Community 2 - "learning_screen.dart"
Cohesion: 0.06
Nodes (37): ../../core/sound_effects.dart, Kanji? get, _advance, _app, _assess, build, _confirmLeave, createState (+29 more)

### Community 3 - "content_repository.dart"
Cohesion: 0.05
Nodes (38): AssetBundle?, AssetBundle get, ../../core/json/kanji_parser.dart, ../../core/json/topic_parser.dart, ../../core/kana_util.dart, dart:async, ../../domain/models/kanji.dart, kanji_parser.dart (+30 more)

### Community 4 - "kanji.dart"
Cohesion: 0.10
Nodes (20): int?, character, cleanedKunReadings, cleanedOnReadings, freq, fromJson, grade, jlptNew (+12 more)

### Community 5 - "kanji_card.dart"
Cohesion: 0.07
Nodes (28): ColorScheme, build, ErrorScreen, message, onRetry, build, character, _HeroReading (+20 more)

### Community 6 - "app.dart"
Cohesion: 0.05
Nodes (40): ChangeNotifier, ../../controllers/app_controller.dart, data/content/content_repository.dart, data/progress/progress_store.dart, InheritedWidget, appTitle, build, buildTheme (+32 more)

### Community 7 - "Kanji Beginner"
Cohesion: 0.15
Nodes (22): AppController, AppScope, ContentRepository, kana_util, Kanji Beginner, kanji.json Dataset, KanjiState, ProgressEngine (+14 more)

### Community 8 - "topic.dart"
Cohesion: 0.12
Nodes (17): @immutable, kanji.dart, Kanji, ProgressCounts, char, description, fromJson, id (+9 more)

### Community 9 - "StatelessWidget"
Cohesion: 0.06
Nodes (38): ../../app.dart, ../../app_scope.dart, ../../domain/models/topic.dart, build, count, _DataWarningBanner, _EmptyTopics, HomeScreen (+30 more)

### Community 10 - "kanji_state.dart"
Cohesion: 0.08
Nodes (23): bool get, double get, appearSound, _play, playAppear, _player, playRemember, rememberSound (+15 more)

### Community 13 - "progress_engine.dart"
Cohesion: 0.22
Nodes (8): applyAssessment, Assessment, countsFor, markSeen, overallCounts, ProgressEngine, reviewQueue, ../models/kanji_state.dart

### Community 14 - "topic_parser_test.dart"
Cohesion: 0.22
Nodes (7): package:kanji_app/core/json/kanji_parser.dart, package:kanji_app/core/json/topic_parser.dart, main, validRecord, kanjiJson, kanjiResult, main

### Community 16 - "kana_util.dart"
Cohesion: 0.29
Nodes (6): cleanReading, code, hasMatch, isHiraganaReading, s, unifyReading

## Knowledge Gaps
- **215 isolated node(s):** `appTitle`, `controller`, `scheme`, `build`, `buildTheme` (+210 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 257 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **3 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AppController` connect `app.dart` to `learning_screen.dart`?**
  _High betweenness centrality (0.047) - this node is a cross-community bridge._
- **Why does `ContentRepository` connect `package:flutter/material.dart` to `content_repository.dart`, `app.dart`?**
  _High betweenness centrality (0.028) - this node is a cross-community bridge._
- **Why does `ProgressCounts` connect `topic.dart` to `StatelessWidget`, `kanji_state.dart`, `progress_controller.dart`?**
  _High betweenness centrality (0.024) - this node is a cross-community bridge._
- **What connects `appTitle`, `controller`, `scheme` to the rest of the system?**
  _215 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `package:flutter/material.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.06423034330011074 - nodes in this community are weakly interconnected._
- **Should `progress_controller.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.06439393939393939 - nodes in this community are weakly interconnected._
- **Should `learning_screen.dart` be split into smaller, more focused modules?**
  _Cohesion score 0.058029689608636977 - nodes in this community are weakly interconnected._