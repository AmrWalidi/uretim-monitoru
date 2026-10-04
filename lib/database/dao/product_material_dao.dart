import '../database_helper.dart';
import '../../models/product_material.dart';

class ProductMaterialDao {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<int> insert(int? productId, ProductMaterial material) async {
    final db = await _databaseHelper.database;

    return await db.insert(
      'product_materials',
      await material.toMap()..addAll({'product_id': productId}),
    );
  }

  Future<ProductMaterial?> getById(int? id) async {
    final db = await _databaseHelper.database;
    final result = await db.query(
      'product_materials',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? ProductMaterial.fromMap(result.first) : null;
  }

  Future<List<ProductMaterial>> getAll() async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      'product_materials',
      orderBy: 'id ASC',
    );

    return result.map(ProductMaterial.fromMap).toList();
  }

  Future<List<ProductMaterial>> getByProductId(
      int? productId,
      ) async {
    final db = await _databaseHelper.database;

    final result = await db.query(
      'product_materials',
      where: 'product_id = ?',
      whereArgs: [productId],
    );

    return result.map(ProductMaterial.fromMap).toList();
  }

  Future<int> update(ProductMaterial material) async {
    final db = await _databaseHelper.database;

    return await db.update(
      'product_materials',
      await material.toMap(),
      where: 'id = ?',
      whereArgs: [material.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await _databaseHelper.database;

    return await db.delete(
      'product_materials',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}