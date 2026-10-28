/// Modo de exibição dos rótulos reconhecidos pela IA.
enum DisplayMode {
  list,
  cards,
}

/// Representa as configurações de inferência e exibição do app.
class AppSettings {
  const AppSettings({
    this.threshold = 0.5,
    this.displayMode = DisplayMode.list,
  });

  /// Limiar de confiança do modelo (entre 0.1 e 0.95).
  /// Apenas rótulos com confiança maior ou igual a este valor são exibidos.
  final double threshold;

  /// Formato visual da apresentação dos resultados.
  final DisplayMode displayMode;

  AppSettings copyWith({
    double? threshold,
    DisplayMode? displayMode,
  }) {
    return AppSettings(
      threshold: threshold ?? this.threshold,
      displayMode: displayMode ?? this.displayMode,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          runtimeType == other.runtimeType &&
          threshold == other.threshold &&
          displayMode == other.displayMode;

  @override
  int get hashCode => Object.hash(threshold, displayMode);

  @override
  String toString() =>
      'AppSettings(threshold: $threshold, displayMode: $displayMode)';
}

