import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 1)
class Product {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int quantity;

  @HiveField(3)
  final DateTime expiryDate;

  @HiveField(4)
  final String? description;

  @HiveField(5)
  final bool isExpired;

  @HiveField(6)
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.quantity,
    required this.expiryDate,
    this.description,
    required this.isExpired,
    required this.createdAt,
  });

  factory Product.create({
    required String name,
    required int quantity,
    required DateTime expiryDate,
    String? description,
  }) {
    return Product(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      quantity: quantity,
      expiryDate: expiryDate,
      description: description,
      isExpired: expiryDate.isBefore(DateTime.now()),
      createdAt: DateTime.now(),
    );
  }
}
