import 'package:flutter/foundation.dart';
import '../services/settings_repository.dart';
import '../models/app_settings.dart';

/// Controlador observável para gerenciamento das preferências do usuário.
class SettingsController extends ChangeNotifier {
  SettingsController(this._repository);

  final SettingsRepository _repository;

  AppSettings _settings = const AppSettings();
  bool _isLoaded = false;

  AppSettings get settings => _settings;
  double get threshold => _settings.threshold;
  DisplayMode get displayMode => _settings.displayMode;
  bool get isLoaded => _isLoaded;

  /// Carrega as configurações do repositório SQLite.
  Future<void> load() async {
    _settings = await _repository.load();
    _isLoaded = true;
    notifyListeners();
  }

  /// Atualiza o limiar de confiança e persiste a alteração.
  Future<void> setThreshold(double newThreshold) async {
    final clamped = newThreshold.clamp(
      SettingsRepository.minThreshold,
      SettingsRepository.maxThreshold,
    );
    // Arredonda para 2 casas decimais (compatível com steps de 0.05)
    final rounded = (clamped * 100).roundToDouble() / 100;
    if ((_settings.threshold - rounded).abs() < 0.001) return;

    _settings = _settings.copyWith(threshold: rounded);
    notifyListeners();
    await _repository.save(_settings);
  }

  /// Atualiza o modo de exibição (lista ou cards) e persiste a alteração.
  Future<void> setDisplayMode(DisplayMode newMode) async {
    if (_settings.displayMode == newMode) return;

    _settings = _settings.copyWith(displayMode: newMode);
    notifyListeners();
    await _repository.save(_settings);
  }
}

