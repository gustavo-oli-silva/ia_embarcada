import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/image_labeling/data/image_labeler_service.dart';
import 'features/image_labeling/data/mlkit_image_labeler_service.dart';
import 'features/image_labeling/data/web_image_labeler_service.dart';
import 'features/image_labeling/presentation/labeling_controller.dart';
import 'features/image_labeling/presentation/labeling_page.dart';
import 'features/settings/presentation/settings_controller.dart';

/// Widget raiz da aplicação IA Embarcada.
class App extends StatelessWidget {
  const App({
    super.key,
    required this.settingsController,
    this.labelingController,
    this.imageLabelerService,
  });

  final SettingsController settingsController;
  final LabelingController? labelingController;
  final ImageLabelerService? imageLabelerService;

  @override
  Widget build(BuildContext context) {
    final effectiveService = imageLabelerService ??
        (kIsWeb
            ? const WebImageLabelerService()
            : const MlKitImageLabelerService());

    final effectiveLabelingController = labelingController ??
        LabelingController(
          service: effectiveService,
        );

    return MaterialApp(
      title: 'IA Embarcada',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: LabelingPage(
        labelingController: effectiveLabelingController,
        settingsController: settingsController,
      ),
    );
  }
}
