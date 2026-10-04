import 'package:uretim_monitoru/database/dao/product_material_dao.dart';
import 'package:uretim_monitoru/models/product_material.dart';

class ProductMaterialRepository {
  final ProductMaterialDao _dao;

  ProductMaterialRepository(this._dao);

  Future<List<ProductMaterial>> getMaterialsForProduct(
      int? productId,
      ) {
    return _dao.getByProductId(productId);
  }

  Future<int> addMaterial(int? productId, ProductMaterial material) {
    return _dao.insert(productId, material);
  }

  Future<int> updateMaterial(ProductMaterial material) {
    return _dao.update(material);
  }

  Future<void> addStock({
    required int? materialId,
    required int quantity,
  }) async {
    final material = await _dao.getById(materialId);

    if (material == null) {
      throw Exception('Material not found');
    }

    final updatedMaterial = material.copyWith(
      totalPcs: material.totalPcs + quantity,
    );

    await _dao.update(updatedMaterial);
  }

  Future<void> consumeStock({
    required int materialId,
    required int quantity,
  }) async {
    final material = await _dao.getById(materialId);

    if (material == null) {
      throw Exception('Material not found');
    }

    if (material.totalPcs < quantity) {
      throw Exception('Not enough material in stock');
    }

    final updatedMaterial = material.copyWith(
      totalPcs: material.totalPcs - quantity,
    );

    await _dao.update(updatedMaterial);
  }

  Future<int> deleteMaterial(int id) {
    return _dao.delete(id);
  }
}