import 'package:flutter/material.dart';
import 'package:uretim_monitoru/models/product.dart';
import 'package:uretim_monitoru/pages/daily_production_page.dart';
import 'package:uretim_monitoru/pages/inventory_page.dart';

class ProductDetailsPage extends StatefulWidget {
  const ProductDetailsPage({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int _currentPage = 0;
  late final List pages;

  @override
  void initState() {
    super.initState();
    pages = [
      DailyProductionPage(widget.product),
      InventoryPage(widget.product),
    ];
  }

  void navigateTo(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_currentPage],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage,
        onTap: navigateTo,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.fact_check_outlined),
            activeIcon: Icon(
              Icons.fact_check,
              color: Colors.blue.shade600,
            ),
            label: 'Günlük Üretim',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory, color: Colors.blue.shade600),
            label: 'Stok',
          ),
        ],
      ),
    );
  }
}
