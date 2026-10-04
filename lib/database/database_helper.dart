import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB('production.db');

    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(
      Database db,
      int version,
      ) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        total_target INTEGER NOT NULL,
        daily_target INTEGER NOT NULL,
        image TEXT,
        is_finished INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_productions (
        id INTEGER PRIMARY KEY,
        product_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        unit INTEGER NOT NULL,
        FOREIGN KEY (product_id)
          REFERENCES products(id)
          ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE product_materials (
        id INTEGER PRIMARY KEY,
        product_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        code TEXT NOT NULL,
        total_pcs INTEGER,
        pcs_per_product INTEGER NOT NULL,
        image TEXT,
        FOREIGN KEY (product_id)
          REFERENCES products(id)
          ON DELETE CASCADE
      )
    ''');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}