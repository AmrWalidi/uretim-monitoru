import 'dart:io';
import 'package:uretim_monitoru/utils/get_image_path.dart';

class ProductMaterial {
  final int? id;
  final String name;
  final String code;
  final int totalPcs;
  final int pcsPerProduct;
  File? image;

  ProductMaterial({
    this.id,
    required this.name,
    required this.code,
    required this.pcsPerProduct,
    required this.totalPcs,
    this.image,
  });

  factory ProductMaterial.fromMap(Map<String, dynamic> map) {
    return ProductMaterial(
      id: map['id'],
      name: map['name'],
      code: map['code'],
      pcsPerProduct: map['pcs_per_product'],
      totalPcs: map['total_pcs'],
      image: map['image'] != null ? File(map['image'] as String) : null,
    );
  }

  Future<Map<String, dynamic>> toMap() async {
    return {
      'id': id,
      'name': name,
      'code': code,
      'total_pcs': totalPcs,
      'pcs_per_product': pcsPerProduct,
      'image': image != null ? await getImagePath(image!) : null,
    };
  }

  ProductMaterial copyWith({
    int? id,
    int? productId,
    String? name,
    String? code,
    int? totalPcs,
    int? pcsPerProduct,
    File? image,
  }) {
    return ProductMaterial(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      totalPcs: totalPcs ?? this.totalPcs,
      pcsPerProduct: pcsPerProduct ?? this.pcsPerProduct,
      image: image ?? this.image,
    );
  }
}
