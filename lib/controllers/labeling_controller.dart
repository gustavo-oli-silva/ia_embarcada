import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../services/image_labeler_service.dart';
import '../models/analysis_result.dart';

typedef ImagePickFunction = Future<XFile?> Function(ImageSource source);

/// Controlador de estado para o fluxo de captura, inferência e exibição.
class LabelingController extends ChangeNotifier {
  LabelingController({
    required this.service,
    ImagePickFunction? pickImageFn,
  }) : _pickImageFn = pickImageFn ?? _defaultPickImage;

  final ImageLabelerService service;
  final ImagePickFunction _pickImageFn;

  String? _imagePath;
  Uint8List? _imageBytes;
  AnalysisResult? _result;
  bool _isLoading = false;
  String? _errorMessage;
  double? _lastThreshold;

  String? get imagePath => _imagePath;
  Uint8List? get imageBytes => _imageBytes;
  AnalysisResult? get result => _result;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double? get lastThreshold => _lastThreshold;

  static Future<XFile?> _defaultPickImage(ImageSource source) {
    return ImagePicker().pickImage(
      source: source,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 90,
    );
  }

  /// Seleciona uma imagem da câmera ou galeria e roda a inferência.
  Future<void> pickAndAnalyze(ImageSource source, double threshold) async {
    try {
      // -------------------------------------------------------------
      // PASSO 1 DO ROTEIRO: Pegar a foto via image_picker
      // -------------------------------------------------------------
      final picked = await _pickImageFn(source);
      if (picked == null) {
        // Usuário cancelou a seleção da imagem (não é erro)
        return;
      }

      _imagePath = picked.path;
      try {
        _imageBytes = await picked.readAsBytes();
      } catch (_) {
        _imageBytes = null;
      }
      await _runInference(threshold);
    } catch (e) {
      _errorMessage = 'Falha ao selecionar imagem: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reanalisa a imagem atual com um novo limiar (por exemplo, ao voltar dos ajustes).
  Future<void> reanalyze(double threshold) async {
    if (_imagePath == null) return;
    await _runInference(threshold);
  }

  Future<void> _runInference(double threshold) async {
    final path = _imagePath;
    if (path == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final analysis = await service.analyze(path, threshold);
      _result = analysis;
      _lastThreshold = threshold;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Erro durante a inferência: $e';
      _result = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Limpa a imagem atual e os resultados.
  void clear() {
    _imagePath = null;
    _imageBytes = null;
    _result = null;
    _errorMessage = null;
    _lastThreshold = null;
    _isLoading = false;
    notifyListeners();
  }
}
