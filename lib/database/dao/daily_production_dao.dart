import '../../models/daily_production.dart';
import '../database_helper.dart';

class DailyProductionDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  /// Insert a production record.
  Future<int> insert(DailyProduction production) async {
    final db = await _databaseHelper.database;

    return await db.insert('daily_productions', production.toMap());
  }

  /// Get all production records.
  Future<List<DailyProduction>> getAll() async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      'daily_productions',
      orderBy: 'created_at DESC',
    );

    return result.map(DailyProduction.fromMap).toList();
  }

  /// Get a production record by ID.
  Future<DailyProduction?> getById(int id) async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      'daily_productions',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return DailyProduction.fromMap(result.first);
  }

  /// Get all production records belonging to a product.
  Future<List<DailyProduction>> getByProductId(int? productId) async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      'daily_productions',
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'created_at DESC',
    );

    return result.map(DailyProduction.fromMap).toList();
  }

  /// Get the total production of a product.
  Future<int> getTotalProduction(int? productId) async {
    final db = await _databaseHelper.database;

    final result = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(unit), 0) AS total
      FROM daily_productions
      WHERE product_id = ?
      ''',
      [productId],
    );

    return (result.first['total'] as num).toInt();
  }

  /// Update a production record.
  Future<int> update(DailyProduction production) async {
    final db = await _databaseHelper.database;

    return await db.update(
      'daily_productions',
      production.toMap(),
      where: 'id = ?',
      whereArgs: [production.id],
    );
  }

  /// Delete a production record.
  Future<int> delete(int id) async {
    final db = await _databaseHelper.database;

    return await db.delete(
      'daily_productions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Delete all production records for a product.
  Future<int> deleteByProductId(int productId) async {
    final db = await _databaseHelper.database;

    return await db.delete(
      'daily_productions',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }
}
