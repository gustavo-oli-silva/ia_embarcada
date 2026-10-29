import 'package:flutter/material.dart';
import '../../models/analysis_result.dart';

/// Exibição dos rótulos em formato de grade de cartões com destaque visual.
class LabelsCardsView extends StatelessWidget {
  const LabelsCardsView({
    super.key,
    required this.labels,
  });

  final List<LabelResult> labels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: labels.map((item) {
        final percent = item.percentage;
        final color = _colorForConfidence(item.confidence);

        return Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Text(
                    '$percent',
                    style: TextStyle(
                      color: color,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.text,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // Rótulo original do modelo, quando foi traduzido
                    if (item.originalText != null &&
                        item.originalText != item.text)
                      Text(
                        item.originalText!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Color _colorForConfidence(double confidence) {
    if (confidence >= 0.80) {
      return Colors.green.shade700;
    } else if (confidence >= 0.50) {
      return Colors.blue.shade700;
    } else {
      return Colors.orange.shade800;
    }
  }
}

