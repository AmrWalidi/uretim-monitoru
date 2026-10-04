import '../../models/product.dart';
import '../database_helper.dart';

class ProductDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> insert(Product product) async {
    final db = await _databaseHelper.database;

    return await db.insert('products', await product.toMap());
  }

  Future<List<Product>> getAll() async {
    final db = await _databaseHelper.database;

    final result = await db.query('products', orderBy: 'id DESC');

    return result.map(Product.fromMap).toList();
  }

  Future<Product?> getById(int id) async {
    final db = await _databaseHelper.database;

    final result = await db.query('products', where: 'id = ?', whereArgs: [id]);

    if (result.isEmpty) {
      return null;
    }

    return Product.fromMap(result.first);
  }

  Future<int> update(Product product) async {
    final db = await _databaseHelper.database;

    return await db.update(
      'products',
      await product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> delete(int? id) async {
    final db = await _databaseHelper.database;

    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateFinishedStatus(int? id, bool isFinished) async {
    final db = await _databaseHelper.database;

    return await db.update(
      'products',
      {'is_finished': isFinished ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
