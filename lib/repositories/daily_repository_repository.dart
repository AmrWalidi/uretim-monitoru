import '../database/dao/daily_production_dao.dart';
import '../models/daily_production.dart';

class DailyProductionRepository {
  final DailyProductionDao _dailyProductionDao;

  DailyProductionRepository(this._dailyProductionDao);

  Future<int> addProduction(
      DailyProduction production,
      ) async {
    return await _dailyProductionDao.insert(
      production,
    );
  }

  Future<List<DailyProduction>> getProductions() async {
    return await _dailyProductionDao.getAll();
  }

  Future<DailyProduction?> getProduction(int id) async {
    return await _dailyProductionDao.getById(id);
  }

  Future<List<DailyProduction>> getProductProductions(
      int? productId,
      ) async {
    return await _dailyProductionDao.getByProductId(
      productId,
    );
  }

  Future<int> getTotalProduction(
      int? productId,
      ) async {
    return await _dailyProductionDao.getTotalProduction(
      productId,
    );
  }

  Future<int> updateProduction(
      DailyProduction production,
      ) async {
    return await _dailyProductionDao.update(
      production,
    );
  }

  Future<int> deleteProduction(int id) async {
    return await _dailyProductionDao.delete(id);
  }

  Future<int> deleteProductProductions(
      int productId,
      ) async {
    return await _dailyProductionDao.deleteByProductId(
      productId,
    );
  }
}