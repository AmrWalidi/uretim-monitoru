import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uretim_monitoru/models/daily_production.dart';
import 'package:uretim_monitoru/models/product.dart';

class DailyProductionListContainer extends StatelessWidget {
  const DailyProductionListContainer({
    super.key,
    required this.dailyProductions,
    required this.product,
  });

  final List<DailyProduction> dailyProductions;
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...dailyProductions.map(
              (dp) => Container(
            margin: EdgeInsets.only(bottom: 2),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ListTile(
              title: Text(
                DateFormat('MMM d, y').format(dp.createdAt),
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              subtitle: Text(
                '${dp.unit} birim',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              trailing: Container(
                padding: EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: dp.unit == product.dailyTarget
                        ? Colors.blue.shade100
                        : dp.unit < product.dailyTarget
                        ? Colors.red.shade100
                        : Colors.green.shade100,
                  ),
                  color: dp.unit == product.dailyTarget
                      ? Colors.blue.shade50
                      : dp.unit < product.dailyTarget
                      ? Colors.red.shade50
                      : Colors.green.shade50,
                ),
                child: Text(
                  (dp.unit == product.dailyTarget
                      ? 'Hedefe Ulaşıldı'
                      : dp.unit > product.dailyTarget
                      ? 'Hedef Üzeri'
                      : 'Hedef Altına')
                      .toUpperCase(),

                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: dp.unit == product.dailyTarget
                        ? Colors.blue.shade700
                        : dp.unit > product.dailyTarget
                        ? Colors.green.shade600
                        : Colors.red.shade600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
