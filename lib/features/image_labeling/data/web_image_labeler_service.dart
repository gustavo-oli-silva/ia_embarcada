import 'dart:math';
import '../domain/analysis_result.dart';
import 'image_labeler_service.dart';

/// Implementação de [ImageLabelerService] para execução no navegador (Edge/Chrome).
///
/// Como o Google ML Kit é uma biblioteca nativa para dispositivos móveis
/// (Android/iOS), esta classe fornece uma inferência simulada no navegador
/// para permitir testar a interface, o slider do limiar e a alternância
/// de visualização sem exibir tela branca ou erros.
class WebImageLabelerService implements ImageLabelerService {
  const WebImageLabelerService();

  static const List<LabelResult> _samplePool = [
    LabelResult(text: 'Device', confidence: 0.96),
    LabelResult(text: 'Technology', confidence: 0.91),
    LabelResult(text: 'Electronic component', confidence: 0.84),
    LabelResult(text: 'Gadget', confidence: 0.77),
    LabelResult(text: 'Computer hardware', confidence: 0.68),
    LabelResult(text: 'Office equipment', confidence: 0.58),
    LabelResult(text: 'Desk', confidence: 0.49),
    LabelResult(text: 'Room', confidence: 0.35),
    LabelResult(text: 'Artificial object', confidence: 0.28),
  ];

  @override
  Future<AnalysisResult> analyze(String imagePath, double threshold) async {
    // Simula o tempo real de processamento do modelo on-device (entre 20 e 45 ms)
    final random = Random();
    final simulatedElapsedMs = 25 + random.nextInt(20);
    await Future<void>.delayed(Duration(milliseconds: simulatedElapsedMs));

    // Filtra pelo limiar e ordena de forma decrescente
    final filtered = _samplePool
        .where((item) => item.confidence >= threshold)
        .toList()
      ..sort((a, b) => b.confidence.compareTo(a.confidence));

    return AnalysisResult(
      labels: filtered,
      elapsedMs: simulatedElapsedMs,
    );
  }
}

