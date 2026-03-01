import 'package:flutter/material.dart';

class ProductIcon extends StatelessWidget {
  final String productName;
  final Color color;

  const ProductIcon({
    super.key,
    required this.productName,
    required this.color,
  });

  IconData _getIcon() {
    final name = productName.toLowerCase();
    if (name.contains('leche') || name.contains('yogurt')) return Icons.opacity;
    if (name.contains('pollo') || name.contains('carne')) return Icons.restaurant;
    if (name.contains('arroz') || name.contains('pasta')) return Icons.grain;
    if (name.contains('huevo')) return Icons.egg;
    if (name.contains('manzana') || name.contains('fruta')) return Icons.apple;
    return Icons.kitchen;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(_getIcon(), color: color),
    );
  }
}
