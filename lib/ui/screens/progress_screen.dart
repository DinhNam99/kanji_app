import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../domain/models/kanji_state.dart';
import '../widgets/progress_bar.dart';

/// Overall + per-topic progress. Reset lives in Settings.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final content = app.content!;
    final progress = app.progress;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: progress,
        builder: (context, _) {
          final overall = progress.overallCounts(content.allCharacters);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SummaryCard(overall: overall),
              const SizedBox(height: 16),
              Text(
                'By topic',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              for (final topic in content.topics)
                _TopicProgressRow(
                  name: topic.name,
                  counts: progress.topicCounts(topic),
                  onTap: () =>
                      Navigator.pushNamed(context, '/topic', arguments: topic),
                ),
              const SizedBox(height: 24),
              Text(
                'Progress is stored only on this device. '
                'You can reset it in Settings.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.overall});

  final ProgressCounts overall;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${overall.learned} of ${overall.total} kanji learned',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            if (overall.learning > 0) ...[
              const SizedBox(height: 4),
              Text(
                '${overall.learning} in progress',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onPrimaryContainer,
                    ),
              ),
            ],
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: overall.fraction,
                minHeight: 10,
                backgroundColor: scheme.surfaceContainerHighest,
                color: scheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicProgressRow extends StatelessWidget {
  const _TopicProgressRow({
    required this.name,
    required this.counts,
    required this.onTap,
  });

  final String name;
  final ProgressCounts counts;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(name,
                        style: Theme.of(context).textTheme.titleSmall),
                  ),
                  Text(
                    '${counts.learned}/${counts.total}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ProgressBar(fraction: counts.fraction, height: 8),
            ],
          ),
        ),
      ),
    );
  }
}