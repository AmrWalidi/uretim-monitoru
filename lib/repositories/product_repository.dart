import '../database/dao/product_dao.dart';
import '../models/product.dart';

class ProductRepository {
  final ProductDao _productDao;

  ProductRepository(this._productDao);

  Future<int> addProduct(Product product) async {
    return await _productDao.insert(product);
  }

  Future<List<Product>> getProducts() async {
    return await _productDao.getAll();
  }

  Future<Product?> getProduct(int id) async {
    return await _productDao.getById(id);
  }

  Future<int> updateProduct(Product product) async {
    return await _productDao.update(product);
  }

  Future<int> deleteProduct(int? id) async {
    return await _productDao.delete(id);
  }

  Future<int> setFinished(
      int? id,
      bool isFinished,
      ) async {
    return await _productDao.updateFinishedStatus(
      id,
      isFinished,
    );
  }
}
