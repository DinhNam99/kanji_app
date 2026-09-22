import 'package:flutter/foundation.dart';

import '../data/content/content_repository.dart';
import '../data/progress/progress_store.dart';
import '../domain/models/topic.dart';
import 'progress_controller.dart';

enum AppStatus { loading, ready, error }

/// Root controller: loads static content + user progress once at startup.
class AppController extends ChangeNotifier {
  AppController({
    required ContentRepository contentRepository,
    required ProgressStore progressStore,
  })  : _contentRepository = contentRepository,
        progress = ProgressController(store: progressStore);

  final ContentRepository _contentRepository;

  /// Exposed for screens (Home, Review, Progress, …).
  final ProgressController progress;

  AppStatus status = AppStatus.loading;
  String? errorMessage;
  LoadedContent? content;

  bool get isReady => status == AppStatus.ready;

  /// First topic that still has unlearned kanji — powers the Home "Continue"
  /// CTA. Null when every topic has been seen at least once (nothing new to
  /// learn; Review covers the rest).
  Topic? get resumeTopic {
    final loaded = content;
    if (loaded == null) return null;
    for (final topic in loaded.topics) {
      final counts = progress.topicCounts(topic);
      if (counts.learned + counts.learning < counts.total) return topic;
    }
    return null;
  }

  Future<void> load() async {
    status = AppStatus.loading;
    notifyListeners();
    try {
      final loaded = await _contentRepository.load(log: debugPrint);
      await progress.init(loaded.allCharacters);
      content = loaded;
      status = AppStatus.ready;
    } catch (e, stack) {
      debugPrint('Failed to load app content: $e\n$stack');
      errorMessage = e.toString();
      status = AppStatus.error;
    }
    notifyListeners();
  }
}