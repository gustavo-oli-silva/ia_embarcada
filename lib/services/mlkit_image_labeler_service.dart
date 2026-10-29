import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import '../models/analysis_result.dart';
import 'image_labeler_service.dart';

/// Implementação de [ImageLabelerService] que utiliza o Google ML Kit
/// para executar rotulagem de imagens (Image Labeling) diretamente no aparelho
/// (on-device / IA embarcada), sem envio de dados para servidores.
class MlKitImageLabelerService implements ImageLabelerService {
  const MlKitImageLabelerService();

  @override
  Future<AnalysisResult> analyze(String imagePath, double threshold) async {
    // -------------------------------------------------------------
    // PASSO 2 DO ROTEIRO: Converter a foto para o formato do ML Kit
    // -------------------------------------------------------------
    final inputImage = InputImage.fromFilePath(imagePath);

    // -------------------------------------------------------------
    // PASSO 3 DO ROTEIRO: Criar o rotulador passando o limiar
    // Cada chamada instancia o rotulador com a nota mínima configurada.
    // -------------------------------------------------------------
    final options = ImageLabelerOptions(confidenceThreshold: threshold);
    final labeler = ImageLabeler(options: options);

    try {
      // Medimos com precisão apenas o tempo de inferência on-device (IA pura)
      final stopwatch = Stopwatch()..start();

      // -------------------------------------------------------------
      // PASSO 4 DO ROTEIRO: Rodar a inferência (onde a IA "pensa")
      // O modelo embutido processa os pixels no processador local.
      // -------------------------------------------------------------
      final labels = await labeler.processImage(inputImage);

      stopwatch.stop();

      // Mapeia para o modelo de domínio da aplicação e ordena por confiança decrescente
      final results = labels
          .map((label) => LabelResult(
                text: label.label,
                confidence: label.confidence,
              ))
          .toList()
        ..sort((a, b) => b.confidence.compareTo(a.confidence));

      return AnalysisResult(
        labels: results,
        elapsedMs: stopwatch.elapsedMilliseconds,
      );
    } finally {
      // Libera os recursos nativos alocados pelo modelo no dispositivo
      try {
        await labeler.close();
      } catch (_) {}
    }
  }
}

