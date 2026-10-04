import 'dart:io';
import '../utils/get_image_path.dart';

class Product {
  final int? id;
  final String name;
  final int totalTarget;
  final int dailyTarget;
  File? image;
  bool isFinished;

  Product({
    this.id,
    required this.name,
    required this.totalTarget,
    required this.dailyTarget,
    this.image,
    this.isFinished = false,
  });

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      totalTarget: map['total_target'],
      dailyTarget: map['daily_target'],
      image: map['image'] != null ? File(map['image'] as String) : null,
      isFinished: map['is_finished'] == 1,
    );
  }

  Future<Map<String, dynamic>> toMap() async {
    return {
      'id': id,
      'name': name,
      'total_target': totalTarget,
      'daily_target': dailyTarget,
      'image': image != null ? await getImagePath(image!) : null,
      'is_finished': isFinished ? 1 : 0,
    };
  }

  static final List<Product> mockProducts = [
    Product(
      id: 1,
      name: 'Product 1',
      totalTarget: 100,
      dailyTarget: 50,
      isFinished: true,
    ),
    Product(
      id: 2,
      name: 'Product 2',
      totalTarget: 120,
      dailyTarget: 50,
      isFinished: false,
    ),
  ];

  Product copyWith({
    int? id,
    String? name,
    int? totalTarget,
    int? dailyTarget,
    File? image,
    bool? isFinished,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      totalTarget: totalTarget ?? this.totalTarget,
      dailyTarget: dailyTarget ?? this.dailyTarget,
      image: image ?? this.image,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}
