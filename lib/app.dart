import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'services/image_labeler_service.dart';
import 'services/mlkit_image_labeler_service.dart';
import 'controllers/labeling_controller.dart';
import 'views/labeling_page.dart';
import 'controllers/settings_controller.dart';

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
    final effectiveService =
        imageLabelerService ?? const MlKitImageLabelerService();

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
