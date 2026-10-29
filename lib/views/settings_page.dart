import 'package:flutter/material.dart';
import '../models/app_settings.dart';
import '../controllers/settings_controller.dart';

/// Tela de ajustes do aplicativo onde o usuário configura o limiar de confiança
/// da inferência e a forma visual de exibição dos resultados.
class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.controller,
  });

  final SettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: ListenableBuilder(
        listenable: controller,
        builder: (context, _) {
          final theme = Theme.of(context);
          final threshold = controller.threshold;
          final displayMode = controller.displayMode;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Card do Limiar
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Limiar de Confiança',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              threshold.toStringAsFixed(2),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Define a nota mínima (0 a 1) para que um rótulo reconhecido seja mostrado.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Slider com passos de 0.05
                      Slider(
                        value: threshold,
                        min: 0.10,
                        max: 0.95,
                        divisions: 17,
                        label: threshold.toStringAsFixed(2),
                        onChanged: (value) => controller.setThreshold(value),
                      ),

                      // Atalhos sugeridos para a atividade prática
                      const SizedBox(height: 8),
                      Text(
                        'Atalhos sugeridos para a aula:',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: [0.30, 0.60, 0.90].map((val) {
                          final isSelected = (threshold - val).abs() < 0.01;
                          return ChoiceChip(
                            label: Text(val.toStringAsFixed(1)),
                            selected: isSelected,
                            onSelected: (_) => controller.setThreshold(val),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '💡 Como o limiar se comporta:',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '• Baixo (0.3): aparecem muitos rótulos, inclusive palpites errados.\n'
                              '• Alto (0.9): aparecem poucos, apenas os que o modelo tem alta certeza.',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Card do Modo de Exibição
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Modo de Exibição',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Escolha como visualizar a lista de rótulos e as porcentagens.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: SegmentedButton<DisplayMode>(
                          segments: const [
                            ButtonSegment(
                              value: DisplayMode.list,
                              label: Text('Lista'),
                              icon: Icon(Icons.view_list_rounded),
                            ),
                            ButtonSegment(
                              value: DisplayMode.cards,
                              label: Text('Cards'),
                              icon: Icon(Icons.grid_view_rounded),
                            ),
                          ],
                          selected: {displayMode},
                          onSelectionChanged: (selected) {
                            if (selected.isNotEmpty) {
                              controller.setDisplayMode(selected.first);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Informações sobre persistência local (sqflite)
              Center(
                child: Text(
                  'Configurações salvas automaticamente no SQLite local.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

