# Graph Report - kanji_app  (2026-09-21)

## Corpus Check
- 0 files · ~406,145 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 369 nodes · 486 edges · 22 communities (20 shown, 2 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 7 edges (avg confidence: 0.88)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- Test Harness & Repos
- App State & Controllers
- Learning Screen Flow
- Content Loading Pipeline
- Kanji Model Fields
- Kanji Card Display
- App Root & Theme
- Core Architecture Hubs
- Domain Models
- Home Screen Dashboard
- Settings & Splash
- Progress Persistence
- Topic Detail Screen
- Progress Engine Rules
- Parser Tests
- List Widgets & State
- Kana Utilities
- Progress Screen
- Error Screen
- Navigation Routes
- Japan Flag Icons
- Graphify Agent Notes

## God Nodes (most connected - your core abstractions)
1. `AppController` - 6 edges
2. `Kanji Beginner` - 6 edges
3. `kanji_app Package` - 6 edges
4. `Kanji Beginner (README)` - 6 edges
5. `build` - 5 edges
6. `ProgressCounts` - 5 edges
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

## Communities (22 total, 2 thin omitted)

### Community 0 - "Test Harness & Repos"
Cohesion: 0.07
Nodes (32): ../helpers.dart, ContentRepository, package:flutter_test/flutter_test.dart, package:kanji_app/app.dart, package:kanji_app/controllers/app_controller.dart, package:kanji_app/controllers/progress_controller.dart, package:kanji_app/core/kana_util.dart, package:kanji_app/data/content/content_repository.dart (+24 more)

### Community 1 - "App State & Controllers"
Cohesion: 0.06
Nodes (35): ../../app.dart, bool get, ChangeNotifier, data/content/content_repository.dart, data/progress/progress_store.dart, ../../domain/progress/progress_engine.dart, AppController, AppStatus (+27 more)

### Community 2 - "Learning Screen Flow"
Cohesion: 0.06
Nodes (36): Kanji? get, _advance, _app, _assess, build, _confirmLeave, createState, _entry (+28 more)

### Community 3 - "Content Loading Pipeline"
Cohesion: 0.06
Nodes (31): AssetBundle?, AssetBundle get, ../../core/json/kanji_parser.dart, ../../core/json/topic_parser.dart, ../../core/kana_util.dart, ../../domain/models/kanji.dart, kanji_parser.dart, kanjiByChar (+23 more)

### Community 4 - "Kanji Model Fields"
Cohesion: 0.06
Nodes (32): double get, int?, character, cleanedKunReadings, cleanedOnReadings, freq, fromJson, grade (+24 more)

### Community 5 - "Kanji Card Display"
Cohesion: 0.08
Nodes (23): ColorScheme, build, character, _HeroReading, KanjiCard, kun, kunReadings, meaning (+15 more)

### Community 6 - "App Root & Theme"
Cohesion: 0.08
Nodes (22): ../../controllers/app_controller.dart, InheritedWidget, appTitle, build, buildTheme, controller, KanjiApp, scheme (+14 more)

### Community 7 - "Core Architecture Hubs"
Cohesion: 0.15
Nodes (22): AppController, AppScope, ContentRepository, kana_util, Kanji Beginner, kanji.json Dataset, KanjiState, ProgressEngine (+14 more)

### Community 8 - "Domain Models"
Cohesion: 0.12
Nodes (17): @immutable, kanji.dart, Kanji, ProgressCounts, char, description, fromJson, id (+9 more)

### Community 9 - "Home Screen Dashboard"
Cohesion: 0.23
Nodes (11): count, _DataWarningBanner, _EmptyTopics, HomeScreen, overall, _OverallCard, _ReviewCta, warnings (+3 more)

### Community 10 - "Settings & Splash"
Cohesion: 0.22
Nodes (7): ../../app_scope.dart, build, _confirmReset, SettingsScreen, build, SplashScreen, package:flutter/material.dart

### Community 11 - "Progress Persistence"
Cohesion: 0.25
Nodes (8): dart:convert, clear, key, load, _minimal, ProgressStore, save, SharedPreferencesProgressStore

### Community 12 - "Topic Detail Screen"
Cohesion: 0.22
Nodes (8): ../../domain/models/topic.dart, build, _CountRow, label, TopicDetailScreen, value, Route /learning, ../widgets/progress_bar.dart

### Community 13 - "Progress Engine Rules"
Cohesion: 0.22
Nodes (8): applyAssessment, Assessment, countsFor, markSeen, overallCounts, ProgressEngine, reviewQueue, ../models/kanji_state.dart

### Community 14 - "Parser Tests"
Cohesion: 0.22
Nodes (7): package:kanji_app/core/json/kanji_parser.dart, package:kanji_app/core/json/topic_parser.dart, main, validRecord, kanjiJson, kanjiResult, main

### Community 15 - "List Widgets & State"
Cohesion: 0.25
Nodes (7): ../../domain/models/kanji_state.dart, build, counts, name, onTap, TopicTile, progress_bar.dart

### Community 16 - "Kana Utilities"
Cohesion: 0.29
Nodes (6): cleanReading, code, hasMatch, isHiraganaReading, s, unifyReading

### Community 17 - "Progress Screen"
Cohesion: 0.29
Nodes (6): counts, name, onTap, overall, ProgressScreen, _SummaryCard

### Community 18 - "Error Screen"
Cohesion: 0.33
Nodes (5): build, ErrorScreen, message, onRetry, VoidCallback

### Community 19 - "Navigation Routes"
Cohesion: 0.40
Nodes (6): build, build, Route /progress, Route /review, Route /settings, Route /topic

## Knowledge Gaps
- **203 isolated node(s):** `controller`, `main`, `_topic`, `main`, `main` (+198 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 240 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **2 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `AppController` connect `App State & Controllers` to `Learning Screen Flow`, `App Root & Theme`?**
  _High betweenness centrality (0.046) - this node is a cross-community bridge._
- **Why does `ContentRepository` connect `Test Harness & Repos` to `App State & Controllers`, `Content Loading Pipeline`?**
  _High betweenness centrality (0.039) - this node is a cross-community bridge._
- **Why does `ProgressCounts` connect `Domain Models` to `Home Screen Dashboard`, `Kanji Model Fields`, `Progress Screen`, `List Widgets & State`?**
  _High betweenness centrality (0.025) - this node is a cross-community bridge._
- **What connects `controller`, `main`, `_topic` to the rest of the system?**
  _203 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Test Harness & Repos` be split into smaller, more focused modules?**
  _Cohesion score 0.06504065040650407 - nodes in this community are weakly interconnected._
- **Should `App State & Controllers` be split into smaller, more focused modules?**
  _Cohesion score 0.05832147937411095 - nodes in this community are weakly interconnected._
- **Should `Learning Screen Flow` be split into smaller, more focused modules?**
  _Cohesion score 0.05832147937411095 - nodes in this community are weakly interconnected._