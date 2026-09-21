import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../controllers/app_controller.dart';
import '../../core/sound_effects.dart';
import '../../domain/models/kanji.dart';
import '../../domain/models/topic.dart';
import '../../domain/progress/progress_engine.dart';
import '../widgets/kanji_card.dart';
import '../widgets/progress_bar.dart';

/// One kanji at a time in the topic's fixed order. Reveal → self-assess.
class LearningScreen extends StatefulWidget {
  const LearningScreen({super.key});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen> {
  late final Topic _topic =
      ModalRoute.of(context)!.settings.arguments! as Topic;
  late final AppController _app = AppScope.read(context);

  int _index = 0;
  bool _revealed = false;
  bool _finished = false;

  TopicKanji get _entry => _topic.kanji[_index];

  Kanji? get _kanji => _app.content!.kanjiFor(_entry.char);

  String get _reading => _entry.readingFor(_kanji!) ?? '';

  void _reveal() {
    if (_revealed) return;
    setState(() => _revealed = true);
    SoundEffects.playAppear();
    // First reveal stamps the kanji as "seen" (UNLEARNED → LEARNING).
    _app.progress.markSeen(_entry.char);
  }

  void _assess(Assessment assessment) {
    if (assessment == Assessment.remembered) SoundEffects.playRemember();
    if (!_revealed) _reveal();
    _app.progress.assess(_entry.char, assessment);
    _advance();
  }

  void _advance() {
    if (_index + 1 >= _topic.kanji.length) {
      _finished = true;
      _showCompletion();
    } else {
      setState(() {
        _index++;
        _revealed = false;
      });
    }
  }

  Future<void> _showCompletion() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.celebration_outlined, size: 40),
        title: const Text('Topic complete!'),
        content: const Text(
          'You have seen all the kanji in this topic. '
          'Revisit any time to review.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _confirmLeave() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave session?'),
        content: const Text('Your progress so far is saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if (leave == true && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final kanji = _kanji;
    final total = _topic.kanji.length;

    return PopScope(
      canPop: _finished,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_finished) _confirmLeave();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('${_topic.name} · ${_index + 1}/$total'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ProgressBar(
                  fraction: (_index + 1) / total,
                  label: 'Session progress',
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: kanji == null
                      ? const Center(child: Text('Sorry, this kanji is unavailable.'))
                      : KanjiCard(
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
                        onPressed: _revealed
                            ? () => _assess(Assessment.reviewAgain)
                            : null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: scheme.error,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.replay),
                        label: const Text('Review Again'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _revealed
                            ? () => _assess(Assessment.remembered)
                            : null,
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
            ),
          ),
        ),
      ),
    );
  }
}