import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_icon.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final Color color;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.color,
    required this.onTap,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) return 'Hoy';
    if (difference == 1) return 'Mañana';
    if (difference == -1) return 'Ayer';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getQuantityText() {
    if (product.type == ProductType.liquid) {
      return 'Cantidad: ${product.liquidQuantity.toStringAsFixed(1)} L';
    } else {
      return 'Cantidad: ${product.quantity} ${product.description ?? 'ud.'}';
    }
  }

  IconData _getQuantityIcon() {
    return product.type == ProductType.liquid
        ? Icons.water_drop
        : Icons.production_quantity_limits;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 6),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: EdgeInsets.all(12),
          leading: ProductIcon(productName: product.name, color: color),
          title: Text(
            product.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 4),
              Row(
                children: [
                  Icon(_getQuantityIcon(), size: 14, color: Colors.grey[600]),
                  SizedBox(width: 4),
                  Text(
                    _getQuantityText(),
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
              SizedBox(height: 2),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: color),
                  SizedBox(width: 4),
                  Text(
                    'Caduca: ${_formatDate(product.expiryDate)}',
                    style: TextStyle(color: color, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          trailing: Icon(Icons.chevron_right, color: Colors.green, size: 28),
        ),
      ),
    );
  }
}
