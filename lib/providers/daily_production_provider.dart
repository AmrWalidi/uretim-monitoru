import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uretim_monitoru/repositories/daily_repository_repository.dart';
import '../database/dao/daily_production_dao.dart';
import '../models/daily_production.dart';

final dailyProductionDaoProvider = Provider<DailyProductionDao>((ref) {
  return DailyProductionDao();
});

final dailyProductionRepositoryProvider = Provider<DailyProductionRepository>((
  ref,
) {
  return DailyProductionRepository(ref.read(dailyProductionDaoProvider));
});

final dailyProductionsProvider = StateNotifierProvider.autoDispose
    .family<DailyProductionsNotifier, AsyncValue<List<DailyProduction>>, int>((
      ref,
      productId,
    ) {
      return DailyProductionsNotifier(
        ref.read(dailyProductionRepositoryProvider),
        productId,
      );
    });

class DailyProductionsNotifier
    extends StateNotifier<AsyncValue<List<DailyProduction>>> {
  final DailyProductionRepository _repository;
  final int productId;

  DailyProductionsNotifier(this._repository, this.productId)
    : super(const AsyncValue.loading()) {
    loadProductions();
  }

  Future<void> loadProductions() async {
    try {
      state = const AsyncValue.loading();

      final productions = await _repository.getProductProductions(productId);

      state = AsyncValue.data(productions);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addProduction(DailyProduction production) async {
    await _repository.addProduction(production);

    await loadProductions();
  }

  Future<void> updateProduction(DailyProduction production) async {
    await _repository.updateProduction(production);

    await loadProductions();
  }

  Future<int> getTotalProduction() async {
    final totalProduction = await _repository.getTotalProduction(productId);
    return totalProduction;
  }

  Future<void> deleteProduction(int id) async {
    await _repository.deleteProduction(id);

    await loadProductions();
  }
}

final totalProductionProvider = FutureProvider.family<int, int?>((
  ref,
  productId,
) async {
  final repository = ref.read(dailyProductionRepositoryProvider);

  return repository.getTotalProduction(productId);
});
