import 'package:flutter_test/flutter_test.dart';
import 'package:ia_embarcada/services/app_database.dart';
import 'package:ia_embarcada/services/settings_repository.dart';
import 'package:ia_embarcada/models/app_settings.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  Future<Database> createInMemoryDb() async {
    return openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE ${AppDatabase.tableSettings} (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
      },
    );
  }

  group('SqfliteSettingsRepository', () {
    test('carrega valores padrão quando o banco está vazio', () async {
      final db = await createInMemoryDb();
      final repo = SqfliteSettingsRepository(Future.value(db));

      final settings = await repo.load();
      expect(settings.threshold, 0.5);
      expect(settings.displayMode, DisplayMode.list);

      await db.close();
    });

    test('salva e recarrega configurações corretamente', () async {
      final db = await createInMemoryDb();
      final repo = SqfliteSettingsRepository(Future.value(db));

      await repo.save(const AppSettings(
        threshold: 0.85,
        displayMode: DisplayMode.cards,
      ));

      final loaded = await repo.load();
      expect(loaded.threshold, 0.85);
      expect(loaded.displayMode, DisplayMode.cards);

      await db.close();
    });

    test('limita (clamp) o limiar caso valor gravado ultrapasse os limites',
        () async {
      final db = await createInMemoryDb();
      final repo = SqfliteSettingsRepository(Future.value(db));

      // Injeta manualmente valor fora do intervalo
      await db.insert(AppDatabase.tableSettings, {
        'key': SqfliteSettingsRepository.keyThreshold,
        'value': '1.50',
      });

      final loaded = await repo.load();
      expect(loaded.threshold, 0.95);

      await db.close();
    });

    test('recupera valor padrão caso o texto no banco não seja numérico',
        () async {
      final db = await createInMemoryDb();
      final repo = SqfliteSettingsRepository(Future.value(db));

      await db.insert(AppDatabase.tableSettings, {
        'key': SqfliteSettingsRepository.keyThreshold,
        'value': 'invalido',
      });

      final loaded = await repo.load();
      expect(loaded.threshold, 0.5);

      await db.close();
    });
  });
}

