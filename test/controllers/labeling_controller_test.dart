import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ia_embarcada/services/image_labeler_service.dart';
import 'package:ia_embarcada/models/analysis_result.dart';
import 'package:ia_embarcada/controllers/labeling_controller.dart';

class FakeImageLabelerService implements ImageLabelerService {
  FakeImageLabelerService({
    this.labels = const [],
    this.shouldThrow = false,
  });

  final List<LabelResult> labels;
  final bool shouldThrow;

  double? capturedThreshold;
  String? capturedPath;

  @override
  Future<AnalysisResult> analyze(String imagePath, double threshold) async {
    if (shouldThrow) {
      throw Exception('Falha simulada na inferência');
    }

    capturedPath = imagePath;
    capturedThreshold = threshold;

    final filtered =
        labels.where((item) => item.confidence >= threshold).toList();

    return AnalysisResult(
      labels: filtered,
      elapsedMs: 35,
    );
  }
}

void main() {
  group('LabelingController', () {
    test('pickAndAnalyze processa imagem com sucesso', () async {
      final fakeService = FakeImageLabelerService(
        labels: const [
          LabelResult(text: 'Dog', confidence: 0.92),
          LabelResult(text: 'Pet', confidence: 0.75),
          LabelResult(text: 'Animal', confidence: 0.40),
        ],
      );

      final controller = LabelingController(
        service: fakeService,
        pickImageFn: (_) async => XFile.fromData(
          Uint8List.fromList([0, 1, 2]),
          path: 'test/sample.jpg',
        ),
      );

      await controller.pickAndAnalyze(ImageSource.gallery, 0.50);

      expect(controller.imagePath, 'test/sample.jpg');
      expect(controller.isLoading, isFalse);
      expect(controller.errorMessage, isNull);
      expect(controller.lastThreshold, 0.50);

      final result = controller.result;
      expect(result, isNotNull);
      expect(result!.labels.length, 2); // Dog (0.92) e Pet (0.75)
      expect(result.labels.first.text, 'Dog');
      expect(result.elapsedMs, 35);
    });

    test('reanalyze reprocessa a imagem atual com novo limiar', () async {
      final fakeService = FakeImageLabelerService(
        labels: const [
          LabelResult(text: 'Dog', confidence: 0.92),
          LabelResult(text: 'Pet', confidence: 0.75),
          LabelResult(text: 'Animal', confidence: 0.40),
        ],
      );

      final controller = LabelingController(
        service: fakeService,
        pickImageFn: (_) async => XFile.fromData(
          Uint8List.fromList([0, 1, 2]),
          path: 'test/sample.jpg',
        ),
      );

      await controller.pickAndAnalyze(ImageSource.gallery, 0.50);
      expect(controller.result!.labels.length, 2);

      // Reanalisa com limiar alto (0.90)
      await controller.reanalyze(0.90);
      expect(controller.lastThreshold, 0.90);
      expect(controller.result!.labels.length, 1);
      expect(controller.result!.labels.first.text, 'Dog');
    });

    test('não altera estado quando usuário cancela seleção da foto', () async {
      final fakeService = FakeImageLabelerService();
      final controller = LabelingController(
        service: fakeService,
        pickImageFn: (_) async => null, // Cancelou
      );

      await controller.pickAndAnalyze(ImageSource.camera, 0.50);

      expect(controller.imagePath, isNull);
      expect(controller.result, isNull);
      expect(controller.errorMessage, isNull);
      expect(fakeService.capturedPath, isNull);
    });

    test('define mensagem de erro quando inferência falha', () async {
      final fakeService = FakeImageLabelerService(shouldThrow: true);
      final controller = LabelingController(
        service: fakeService,
        pickImageFn: (_) async => XFile.fromData(
          Uint8List.fromList([0, 1]),
          path: 'test/corrupted.jpg',
        ),
      );

      await controller.pickAndAnalyze(ImageSource.gallery, 0.50);

      expect(controller.isLoading, isFalse);
      expect(controller.result, isNull);
      expect(controller.errorMessage, contains('Falha simulada'));
    });
  });
}

