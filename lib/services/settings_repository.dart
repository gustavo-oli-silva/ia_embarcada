import 'package:sqflite/sqflite.dart';
import '../models/app_settings.dart';
import 'app_database.dart';

/// Contrato para persistência e recuperação das configurações do app.
abstract class SettingsRepository {
  static const double minThreshold = 0.1;
  static const double maxThreshold = 0.95;
  static const double defaultThreshold = 0.5;

  Future<AppSettings> load();
  Future<void> save(AppSettings settings);
}

/// Implementação do [SettingsRepository] utilizando SQLite local através do [sqflite].
class SqfliteSettingsRepository implements SettingsRepository {
  SqfliteSettingsRepository(this._databaseFuture);

  final Future<Database> _databaseFuture;

  static const String keyThreshold = 'threshold';
  static const String keyDisplayMode = 'display_mode';

  @override
  Future<AppSettings> load() async {
    final db = await _databaseFuture;
    final rows = await db.query(AppDatabase.tableSettings);

    final map = <String, String>{};
    for (final row in rows) {
      final key = row['key'] as String?;
      final value = row['value'] as String?;
      if (key != null && value != null) {
        map[key] = value;
      }
    }

    double threshold = SettingsRepository.defaultThreshold;
    if (map.containsKey(keyThreshold)) {
      final parsed = double.tryParse(map[keyThreshold]!);
      if (parsed != null) {
        threshold = parsed.clamp(
          SettingsRepository.minThreshold,
          SettingsRepository.maxThreshold,
        );
      }
    }

    DisplayMode displayMode = DisplayMode.list;
    if (map.containsKey(keyDisplayMode)) {
      final modeStr = map[keyDisplayMode];
      if (modeStr == DisplayMode.cards.name) {
        displayMode = DisplayMode.cards;
      } else {
        displayMode = DisplayMode.list;
      }
    }

    return AppSettings(
      threshold: threshold,
      displayMode: displayMode,
    );
  }

  @override
  Future<void> save(AppSettings settings) async {
    final db = await _databaseFuture;
    final clampedThreshold = settings.threshold.clamp(
      SettingsRepository.minThreshold,
      SettingsRepository.maxThreshold,
    );

    await db.transaction((txn) async {
      await txn.insert(
        AppDatabase.tableSettings,
        {
          'key': keyThreshold,
          'value': clampedThreshold.toStringAsFixed(2),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await txn.insert(
        AppDatabase.tableSettings,
        {
          'key': keyDisplayMode,
          'value': settings.displayMode.name,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }
}

/// Implementação em memória de [SettingsRepository], usada como fallback quando
/// o SQLite não pode ser aberto e nos testes de widget.
class InMemorySettingsRepository implements SettingsRepository {
  InMemorySettingsRepository([this._settings = const AppSettings()]);

  AppSettings _settings;

  @override
  Future<AppSettings> load() async => _settings;

  @override
  Future<void> save(AppSettings settings) async {
    _settings = settings;
  }
}


