import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uretim_monitoru/models/daily_production.dart';
import 'package:uretim_monitoru/models/product.dart';
import 'package:uretim_monitoru/models/product_material.dart';
import 'package:uretim_monitoru/pages/production_history.dart';
import 'package:uretim_monitoru/providers/daily_production_provider.dart';
import 'package:uretim_monitoru/providers/product_material_provider.dart';
import 'package:uretim_monitoru/widgets/daily_production_list_container.dart';

class DailyProductionPage extends ConsumerStatefulWidget {
  const DailyProductionPage(this.product, {super.key});

  final Product product;

  @override
  ConsumerState<DailyProductionPage> createState() =>
      _DailyProductionPageState();
}

class _DailyProductionPageState extends ConsumerState<DailyProductionPage> {
  late final TextEditingController _dailyProductionController;
  String counterError = '';

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

  void clear() {
    _dailyProductionController.clear();
  }

  void _decreaseDailyProduction() {
    final current = int.tryParse(_dailyProductionController.text) ?? 0;
    setState(() {
      if (current <= 1) {
        _dailyProductionController.clear();
      } else {
        _dailyProductionController.text = (current - 1).toString();
      }
    });
  }

  void _increaseDailyProduction() {
    final current = int.tryParse(_dailyProductionController.text) ?? 0;

    setState(() {
      _dailyProductionController.text = (current + 1).toString();
    });
  }

  Future<void> _saveDailyProduction() async {
    FocusScope.of(context).unfocus();
    final productionQuantity = _getProductionQuantity();

    if (productionQuantity == null) {
      return;
    }

    if (!_isDayValid()) {
      return;
    }

    final productId = widget.product.id!;
    final totalProduction = await _getTotalProduction(productId);
    final materials = _getMaterials(productId);

    if (materials == null) {
      return;
    }

    final hasEnoughMaterials = _checkMaterials(
      materials: materials,
      totalProduction: totalProduction,
      productionQuantity: productionQuantity,
    );

    if (!hasEnoughMaterials) {
      return;
    }

    await _addDailyProduction(
      productId: productId,
      productionQuantity: productionQuantity,
    );

    _clearProductionForm();
  }

  int? _getProductionQuantity() {
    final productionText = _dailyProductionController.text.trim();
    final productionQuantity = int.tryParse(productionText);

    if (productionQuantity == null || productionQuantity <= 0) {
      setState(() {
        counterError = 'Lütfen geçerli bir üretim miktarı girin.';
      });

      return null;
    }

    return productionQuantity;
  }

  bool _isDayValid() {
    final dailyProductionsState = ref.watch(
      dailyProductionsProvider(widget.product.id!),
    );
    final DailyProduction? lastDayProduction =
        dailyProductionsState.value?.isNotEmpty == true
        ? dailyProductionsState.value!.first
        : null;

    if (lastDayProduction == null) {
      return true;
    }

    final now = DateTime.now();

    final lastDate = DateTime(
      lastDayProduction.createdAt.year,
      lastDayProduction.createdAt.month,
      lastDayProduction.createdAt.day,
    );

    final today = DateTime(now.year, now.month, now.day);

    if (!lastDate.isBefore(today)) {
      setState(() {
        counterError = 'Bugünkü üretim zaten kaydedildi.';
      });
      return false;
    }

    return true;
  }

  Future<int> _getTotalProduction(int productId) async {
    return await ref.read(totalProductionProvider(productId).future);
  }

  List<ProductMaterial>? _getMaterials(int productId) {
    final materialsState = ref.read(productMaterialsProvider(productId));

    final materials = materialsState.value;

    if (materials == null || materials.isEmpty) {
      setState(() {
        counterError = 'Malzemeler henüz yüklenmedi.';
      });

      return null;
    }

    return materials;
  }

  bool _checkMaterials({
    required List<ProductMaterial> materials,
    required int totalProduction,
    required int productionQuantity,
  }) {
    final newTotalProduction = totalProduction + productionQuantity;

    String errorMessage = '';

    for (final material in materials) {
      final requiredPcs = newTotalProduction * material.pcsPerProduct;
      final remainingPcs =
          material.totalPcs - (totalProduction * material.pcsPerProduct);

      if (material.totalPcs < requiredPcs) {
        errorMessage +=
            '${material.name} malzemesi yetersiz.\n'
            'Gerekli: $requiredPcs parça, '
            'Mevcut: $remainingPcs parça.';
      }
    }

    if (errorMessage.isNotEmpty) {
      setState(() {
        counterError = errorMessage;
      });

      return false;
    }

    return true;
  }

  Future<void> _addDailyProduction({
    required int productId,
    required int productionQuantity,
  }) async {
    final dailyProduction = DailyProduction(
      productId: productId,
      createdAt: DateTime.now(),
      unit: productionQuantity,
    );

    await ref
        .read(dailyProductionsProvider(productId).notifier)
        .addProduction(dailyProduction);

    ref.invalidate(totalProductionProvider(productId));
  }

  void _clearProductionForm() {
    clear();

    setState(() {
      counterError = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Günlük Üretim',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ListTile(
                title: Text(
                  '${widget.product.isFinished ? 'Tamamlanmış' : 'Aktif'} Ürün',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
                subtitle: Text(
                  widget.product.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                trailing: Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Text(
                    'Hedef: ${widget.product.dailyTarget} birim',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade600,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            _buildCounterSection(),
            SizedBox(height: 16),
            _buildDepletedItemsSection(ref),
            SizedBox(height: 16),
            _buildDailyProductionHistorySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterSection() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Bugünkü Üretim',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _dailyProductionController.text.isEmpty
                        ? Colors.grey.shade100
                        : int.parse(_dailyProductionController.text) >=
                              widget.product.dailyTarget
                        ? Colors.green.shade100
                        : Colors.red.shade100,
                  ),
                  color: _dailyProductionController.text.isEmpty
                      ? Colors.grey.shade50
                      : int.parse(_dailyProductionController.text) >=
                            widget.product.dailyTarget
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                ),
                child: Text(
                  (_dailyProductionController.text.isEmpty
                          ? 'Giriş bekleniyor'
                          : int.parse(_dailyProductionController.text) ==
                                widget.product.dailyTarget
                          ? 'Hedefe Ulaşıldı'
                          : int.parse(_dailyProductionController.text) >
                                widget.product.dailyTarget
                          ? 'Hedef Üzeri (+${int.parse(_dailyProductionController.text) - widget.product.dailyTarget})'
                          : 'Hedef Altına (-${widget.product.dailyTarget - int.parse(_dailyProductionController.text)})')
                      .toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _dailyProductionController.text.isEmpty
                        ? Colors.grey.shade700
                        : int.parse(_dailyProductionController.text) >=
                              widget.product.dailyTarget
                        ? Colors.green.shade600
                        : Colors.red.shade600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: IconButton(
                  onPressed:
                      (int.tryParse(_dailyProductionController.text) ?? 0) > 0
                      ? _decreaseDailyProduction
                      : null,
                  icon: Icon(Icons.remove),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _dailyProductionController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      if (newValue.text.isEmpty) return newValue;
                      final parsed = int.tryParse(newValue.text);
                      if (parsed == null ||
                          parsed > widget.product.totalTarget) {
                        return oldValue;
                      }
                      return newValue;
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {});
                  },
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),

                    hintText: '0',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: IconButton(
                  onPressed:
                      (int.tryParse(_dailyProductionController.text) ?? 0) <
                          widget.product.totalTarget
                      ? _increaseDailyProduction
                      : null,
                  icon: Icon(Icons.add),
                ),
              ),
            ],
          ),
          Text(
            'BİRİM',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onPressed: _saveDailyProduction,
            label: Text(
              'Gülük Üretim Kaydet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            icon: Icon(Icons.save),
          ),
          if (counterError.isNotEmpty)
            Column(
              children: [
                SizedBox(height: 16),
                Text(counterError, style: TextStyle(color: Colors.red)),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDepletedItemsSection(WidgetRef ref) {
    final totalProduction = ref.watch(
      totalProductionProvider(widget.product.id),
    );
    final materialsState = ref.watch(
      productMaterialsProvider(widget.product.id ?? 0),
    );
    final dailyProductionsState = ref.watch(
      dailyProductionsProvider(widget.product.id!),
    );
    final DailyProduction? lastDayProduction =
        dailyProductionsState.value?.isNotEmpty == true
        ? dailyProductionsState.value!.first
        : null;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Kalan Malzemeler',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Divider(color: Colors.grey.shade300, height: 8),
          SizedBox(height: 8),
          materialsState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
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
                return _buildMaterialsEmptyState();
              }
              return Column(
                children: [
                  ...materials.map((m) {
                    final total = totalProduction.requireValue;
                    final remainingPcs =
                        (m.totalPcs - (total * m.pcsPerProduct));
                    return Container(
                      margin: EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Color(0XFF64748B).withAlpha(10),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(8),
                        title: Text(
                          '${m.name} (${m.code})',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: RichText(
                          text: TextSpan(
                            style: TextStyle(color: Colors.grey.shade600),
                            children: [
                              TextSpan(
                                text: remainingPcs.toString(),
                                style: TextStyle(
                                  color:
                                      widget.product.dailyTarget *
                                              m.pcsPerProduct <=
                                          remainingPcs
                                      ? Colors.black
                                      : Colors.orange.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              TextSpan(text: ' kalan parça'),
                            ],
                          ),
                        ),
                        trailing: Text(
                          lastDayProduction != null
                              ? '-${lastDayProduction.unit * m.pcsPerProduct} birim'
                              : '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade600,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialsEmptyState() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Icon(
              Icons.inventory_outlined,
              color: Colors.blue.shade600,
              size: 24,
            ),
          ),
          Text(
            'Henüz Malzeme Eklenmedi',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Malzeme tüketimini otomatik olarak hesaplamak ve depo envanterini güncellemek için bugünkü üretim miktarını girip kaydedin.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyProductionHistorySection() {
    final dailyProductionsState = ref.watch(
      dailyProductionsProvider(widget.product.id!),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Üretim Geçmişi',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        dailyProductionsState.when(
          loading: () => Center(child: CircularProgressIndicator()),
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
          data: (dailyProductions) {
            if (dailyProductions.isEmpty) {
              return _buildDailyProductionHistoryEmptyState();
            }
            return Column(
              children: [
                DailyProductionListContainer(
                  dailyProductions: dailyProductions.length < 4
                      ? dailyProductions
                      : dailyProductions.sublist(0, 3),
                  product: widget.product,
                ),
                dailyProductions.length > 3
                    ? TextButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductionHistory(
                              dailyProductions: dailyProductions,
                              product: widget.product,
                            ),
                          ),
                        ),
                        child: Text(
                          'Tümü Görüntüle',
                          style: TextStyle(color: Colors.blue.shade600),
                        ),
                      )
                    : Container(),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildDailyProductionHistoryEmptyState() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Icon(
              Icons.history_toggle_off,
              color: Colors.grey.shade700,
              size: 24,
            ),
          ),
          Text(
            'Üretim Geçmişi Kaydedilmedi',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Günlük üretim kayıtları ve performans takibi, kaydedildikten sonra burada görüntülenecektir.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
