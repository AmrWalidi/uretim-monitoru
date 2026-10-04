import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:uretim_monitoru/models/product.dart';
import 'package:uretim_monitoru/pages/add_product_page.dart';
import 'package:uretim_monitoru/providers/product_provider.dart';
import 'package:uretim_monitoru/widgets/product_container.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  int _productType = 0;

  List<Product> _filterProducts(List<Product> products) {
    switch (_productType) {
      case 0:
        return products.where((product) => !product.isFinished).toList();

      case 1:
        return products.where((product) => product.isFinished).toList();

      case 2:
      default:
        return products;
    }
  }

  void _changeProductType(int type) {
    setState(() {
      _productType = type;
    });
  }

  Future<void> _openAddProductPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddProductPage()),
    );

    ref.invalidate(productsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final productsState = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ürünler',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),

      body: productsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text(
                  'Ürünler yüklenirken bir hata oluştu.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(productsProvider);
                  },
                  child: const Text('Tekrar Dene'),
                ),
              ],
            ),
          ),
        ),

        data: (products) {
          final filteredProducts = _filterProducts(products);

          if (products.isEmpty) {
            return _buildEmptyState();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0XFF64748B).withAlpha(30),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildProductTypeButton(type: 0, title: 'Devam'),
                            _buildProductTypeButton(
                              type: 1,
                              title: 'Tamamlanan',
                            ),
                            _buildProductTypeButton(type: 2, title: 'Tümü'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                if (filteredProducts.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        'Bu kategoride ürün bulunamadı.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                else
                  ...filteredProducts.map(
                    (product) => ProductContainer(product: product),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: productsState.value?.isNotEmpty == true
          ? FloatingActionButton(
              onPressed: _openAddProductPage,
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildProductTypeButton({required int type, required String title}) {
    final isSelected = _productType == type;

    return Expanded(
      child: GestureDetector(
        onTap: () => _changeProductType(type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: isSelected ? Colors.white : null,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.grey.shade700,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Icon(
                  Icons.pending_actions_rounded,
                  color: Colors.blue.shade600,
                  size: 40,
                ),
              ),

              const Text(
                'Ürün Henüz Eklenmedi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                'İlk ürününüzü ekleyerek fabrika üretimini ve gerekli malzemeleri takip etmeye başlayın.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 16),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                onPressed: _openAddProductPage,
                label: const Text(
                  'İlk Ürünü Oluştur',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
