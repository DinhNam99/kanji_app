import 'package:flutter/material.dart';

import '../../app.dart';
import '../../app_scope.dart';
import '../../domain/models/kanji_state.dart';
import '../widgets/topic_tile.dart';

/// Home = overall progress header + the topic list (plus progress/settings
/// entry points).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final content = app.content!;
    final progress = app.progress;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights_outlined),
            tooltip: 'Progress',
            onPressed: () => Navigator.pushNamed(context, '/progress'),
          ),
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
              _OverallCard(overall: overall),
              const SizedBox(height: 8),
              _ReviewCta(count: progress.reviewQueue(content.allCharacters).length),
              if (content.warnings.isNotEmpty) ...[
                const SizedBox(height: 8),
                _DataWarningBanner(
                  count: content.skippedRecords,
                  warnings: content.warnings.length,
                ),
              ],
              const SizedBox(height: 16),
              Text(
                'Topics',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
              ),
              const SizedBox(height: 8),
              if (content.topics.isEmpty)
                const _EmptyTopics()
              else
                for (final topic in content.topics)
                  TopicTile(
                    name: topic.name,
                    counts: progress.topicCounts(topic),
                    onTap: () =>
                        Navigator.pushNamed(context, '/topic', arguments: topic),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _OverallCard extends StatelessWidget {
  const _OverallCard({required this.overall});

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
              'Learn',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
            ),
            Text(
              '${overall.learned} of ${overall.total} kanji learned',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: overall.fraction,
                minHeight: 10,
                backgroundColor: scheme.primaryContainer,
                color: scheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCta extends StatelessWidget {
  const _ReviewCta({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Icon(
          Icons.autorenew,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: const Text('Review'),
        subtitle: Text(
          count == 0
              ? 'Everything learned — nice!'
              : '$count kanji to review',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.pushNamed(context, '/review'),
      ),
    );
  }
}

class _DataWarningBanner extends StatelessWidget {
  const _DataWarningBanner({required this.count, required this.warnings});

  final int count;
  final int warnings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              count > 0
                  ? 'Some kanji records were skipped ($count).'
                  : 'Data loaded with $warnings warning(s).',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTopics extends StatelessWidget {
  const _EmptyTopics();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Text(
        'No topics yet — add entries to assets/topics.json.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}