import 'package:hive/hive.dart';
import 'package:stocky/models/product.dart';

part 'shopping_item.g.dart';

@HiveType(typeId: 3)
class ShoppingItem {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String? category;

  @HiveField(3)
  final String quantity;

  @HiveField(4)
  final String? notes;

  @HiveField(5)
  final bool isPurchased;

  @HiveField(6)
  final String? originalProductId;

  @HiveField(7)
  final DateTime createdAt;

  ShoppingItem({
    required this.id,
    required this.name,
    this.category,
    required this.quantity,
    this.notes,
    required this.isPurchased,
    this.originalProductId,
    required this.createdAt,
  });

  factory ShoppingItem.fromProduct(Product product) {
    return ShoppingItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: product.name,
      category: _getCategoryFromProduct(product),
      quantity: product.type == ProductType.liquid
          ? '${product.liquidQuantity.toStringAsFixed(1)} L'
          : '${product.quantity} ${product.description ?? 'UD'}',
      notes: product.description,
      isPurchased: false,
      originalProductId: product.id,
      createdAt: DateTime.now(),
    );
  }

  static String? _getCategoryFromProduct(Product product) {
    final name = product.name.toLowerCase();
    if (name.contains('leche') || name.contains('yogur')) return 'Lácteos';
    if (name.contains('manzana') || name.contains('platano')) return 'Frutas';
    if (name.contains('pollo') || name.contains('carne')) return 'Carnes';
    if (name.contains('huevo')) return 'Huevos';
    return 'Otros';
  }
}
