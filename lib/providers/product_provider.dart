import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/dao/product_dao.dart';
import '../models/product.dart';
import '../repositories/product_repository.dart';

final productDaoProvider = Provider<ProductDao>((ref) {
  return ProductDao();
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(ref.read(productDaoProvider));
});

final productsProvider = AsyncNotifierProvider<ProductsNotifier, List<Product>>(
  ProductsNotifier.new,
);

class ProductsNotifier extends AsyncNotifier<List<Product>> {
  ProductRepository get _repository =>
      ref.read(productRepositoryProvider);

  @override
  Future<List<Product>> build() async {
    return await _repository.getProducts();
  }

  Future<int> addProduct(Product product) async {
    final id = await _repository.addProduct(product);

    ref.invalidateSelf();
    await future;

    return id;
  }

  Future<void> updateProduct(Product product) async {
    await _repository.updateProduct(product);

    ref.invalidateSelf();
    await future;
  }

  Future<void> deleteProduct(int? id) async {
    await _repository.deleteProduct(id);

    ref.invalidateSelf();
    await future;
  }

  Future<void> setFinished(int? id, bool isFinished) async {
    await _repository.setFinished(id, isFinished);

    ref.invalidateSelf();
    await future;
  }
}
