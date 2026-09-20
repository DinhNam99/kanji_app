import 'package:flutter/material.dart';

import '../../domain/models/kanji_state.dart';
import 'progress_bar.dart';

/// One topic in the Home topic list: name, counts and a progress bar.
class TopicTile extends StatelessWidget {
  const TopicTile({
    super.key,
    required this.name,
    required this.counts,
    required this.onTap,
  });

  final String name;
  final ProgressCounts counts;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    '${counts.learned}/${counts.total}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ProgressBar(fraction: counts.fraction),
            ],
          ),
        ),
      ),
    );
  }
}