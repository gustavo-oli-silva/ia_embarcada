import 'package:flutter/material.dart';
import 'app.dart';
import 'services/app_database.dart';
import 'services/settings_repository.dart';
import 'controllers/settings_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SettingsRepository settingsRepository;

  try {
    final databaseFuture = AppDatabase.open();
    settingsRepository = SqfliteSettingsRepository(databaseFuture);
  } catch (e) {
    debugPrint('Falha ao abrir SQLite, usando fallback em memória: $e');
    settingsRepository = InMemorySettingsRepository();
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
