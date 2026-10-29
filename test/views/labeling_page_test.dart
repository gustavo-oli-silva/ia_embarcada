import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ia_embarcada/services/image_labeler_service.dart';
import 'package:ia_embarcada/models/analysis_result.dart';
import 'package:ia_embarcada/controllers/labeling_controller.dart';
import 'package:ia_embarcada/views/labeling_page.dart';
import 'package:ia_embarcada/views/widgets/labels_cards_view.dart';
import 'package:ia_embarcada/views/widgets/labels_list_view.dart';
import 'package:ia_embarcada/services/settings_repository.dart';
import 'package:ia_embarcada/models/app_settings.dart';
import 'package:ia_embarcada/controllers/settings_controller.dart';

class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository([this.settings = const AppSettings()]);
  AppSettings settings;

  @override
  Future<AppSettings> load() async => settings;

  @override
  Future<void> save(AppSettings s) async => settings = s;
}

class TestImageLabelerService implements ImageLabelerService {
  TestImageLabelerService(this.labels);
  final List<LabelResult> labels;

  @override
  Future<AnalysisResult> analyze(String imagePath, double threshold) async {
    final filtered =
        labels.where((item) => item.confidence >= threshold).toList();
    return AnalysisResult(labels: filtered, elapsedMs: 48);
  }
}

void main() {
  testWidgets('LabelingPage exibe estado inicial vazio', (tester) async {
    final settingsRepo = FakeSettingsRepository();
    final settingsController = SettingsController(settingsRepo);
    await settingsController.load();

    final labelingController = LabelingController(
      service: TestImageLabelerService(const []),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: LabelingPage(
          labelingController: labelingController,
          settingsController: settingsController,
        ),
      ),
    );

    expect(find.text('IA Embarcada'), findsOneWidget);
    expect(find.text('Nenhuma foto selecionada'), findsOneWidget);
    expect(find.text('Galeria'), findsOneWidget);
    expect(find.text('Câmera'), findsOneWidget);
  });

  testWidgets('LabelingPage exibe resultados em modo lista', (tester) async {
    final settingsRepo = FakeSettingsRepository();
    final settingsController = SettingsController(settingsRepo);
    await settingsController.load();

    final labelingController = LabelingController(
      service: TestImageLabelerService(const [
        LabelResult(text: 'Coffee', confidence: 0.94),
        LabelResult(text: 'Drink', confidence: 0.81),
      ]),
      pickImageFn: (_) async => XFile.fromData(
        Uint8List(0),
        path: 'test/coffee.jpg',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: LabelingPage(
          labelingController: labelingController,
          settingsController: settingsController,
        ),
      ),
    );

    // Executa a seleção e análise da imagem
    await labelingController.pickAndAnalyze(
      ImageSource.gallery,
      settingsController.threshold,
    );
    await tester.pumpAndSettle();

    expect(find.byType(LabelsListView), findsOneWidget);
    expect(find.text('Coffee'), findsOneWidget);
    expect(find.text('94%'), findsOneWidget);
    expect(find.text('Drink'), findsOneWidget);
    expect(find.text('81%'), findsOneWidget);
    expect(find.text('48 ms'), findsOneWidget);
  });

  testWidgets('LabelingPage exibe resultados em modo cards', (tester) async {
    final settingsRepo = FakeSettingsRepository();
    final settingsController = SettingsController(settingsRepo);
    await settingsController.load();
    await settingsController.setDisplayMode(DisplayMode.cards);

    final labelingController = LabelingController(
      service: TestImageLabelerService(const [
        LabelResult(text: 'Laptop', confidence: 0.89),
      ]),
      pickImageFn: (_) async => XFile.fromData(
        Uint8List(0),
        path: 'test/laptop.jpg',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: LabelingPage(
          labelingController: labelingController,
          settingsController: settingsController,
        ),
      ),
    );

    await labelingController.pickAndAnalyze(
      ImageSource.gallery,
      settingsController.threshold,
    );
    await tester.pumpAndSettle();

    expect(find.byType(LabelsCardsView), findsOneWidget);
    expect(find.text('Laptop'), findsOneWidget);
  });

  testWidgets('LabelingPage exibe aviso quando nenhum rótulo supera o limiar',
      (tester) async {
    final settingsRepo = FakeSettingsRepository();
    final settingsController = SettingsController(settingsRepo);
    await settingsController.load();
    await settingsController.setThreshold(0.95);

    final labelingController = LabelingController(
      service: TestImageLabelerService(const [
        LabelResult(text: 'Uncertain', confidence: 0.40),
      ]),
      pickImageFn: (_) async => XFile.fromData(
        Uint8List(0),
        path: 'test/blur.jpg',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: LabelingPage(
          labelingController: labelingController,
          settingsController: settingsController,
        ),
      ),
    );

    await labelingController.pickAndAnalyze(
      ImageSource.gallery,
      settingsController.threshold,
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Nenhum rótulo acima do limiar (0.95)'),
      findsOneWidget,
    );
  });
}

