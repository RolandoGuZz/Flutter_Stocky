import 'package:flutter/material.dart';

class ShoppingHeader extends StatelessWidget {
  final int purchasedCount;
  final VoidCallback? onClearPressed;

  const ShoppingHeader({
    super.key,
    required this.purchasedCount,
    this.onClearPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Tu Lista',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          TextButton.icon(
            onPressed: purchasedCount > 0 ? onClearPressed : null,
            icon: Icon(Icons.cleaning_services, size: 18),
            label: Text('Limpiar'),
            style: TextButton.styleFrom(
              foregroundColor: purchasedCount > 0 ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
