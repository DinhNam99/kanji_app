import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../domain/models/topic.dart';
import '../widgets/progress_bar.dart';

/// Topic header + Start/Continue entry into the learning session.
class TopicDetailScreen extends StatelessWidget {
  const TopicDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final topic = ModalRoute.of(context)!.settings.arguments! as Topic;
    final progress = app.progress;

    return Scaffold(
      appBar: AppBar(title: Text(topic.name)),
      body: ListenableBuilder(
        listenable: progress,
        builder: (context, _) {
          final counts = progress.topicCounts(topic);
          final started = counts.learning > 0 || counts.learned > 0;
          final empty = counts.total == 0;
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  topic.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _CountRow(label: 'Kanji', value: '${counts.total}'),
                        const SizedBox(height: 6),
                        _CountRow(
                          label: 'Learned',
                          value: '${counts.learned}',
                        ),
                        if (counts.learning > 0) ...[
                          const SizedBox(height: 6),
                          _CountRow(
                            label: 'Learning',
                            value: '${counts.learning}',
                          ),
                        ],
                        const SizedBox(height: 12),
                        ProgressBar(
                          fraction: counts.fraction,
                          height: 12,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${(counts.fraction * 100).round()}% complete',
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: empty
                      ? null
                      : () => Navigator.pushNamed(
                          context,
                          '/learning',
                          arguments: topic,
                        ),
                  icon: Icon(
                    started ? Icons.play_arrow : Icons.school_outlined,
                  ),
                  label: Text(empty
                      ? 'No kanji yet'
                      : started
                          ? 'Continue'
                          : 'Start'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CountRow extends StatelessWidget {
  const _CountRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}