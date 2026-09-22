import 'package:flutter/material.dart';

import '../../app.dart';
import '../../app_scope.dart';
import '../../domain/models/kanji_state.dart';
import '../../domain/models/topic.dart';
import '../widgets/progress_bar.dart';
import '../widgets/topic_card.dart';

/// Home = overall progress header + the topic grid/list (plus progress/settings
/// entry points). Content is capped to a centered 600dp column on wide screens
/// and switches the topic list to a 2-column grid at >= 600dp (issue #10).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final content = app.content!;
    final progress = app.progress;
    final scheme = Theme.of(context).colorScheme;
    final wide = MediaQuery.sizeOf(context).width >= 600;

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
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SizedBox(
                width: double.infinity,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _OverallCard(
                      overall: overall,
                      resumeTopic: app.resumeTopic,
                    ),
                    const SizedBox(height: 8),
                    _ReviewCta(
                      count: progress
                          .reviewQueue(content.allCharacters)
                          .length,
                    ),
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
                    else if (wide)
                      _TopicGrid(
                        topics: content.topics,
                        countsOf: progress.topicCounts,
                        onOpen: (topic) => Navigator.pushNamed(
                          context,
                          '/topic',
                          arguments: topic,
                        ),
                      )
                    else
                      for (var i = 0; i < content.topics.length; i++) ...[
                        if (i > 0) const SizedBox(height: 8),
                        TopicCard(
                          index: i + 1,
                          name: content.topics[i].name,
                          counts: progress.topicCounts(content.topics[i]),
                          onTap: () => Navigator.pushNamed(
                            context,
                            '/topic',
                            arguments: content.topics[i],
                          ),
                        ),
                      ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OverallCard extends StatelessWidget {
  const _OverallCard({required this.overall, this.resumeTopic});

  final ProgressCounts overall;

  /// First topic with unlearned kanji; null hides the "Continue" CTA.
  final Topic? resumeTopic;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final notStarted = overall.total - overall.learned - overall.learning;
    final topic = resumeTopic;
    return Card(
      color: scheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Overall Progress',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '${overall.learned} of ${overall.total} kanji learned',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '${overall.learning} in progress · $notStarted not started',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onPrimaryContainer.withOpacity(0.8),
                  ),
            ),
            const SizedBox(height: 12),
            ProgressBar(fraction: overall.fraction),
            if (topic != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => Navigator.pushNamed(
                  context,
                  '/learning',
                  arguments: topic,
                ),
                icon: const Icon(Icons.play_arrow),
                label: const Text('Continue'),
              ),
            ],
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
    final scheme = Theme.of(context).colorScheme;
    final due = count > 0;
    return Card(
      clipBehavior: Clip.antiAlias,
      color: due ? scheme.secondaryContainer : null,
      child: ListTile(
        leading: Icon(
          due ? Icons.history : Icons.check_circle_outline,
          color: due ? scheme.onSecondaryContainer : scheme.primary,
        ),
        title: Text(
          'Review',
          style: due
              ? TextStyle(
                  color: scheme.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                )
              : null,
        ),
        subtitle: Text(
          due ? '$count kanji to review' : 'All caught up!',
          style: due
              ? TextStyle(color: scheme.onSecondaryContainer.withOpacity(0.8))
              : null,
        ),
        trailing: due ? const Icon(Icons.chevron_right) : null,
        // Always tappable: the review screen renders its own "nothing to
        // review" empty state, and tests reach it through this CTA.
        onTap: () => Navigator.pushNamed(context, '/review'),
      ),
    );
  }
}

/// Two-column topic grid for wide (>= 600dp) layouts. Lives inside the Home
/// ListView, so it must not scroll on its own.
class _TopicGrid extends StatelessWidget {
  const _TopicGrid({
    required this.topics,
    required this.countsOf,
    required this.onOpen,
  });

  final List<Topic> topics;
  final ProgressCounts Function(Topic) countsOf;
  final ValueChanged<Topic> onOpen;

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 112,
      ),
      children: [
        for (var i = 0; i < topics.length; i++)
          TopicCard(
            index: i + 1,
            name: topics[i].name,
            counts: countsOf(topics[i]),
            onTap: () => onOpen(topics[i]),
          ),
      ],
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
        'No topics available yet — check back soon.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
