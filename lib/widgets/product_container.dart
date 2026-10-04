import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:uretim_monitoru/models/product.dart';
import 'package:uretim_monitoru/pages/product_details_page.dart';
import 'package:uretim_monitoru/pages/production_history.dart';
import 'package:uretim_monitoru/providers/daily_production_provider.dart';
import 'package:uretim_monitoru/providers/product_provider.dart';

class ProductContainer extends ConsumerWidget {
  const ProductContainer({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productionsState = ref.watch(dailyProductionsProvider(product.id!));

    final currentProduction = productionsState.when(
      loading: () => 0,
      error: (_, __) => 0,
      data: (productions) {
        return productions.fold<int>(
          0,
          (sum, production) => sum + production.unit,
        );
      },
    );

    final progress = product.totalTarget == 0
        ? 0.0
        : currentProduction / product.totalTarget;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          ListTile(
            leading: product.image != null
                ? Image.file(
                    product.image!,
                    fit: BoxFit.cover,
                    width: 50,
                    height: 50,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image_not_supported);
                    },
                  )
                : const Icon(Icons.image_not_supported, size: 30),

            title: Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            subtitle: Text(
              'Günlük hedef: ${product.dailyTarget}',
              style: TextStyle(color: Colors.grey.shade600),
            ),

            trailing: product.isFinished
                ? null
                : IconButton(
                    onPressed: () => _deleteProduct(context, ref),
                    icon: Icon(Icons.delete, color: Colors.grey.shade600),
                  ),
          ),

          // Production progress
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0XFF64748B).withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.grey.shade600),
                    children: [
                      TextSpan(
                        text: '$currentProduction',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(text: ' / ${product.totalTarget} units'),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(16),
                  color: currentProduction >= product.totalTarget
                      ? Colors.green
                      : Colors.blue,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(8),
                    backgroundColor: product.isFinished
                        ? Colors.white
                        : Colors.blue.shade600,
                    foregroundColor: product.isFinished
                        ? Colors.grey.shade600
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                      side: product.isFinished
                          ? BorderSide(color: Colors.grey.shade50)
                          : BorderSide.none,
                    ),
                  ),
                  onPressed: () async {
                    if (product.isFinished) {
                      final productions = productionsState.value ?? [];

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductionHistory(
                            dailyProductions: productions,
                            product: product,
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetailsPage(product: product),
                        ),
                      );
                    }
                  },
                  label: Text(
                    product.isFinished ? 'Geçmişi görüntüle' : 'Günlük Üretim',
                    textAlign: TextAlign.center,
                  ),
                  icon: Icon(
                    product.isFinished ? Icons.history : Icons.construction,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(8),
                    backgroundColor: product.isFinished
                        ? Colors.green.shade50
                        : Colors.white,
                    foregroundColor: product.isFinished
                        ? Colors.green.shade600
                        : Colors.grey.shade600,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                      side: BorderSide(
                        color: product.isFinished
                            ? Colors.green.shade100
                            : Colors.grey.shade50,
                      ),
                    ),
                  ),
                  onPressed: product.isFinished
                      ? () {}
                      : () => _completeProduct(context, ref),
                  label: Text(
                    product.isFinished ? 'Tamamlandı' : 'Ürünü Tamamla',
                    textAlign: TextAlign.center,
                  ),
                  icon: Icon(
                    Icons.check_circle_outline,
                    color: product.isFinished
                        ? Colors.green.shade600
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProduct(BuildContext context, WidgetRef ref) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ürünü Sil'),
          content: Text(
            '${product.name} ürününü silmek istediğinizden emin misiniz?',
          ),
          actions: [
            TextButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32),
                foregroundColor: Colors.grey.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade700),
                ),
              ),
              onPressed: () => Navigator.pop(context, false),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 32),
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Sil'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    await ref.read(productsProvider.notifier).deleteProduct(product.id);
  }

  Future<void> _completeProduct(BuildContext context, WidgetRef ref) async {
    await ref.read(productsProvider.notifier).setFinished(product.id, true);
  }
}
