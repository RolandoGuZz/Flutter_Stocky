import 'package:flutter/material.dart';
import '../../models/shopping_item.dart';
import '../../viewmodels/shopping_viewmodel.dart';

class ShoppingPurchasedItem extends StatelessWidget {
  final ShoppingItem item;
  final ShoppingViewModel vm;
  final VoidCallback onDelete;

  const ShoppingPurchasedItem({
    super.key,
    required this.item,
    required this.vm,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListTile(
        leading: Icon(Icons.check_circle, color: Colors.green[300], size: 24),
        title: Text(
          item.name,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Colors.grey[600],
            decoration: TextDecoration.lineThrough,
          ),
        ),
        subtitle: Text(
          '${item.category ?? 'Otros'} • ${item.quantity}',
          style: TextStyle(fontSize: 13, color: Colors.grey[500]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.restore, size: 20, color: Colors.grey[600]),
              onPressed: () => vm.restoreItem(item.id),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, size: 20, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
