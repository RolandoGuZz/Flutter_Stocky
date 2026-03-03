import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 2)
enum ProductType {
  @HiveField(0)
  solid,

  @HiveField(1)
  liquid,
}

@HiveType(typeId: 1)
class Product {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int quantity;

  @HiveField(3)
  final double liquidQuantity;

  @HiveField(4)
  final ProductType type;

  @HiveField(5)
  final DateTime expiryDate;

  @HiveField(6)
  final String? description;

  @HiveField(7)
  final bool isExpired;

  @HiveField(8)
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.quantity,
    required this.liquidQuantity,
    required this.type,
    required this.expiryDate,
    this.description,
    required this.isExpired,
    required this.createdAt,
  });

  factory Product.create({
    required String name,
    required int quantity,
    required double liquidQuantity,
    required ProductType type,
    required DateTime expiryDate,
    String? description,
  }) {
    return Product(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      quantity: type == ProductType.solid ? quantity : 0,
      liquidQuantity: type == ProductType.liquid ? liquidQuantity : 0.0,
      type: type,
      expiryDate: expiryDate,
      description: description,
      isExpired: expiryDate.isBefore(DateTime.now()),
      createdAt: DateTime.now(),
    );
  }
}
