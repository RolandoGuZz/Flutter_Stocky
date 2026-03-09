import 'package:flutter/material.dart';
import '../../models/shopping_item.dart';
import '../../viewmodels/shopping_viewmodel.dart';

class ShoppingPendingItem extends StatelessWidget {
  final ShoppingItem item;
  final ShoppingViewModel vm;
  final VoidCallback onDelete;

  const ShoppingPendingItem({
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Checkbox(
          value: false,
          onChanged: (_) => vm.togglePurchased(item.id),
          activeColor: Colors.green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        title: Text(
          item.name,
          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
        subtitle: Text(
          '${item.category ?? 'Otros'} • ${item.quantity}',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, size: 20),
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              // Ver si se queda o elimina
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Eliminar', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'delete') {
              onDelete();
            }
          },
        ),
      ),
    );
  }
}
