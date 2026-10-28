import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'features/settings/data/app_database.dart';
import 'features/settings/data/settings_repository.dart';
import 'features/settings/presentation/settings_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SettingsRepository settingsRepository;

  if (kIsWeb) {
    // No navegador (Edge/Chrome), usa o repositório em memória
    // evitando a dependência de plugins nativos de SQLite não suportados na Web.
    settingsRepository = InMemorySettingsRepository();
  } else {
    try {
      final databaseFuture = AppDatabase.open();
      settingsRepository = SqfliteSettingsRepository(databaseFuture);
    } catch (e) {
      debugPrint('Falha ao abrir SQLite, usando fallback em memória: $e');
      settingsRepository = InMemorySettingsRepository();
    }
  }

  final settingsController = SettingsController(settingsRepository);

  try {
    await settingsController.load();
  } catch (e) {
    debugPrint('Falha ao carregar ajustes: $e');
  }

  runApp(
    App(
      settingsController: settingsController,
    ),
  );
}
