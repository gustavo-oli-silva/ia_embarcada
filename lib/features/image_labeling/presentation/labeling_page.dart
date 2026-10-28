import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../settings/domain/app_settings.dart';
import '../../settings/presentation/settings_controller.dart';
import '../../settings/presentation/settings_page.dart';
import 'labeling_controller.dart';
import 'widgets/labels_cards_view.dart';
import 'widgets/labels_list_view.dart';

/// Tela principal do aplicativo para captura da foto, exibição da imagem,
/// métricas de tempo da inferência e listagem dos rótulos reconhecidos.
class LabelingPage extends StatefulWidget {
  const LabelingPage({
    super.key,
    required this.labelingController,
    required this.settingsController,
  });

  final LabelingController labelingController;
  final SettingsController settingsController;

  @override
  State<LabelingPage> createState() => _LabelingPageState();
}

class _LabelingPageState extends State<LabelingPage> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        widget.labelingController,
        widget.settingsController,
      ]),
      builder: (context, _) {
        final theme = Theme.of(context);
        final labeling = widget.labelingController;
        final settings = widget.settingsController;
        final imagePath = labeling.imagePath;
        final result = labeling.result;

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('IA Embarcada'),
                Text(
                  'ML Kit on-device (sem internet)',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Ajustes',
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => _openSettings(context),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (kIsWeb) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.public,
                          color: theme.colorScheme.onSecondaryContainer,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Modo Navegador (Edge): Interface e ajustes ativos. A IA embarcada real (ML Kit) roda diretamente no processador do Android via APK.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Barra de botões de captura
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.photo_library_outlined),
                        label: const Text('Galeria'),
                        onPressed: labeling.isLoading
                            ? null
                            : () => labeling.pickAndAnalyze(
                                  ImageSource.gallery,
                                  settings.threshold,
                                ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.tonalIcon(
                        icon: const Icon(Icons.camera_alt_outlined),
                        label: const Text('Câmera'),
                        onPressed: labeling.isLoading
                            ? null
                            : () => labeling.pickAndAnalyze(
                                  ImageSource.camera,
                                  settings.threshold,
                                ),
                      ),
                    ),
                    if (imagePath != null) ...[
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        tooltip: 'Limpar',
                        icon: const Icon(Icons.close_rounded),
                        onPressed: labeling.isLoading ? null : labeling.clear,
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 16),

                // Prévia da imagem
                if (imagePath != null)
                  _buildImagePreview(theme, labeling)
                else
                  _buildEmptyPlaceholder(theme),

                const SizedBox(height: 16),

                // Banner de métricas (Limiar e Tempo de resposta em ms)
                _buildMetricsBanner(theme, settings, labeling),

                const SizedBox(height: 16),

                // Área de resultados da inferência
                _buildResultsArea(theme, settings, labeling, result),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePreview(ThemeData theme, LabelingController labeling) {
    final bytes = labeling.imageBytes;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 260),
        color: theme.colorScheme.surfaceContainerHighest,
        width: double.infinity,
        child: bytes != null && bytes.isNotEmpty
            ? Image.memory(
                bytes,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    _buildFileFallback(theme, labeling.imagePath),
              )
            : _buildFileFallback(theme, labeling.imagePath),
      ),
    );
  }

  Widget _buildFileFallback(ThemeData theme, String? path) {
    final fileName = path != null
        ? path.split(RegExp(r'[\\/]')).last
        : 'Imagem selecionada';

    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image, size: 48, color: theme.colorScheme.primary),
          const SizedBox(height: 8),
          Text(
            'Imagem selecionada:',
            style: theme.textTheme.labelMedium,
          ),
          Text(
            fileName,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyPlaceholder(ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
        child: Column(
          children: [
            Icon(
              Icons.add_photo_alternate_outlined,
              size: 56,
              color: theme.colorScheme.primary.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 12),
            Text(
              'Nenhuma foto selecionada',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Escolha uma imagem da galeria ou use a câmera para testar a IA embarcada.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsBanner(
    ThemeData theme,
    SettingsController settings,
    LabelingController labeling,
  ) {
    final result = labeling.result;

    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMetricItem(
              theme: theme,
              icon: Icons.tune_rounded,
              label: 'Limiar Atual',
              value: settings.threshold.toStringAsFixed(2),
            ),
            Container(
              height: 32,
              width: 1,
              color: theme.colorScheme.outlineVariant,
            ),
            _buildMetricItem(
              theme: theme,
              icon: Icons.timer_outlined,
              label: 'Tempo de IA',
              value: result != null ? '${result.elapsedMs} ms' : '--',
            ),
            Container(
              height: 32,
              width: 1,
              color: theme.colorScheme.outlineVariant,
            ),
            _buildMetricItem(
              theme: theme,
              icon: Icons.label_outline_rounded,
              label: 'Rótulos',
              value: result != null ? '${result.labels.length}' : '--',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildResultsArea(
    ThemeData theme,
    SettingsController settings,
    LabelingController labeling,
    dynamic result,
  ) {
    if (labeling.isLoading) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Executando inferência on-device...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'O modelo está processando a imagem no chip do aparelho.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (labeling.errorMessage != null) {
      return Card(
        color: theme.colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: theme.colorScheme.error),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  labeling.errorMessage!,
                  style: TextStyle(color: theme.colorScheme.onErrorContainer),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (labeling.imagePath != null && result != null) {
      if (result.isEmpty) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(
                  Icons.search_off_rounded,
                  size: 40,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(height: 12),
                Text(
                  'Nenhum rótulo acima do limiar (${settings.threshold.toStringAsFixed(2)})',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  'O modelo não teve certeza suficiente para ultrapassar a nota mínima. '
                  'Toque na engrenagem no topo e diminua o limiar (ex: 0.3) para visualizar palpites adicionais.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rótulos Reconhecidos',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${result.labels.length} item(s)',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (settings.displayMode == DisplayMode.list)
                LabelsListView(labels: result.labels)
              else
                LabelsCardsView(labels: result.labels),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Future<void> _openSettings(BuildContext context) async {
    final oldThreshold = widget.settingsController.threshold;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SettingsPage(controller: widget.settingsController),
      ),
    );

    // Reanálise automática caso o limiar tenha sido alterado nos ajustes
    final newThreshold = widget.settingsController.threshold;
    if ((newThreshold - oldThreshold).abs() > 0.001 &&
        widget.labelingController.imagePath != null) {
      await widget.labelingController.reanalyze(newThreshold);
    }
  }
}
