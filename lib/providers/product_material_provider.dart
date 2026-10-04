import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uretim_monitoru/database/dao/product_material_dao.dart';
import 'package:uretim_monitoru/models/product_material.dart';
import 'package:uretim_monitoru/repositories/product_material_repository.dart';

final materialRepositoryProvider = Provider<ProductMaterialRepository>((ref) {
  return ProductMaterialRepository(
    ProductMaterialDao(),
  );
});

final productMaterialsProvider = StateNotifierProvider.autoDispose.family<
    ProductMaterialNotifier,
    AsyncValue<List<ProductMaterial>>,
    int
>((ref, productId) {
  final repository = ref.read(materialRepositoryProvider);

  return ProductMaterialNotifier(
    repository,
    productId,
  );
});

class ProductMaterialNotifier
    extends StateNotifier<AsyncValue<List<ProductMaterial>>> {
  final ProductMaterialRepository _repository;
  final int productId;

  ProductMaterialNotifier(
      this._repository,
      this.productId,
      ) : super(const AsyncValue.loading()) {
    loadMaterials();
  }

  Future<void> loadMaterials() async {
    try {
      state = const AsyncValue.loading();

      final materials =
      await _repository.getMaterialsForProduct(productId);
      state = AsyncValue.data(materials);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addMaterial(ProductMaterial material) async {
     await _repository.addMaterial(productId, material);
     await loadMaterials();
  }

  Future<void> addStock(
      int? materialId,
      int quantity,
      ) async {
    await _repository.addStock(
      materialId: materialId,
      quantity: quantity,
    );

    await loadMaterials();
  }

  Future<void> consumeStock(
      int materialId,
      int quantity,
      ) async {
    await _repository.consumeStock(
      materialId: materialId,
      quantity: quantity,
    );

    await loadMaterials();
  }

  Future<void> deleteMaterial(int materialId) async {
    await _repository.deleteMaterial(materialId);

    await loadMaterials();
  }
}