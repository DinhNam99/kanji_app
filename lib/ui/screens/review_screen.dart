import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../controllers/app_controller.dart';
import '../../core/sound_effects.dart';
import '../../domain/models/kanji.dart';
import '../../domain/progress/progress_engine.dart';
import '../widgets/kanji_card.dart';

/// One pass through the "not learned yet" queue (LEARNING first, then
/// UNLEARNED), across all topics. Assessments update progress; the queue is
/// captured when the session starts.
class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  late final AppController _app = AppScope.read(context);
  late final List<String> _queue = _buildQueue();
  int _index = 0;
  bool _revealed = false;

  List<String> _buildQueue() {
    final content = _app.content!;
    return _app.progress.reviewQueue(content.allCharacters);
  }

  bool get _isEmpty => _queue.isEmpty;
  bool get _isDone => _queue.isNotEmpty && _index >= _queue.length;

  Kanji? get _kanji {
    if (_queue.isEmpty || _isDone) return null;
    return _app.content!.kanjiFor(_queue[_index]);
  }

  String get _reading {
    if (_queue.isEmpty || _isDone) return '';
    final content = _app.content!;
    // Use the entry's curated reading if its topic defines one, else default.
    for (final topic in content.topics) {
      for (final entry in topic.kanji) {
        if (entry.char == _queue[_index]) {
          return entry.readingFor(_kanji!) ?? '';
        }
      }
    }
    return _kanji!.defaultReading ?? '';
  }

  void _reveal() {
    if (_revealed) return;
    setState(() => _revealed = true);
    SoundEffects.playAppear();
    _app.progress.markSeen(_queue[_index]);
  }

  void _assess(Assessment assessment) {
    if (_queue.isEmpty || _isDone) return;
    if (assessment == Assessment.remembered) SoundEffects.playRemember();
    if (!_revealed) _reveal();
    _app.progress.assess(_queue[_index], assessment);
    setState(() {
      _index++;
      _revealed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Review')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.celebration_outlined, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        'Nothing to review — you have learned everything!',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : _isDone
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.done_all, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            'Review complete!',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Back to topics'),
                          ),
                        ],
                      ),
                    )
                  : _buildSession(context, scheme),
        ),
      ),
    );
  }

  Widget _buildSession(BuildContext context, ColorScheme scheme) {
    final kanji = _kanji!;
    final total = _queue.length;
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '${_index + 1} / $total to review',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: KanjiCard(
            character: kanji.character,
            reading: _reading,
            meaning: kanji.primaryMeaning,
            onReadings: kanji.cleanedOnReadings,
            kunReadings: kanji.cleanedKunReadings,
            revealed: _revealed,
            onReveal: _reveal,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _revealed ? () => _assess(Assessment.reviewAgain) : null,
                style: OutlinedButton.styleFrom(
                  foregroundColor: scheme.error,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.replay),
                label: const Text('Again'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: _revealed ? () => _assess(Assessment.remembered) : null,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.check),
                label: const Text('I Remember'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}