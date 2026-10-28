import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Gerenciador de conexão com o banco de dados SQLite local.
class AppDatabase {
  static const String databaseName = 'ia_embarcada.db';
  static const int databaseVersion = 1;
  static const String tableSettings = 'settings';

  /// Abre a conexão com o banco de dados e cria as tabelas necessárias.
  static Future<Database> open({String? customPath}) async {
    final dbPath = customPath ?? p.join(await getDatabasesPath(), databaseName);

    return openDatabase(
      dbPath,
      version: databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tableSettings (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
      },
    );
  }
}

