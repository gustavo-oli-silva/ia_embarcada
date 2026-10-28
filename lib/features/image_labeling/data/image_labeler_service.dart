import '../domain/analysis_result.dart';

/// Contrato para serviços de rotulagem de imagens.
/// Permite injetar implementações mockadas em testes de widget e de unidade.
abstract class ImageLabelerService {
  /// Executa a análise on-device da imagem localizada em [imagePath]
  /// aplicando o limiar [threshold] na seleção dos rótulos.
  Future<AnalysisResult> analyze(String imagePath, double threshold);
}

