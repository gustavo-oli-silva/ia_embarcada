import 'package:flutter/material.dart';
import '../../domain/analysis_result.dart';

/// Exibição dos rótulos em formato de lista detalhada, com barra de progresso.
class LabelsListView extends StatelessWidget {
  const LabelsListView({
    super.key,
    required this.labels,
  });

  final List<LabelResult> labels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: labels.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = labels[index];
        final percent = item.percentage;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.text,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _colorForConfidence(theme, item.confidence),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$percent%',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: item.confidence,
                  minHeight: 6,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _colorForConfidence(theme, item.confidence),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _colorForConfidence(ThemeData theme, double confidence) {
    if (confidence >= 0.80) {
      return Colors.green.shade600;
    } else if (confidence >= 0.50) {
      return Colors.blue.shade600;
    } else {
      return Colors.orange.shade700;
    }
  }
}
