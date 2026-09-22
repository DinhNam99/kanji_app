import 'package:flutter/material.dart';

import '../../domain/models/kanji_state.dart';
import 'progress_bar.dart';

/// One topic on Home: index, name, learned/total counts, completion badge and
/// a progress bar. Renders both in the phone list and the tablet grid.
///
/// Exposes a single semantic node (button + combined label) so screen readers
/// announce name and progress as one item (issue #10, P3).
class TopicCard extends StatelessWidget {
  const TopicCard({
    super.key,
    required this.index,
    required this.name,
    required this.counts,
    required this.onTap,
  });

  /// 1-based position in the curriculum.
  final int index;
  final String name;
  final ProgressCounts counts;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final complete = counts.total > 0 && counts.learned == counts.total;

    return Semantics(
      button: true,
      excludeSemantics: true,
      label: '$name, ${counts.learned} of ${counts.total} learned'
          '${complete ? ', complete' : ''}',
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: scheme.primary.withOpacity(0.10),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$index',
                        style: textTheme.labelSmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    Text(
                      '${counts.learned}/${counts.total}',
                      style: textTheme.bodyMedium
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    if (complete) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.check_circle, size: 18, color: scheme.primary),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                ProgressBar(fraction: counts.fraction),
                if (counts.learning > 0 && !complete) ...[
                  const SizedBox(height: 6),
                  Text(
                    '${counts.learning} in progress',
                    style: textTheme.bodySmall?.copyWith(color: scheme.primary),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
