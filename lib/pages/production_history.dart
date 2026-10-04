import 'package:flutter/material.dart';
import 'package:uretim_monitoru/models/daily_production.dart';
import 'package:uretim_monitoru/models/product.dart';
import 'package:uretim_monitoru/widgets/daily_production_list_container.dart';

class ProductionHistory extends StatelessWidget {
  const ProductionHistory({
    super.key,
    required this.dailyProductions,
    required this.product,
  });

  final List<DailyProduction> dailyProductions;
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Günlük Üretim Geçmişi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(8),
        child: DailyProductionListContainer(
          dailyProductions: dailyProductions,
          product: product,
        ),
      ),
    );
  }
}
