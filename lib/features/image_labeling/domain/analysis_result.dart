/// Representa um rótulo individual inferido pelo modelo on-device.
class LabelResult {
  const LabelResult({
    required this.text,
    required this.confidence,
  });

  /// Nome do rótulo reconhecido (em inglês pelo modelo base do ML Kit).
  final String text;

  /// Grau de certeza do modelo entre 0.0 e 1.0.
  final double confidence;

  /// Porcentagem inteira de confiança (ex: 92 para 92%).
  int get percentage => (confidence * 100).round();

  @override
  String toString() => '$text ($percentage%)';
}

/// Resultado completo da inferência on-device de uma imagem.
class AnalysisResult {
  const AnalysisResult({
    required this.labels,
    required this.elapsedMs,
  });

  /// Lista de rótulos detectados acima do limiar configurado.
  final List<LabelResult> labels;

  /// Tempo de inferência pura (em milissegundos) decorrido no processador.
  final int elapsedMs;

  bool get isEmpty => labels.isEmpty;
  bool get isNotEmpty => labels.isNotEmpty;
}

