import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uretim_monitoru/models/product_material.dart';
import 'package:uretim_monitoru/models/product.dart';
import 'package:uretim_monitoru/pages/add_material_page.dart';
import 'package:uretim_monitoru/providers/daily_production_provider.dart';
import 'package:uretim_monitoru/providers/product_material_provider.dart';

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage(this.product, {super.key});

  final Product product;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage> {
  late final TextEditingController _dailyProductionController;

  @override
  void initState() {
    super.initState();
    _dailyProductionController = TextEditingController();
  }

  @override
  void dispose() {
    _dailyProductionController.dispose();
    super.dispose();
  }

  void _decreaseDailyProduction(StateSetter setDialogState) {
    final current = int.tryParse(_dailyProductionController.text) ?? 0;
    setDialogState(() {
      if (current <= 1) {
        _dailyProductionController.clear();
      } else {
        _dailyProductionController.text = (current - 1).toString();
      }
    });
  }

  void _increaseDailyProduction(StateSetter setDialogState) {
    final current = int.tryParse(_dailyProductionController.text) ?? 0;
    setDialogState(() {
      _dailyProductionController.text = (current + 1).toString();
    });
  }

  void clear() {
    _dailyProductionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final materialsState = ref.watch(
      productMaterialsProvider(widget.product.id!),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Stok', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        actions: [
          materialsState.when(
            data: (materials) {
              if (materials.isEmpty) return Container();

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddMaterialPage(widget.product.id),
                    ),
                  ),
                  icon: Icon(Icons.add),
                ),
              );
            },
            error: (error, stackTrace) => Center(child: Text('Hata: $error')),
            loading: () => Container(),
          ),
        ],
      ),
      body: materialsState.when(
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
                  'Malzemeler yüklenirken bir hata oluştu.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),

        data: (materials) {
          if (materials.isEmpty) {
            return _buildEmptyState(context);
          }
          return _buildMaterialsList(materials);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
                  Icons.construction,
                  color: Colors.blue.shade600,
                  size: 40,
                ),
              ),

              const Text(
                'Malzeme Henüz Eklenmedi',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 8),

              const Text(
                'Ürünün takibini sağlamak için gerekli malzemeleri ekleyin.',
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddMaterialPage(widget.product.id),
                    ),
                  );
                },
                label: const Text(
                  'İlk Malzeme Ekle',
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

  Widget _buildMaterialsList(List<ProductMaterial> materials) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: materials.map((material) {
          return _buildMaterialCard(ref, material);
        }).toList(),
      ),
    );
  }

  Widget _buildMaterialCard(WidgetRef ref, ProductMaterial material) {
    final totalProduction = ref.watch(
      totalProductionProvider(widget.product.id),
    );
    final remainingPcs =
        material.totalPcs -
        (totalProduction.requireValue * material.pcsPerProduct);

    final requiredForToday =
        widget.product.dailyTarget * material.pcsPerProduct;

    final insufficient = requiredForToday > remainingPcs;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ListTile(
            leading: material.image != null
                ? Image.file(
                    material.image!,
                    fit: BoxFit.cover,
                    width: 50,
                    height: 50,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image_not_supported);
                    },
                  )
                : const Icon(Icons.image_not_supported, size: 30),

            title: Row(
              children: [
                Flexible(
                  child: Text(
                    material.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),

                const SizedBox(width: 8),

                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0XFF64748B).withAlpha(40),
                  ),
                  child: Text(
                    material.code,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),

            subtitle: Text(
              '$remainingPcs Kalan Birim'
              '${insufficient ? ' • Yetersiz' : ''}',
              style: TextStyle(
                fontSize: 14,
                color: insufficient ? Colors.red : Colors.grey,
              ),
            ),

            trailing: IconButton(
              onPressed: () {
                ref
                    .read(productMaterialsProvider(widget.product.id!).notifier)
                    .deleteMaterial(material.id!);
              },
              icon: const Icon(Icons.delete_outline, color: Colors.grey),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 8),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () {
                _showAddToStockDialog(context, ref, material);
              },
              icon: const Icon(Icons.add),
              label: const Text('Stoka Ekle'),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddToStockDialog(
    BuildContext context,
    WidgetRef ref,
    ProductMaterial material,
  ) {
    final totalProduction = ref.watch(
      totalProductionProvider(widget.product.id),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              insetPadding: EdgeInsets.symmetric(horizontal: 16),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.close, color: Colors.grey),
                        ),
                      ],
                    ),
                    Text(
                      'Ekstra parçalar ekleyin',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.grey.shade600),
                        children: [
                          TextSpan(text: '${material.name} • Kalan: '),
                          TextSpan(
                            text:
                                '${material.totalPcs - (totalProduction.value! * material.pcsPerProduct)} birim',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color(0XFF64748B).withAlpha(10),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            ('Eklenecek miktar').toUpperCase(),
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                child: IconButton(
                                  onPressed:
                                      (int.tryParse(
                                                _dailyProductionController.text,
                                              ) ??
                                              0) >
                                          0
                                      ? () => _decreaseDailyProduction(
                                          setDialogState,
                                        )
                                      : null,
                                  icon: Icon(
                                    Icons.remove,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  controller: _dailyProductionController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    TextInputFormatter.withFunction((
                                      oldValue,
                                      newValue,
                                    ) {
                                      if (newValue.text.isEmpty) {
                                        return newValue;
                                      }
                                      final parsed = int.tryParse(
                                        newValue.text,
                                      );
                                      if (parsed == null ||
                                          parsed > widget.product.totalTarget) {
                                        return oldValue;
                                      }
                                      return newValue;
                                    }),
                                  ],
                                  onChanged: (value) {
                                    setDialogState(() {});
                                  },
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 32,
                                  ),
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,

                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade400,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade400,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    hintText: '0',
                                    hintStyle: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                child: IconButton(
                                  onPressed:
                                      (int.tryParse(
                                                _dailyProductionController.text,
                                              ) ??
                                              0) <
                                          widget.product.totalTarget
                                      ? () => _increaseDailyProduction(
                                          setDialogState,
                                        )
                                      : null,
                                  icon: Icon(
                                    Icons.add,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            onPressed: () {
                              ref
                                  .read(
                                    productMaterialsProvider(
                                      widget.product.id!,
                                    ).notifier,
                                  )
                                  .addStock(
                                    material.id,
                                    int.parse(_dailyProductionController.text),
                                  );
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.add_task),
                            label: Text(
                              'Onayla ve Ekle',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
