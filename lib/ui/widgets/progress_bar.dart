import 'package:flutter/material.dart';

/// Thin wrapper around [LinearProgressIndicator] with a label row.
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.fraction,
    this.label,
    this.height = 10,
  });

  final double fraction;
  final String? label;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: fraction.clamp(0.0, 1.0).toDouble(),
            minHeight: height,
            backgroundColor: scheme.surfaceContainerHighest,
            color: scheme.primary,
          ),
        ),
      ],
    );
  }
}