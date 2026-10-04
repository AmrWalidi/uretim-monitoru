class DailyProduction {
  final int? id;
  final int productId;
  final DateTime createdAt;
  final int unit;

  DailyProduction( {this.id,required this.productId, required this.createdAt, required this.unit});

  factory DailyProduction.fromMap(Map<String, dynamic> map) {
    return DailyProduction(
      id: map['id'],
      productId: map['product_id'],
      createdAt: DateTime.parse(map['created_at']),
      unit: map['unit'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_id': productId,
      'created_at': createdAt.toIso8601String(),
      'unit': unit,
    };
  }
}
