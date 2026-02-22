import 'package:flutter/material.dart';
import '../models/product.dart';
import 'product_icon.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final Color color;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onMarkUsed;

  const ProductCard({
    super.key,
    required this.product,
    required this.color,
    this.onDelete,
    this.onEdit,
    this.onMarkUsed,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) return 'Hoy';
    if (difference == 1) return 'Mañana';
    if (difference == -1) return 'Ayer';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ProductIcon(productName: product.name, color: color),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.production_quantity_limits,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  'Cantidad: ${product.quantity} ${product.description ?? 'ud.'}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 14, color: color),
                const SizedBox(width: 4),
                Text(
                  'Caduca: ${_formatDate(product.expiryDate)}',
                  style: TextStyle(color: color, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => [
            if (onEdit != null)
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
            if (onDelete != null)
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Eliminar', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            if (onMarkUsed != null && !product.isExpired)
              const PopupMenuItem(
                value: 'mark_used',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 20, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Marcar como usado'),
                  ],
                ),
              ),
          ],
          onSelected: (value) {
            if (value == 'delete') onDelete?.call();
            if (value == 'edit') onEdit?.call();
            if (value == 'mark_used') onMarkUsed?.call();
          },
        ),
      ),
    );
  }
}
