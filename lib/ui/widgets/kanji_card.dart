import 'package:flutter/material.dart';

/// A big kanji card. Tapping the back of an unrevealed card reveals its
/// reading and meaning. Both on-yomi and kun-yomi are listed so beginners
/// see the readings that exist, while the hero reading is the curated one.
class KanjiCard extends StatelessWidget {
  const KanjiCard({
    super.key,
    required this.character,
    required this.reading,
    required this.meaning,
    this.onReadings = const [],
    this.kunReadings = const [],
    this.revealed = false,
    this.onReveal,
  });

  final String character;

  /// Curated display reading (from topics.json or the dataset default).
  final String? reading;

  final String? meaning;
  final List<String> onReadings;
  final List<String> kunReadings;
  final bool revealed;
  final VoidCallback? onReveal;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      label: revealed
          ? '$character, pronounced $reading, meaning $meaning'
          : '$character, tap to reveal reading and meaning',
      child: Card(
        elevation: 2,
        color: scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: revealed ? null : onReveal,
          child: SizedBox(
            height: 360,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // The kanji itself — always visible, always large.
                Text(
                  character,
                  style: textTheme.displayLarge?.copyWith(
                    fontSize: 120,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                if (!revealed) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Tap for reading',
                    style: textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 28),
                  _HeroReading(scheme: scheme, reading: reading, textTheme: textTheme),
                  const SizedBox(height: 12),
                  Text(
                    meaning ?? '',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall?.copyWith(
                      color: scheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (kunReadings.isNotEmpty || onReadings.isNotEmpty)
                    _ReadingList(
                      scheme: scheme,
                      textTheme: textTheme,
                      on: onReadings,
                      kun: kunReadings,
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

class _HeroReading extends StatelessWidget {
  const _HeroReading({
    required this.scheme,
    required this.reading,
    required this.textTheme,
  });

  final ColorScheme scheme;
  final String? reading;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final reading = this.reading;
    if (reading == null) {
      return const SizedBox.shrink();
    }
    return Text(
      reading,
      style: textTheme.headlineMedium?.copyWith(
        fontSize: 44,
        color: scheme.primary,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _ReadingList extends StatelessWidget {
  const _ReadingList({
    required this.scheme,
    required this.textTheme,
    required this.on,
    required this.kun,
  });

  final ColorScheme scheme;
  final TextTheme textTheme;
  final List<String> on;
  final List<String> kun;

  @override
  Widget build(BuildContext context) {
    Widget line(String label, List<String> readings) {
      if (readings.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Text(
          '$label ${readings.join(' ・ ')}',
          style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        line('音', on),
        line('訓', kun),
      ],
    );
  }
}