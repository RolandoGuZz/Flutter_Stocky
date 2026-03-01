import 'package:flutter/material.dart';

class ShoppingListView extends StatefulWidget {
  const ShoppingListView({super.key});

  @override
  State<ShoppingListView> createState() => _ShoppingListViewState();
}

class _ShoppingListViewState extends State<ShoppingListView> {
  final List<Map<String, dynamic>> _pendingItems = [
    {
      'name': 'Manzanas',
      'category': 'Frutas',
      'quantity': '1kg',
      'checked': false,
    },
    {
      'name': 'Leche 1L',
      'category': 'Lácteos',
      'quantity': '2 unidades',
      'checked': false,
    },
    {
      'name': 'Pan integral',
      'category': 'Panadería',
      'quantity': '1 bolsa',
      'checked': false,
    },
  ];

  final List<Map<String, dynamic>> _purchasedItems = [
    {'name': 'Café de grano', 'category': 'Bebidas', 'quantity': '1 paquete'},
    {'name': 'Huevos x12', 'category': 'Huevos', 'quantity': '1 docena'},
  ];

  @override
  Widget build(BuildContext context) {
    final pendingCount = _pendingItems.length;
    final purchasedCount = _purchasedItems.length;
    final totalCount = pendingCount + purchasedCount;
    final progress = totalCount > 0 ? (purchasedCount / totalCount) : 0.0;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Shopping List',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Lista de Compra',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.cleaning_services, size: 18),
                  label: const Text('Limpiar'),
                  style: TextButton.styleFrom(foregroundColor: Colors.green),
                ),
              ],
            ),
          ),

          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tu Progreso',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      '$pendingCount por comprar, $purchasedCount comprados',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.green,
                    ),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                Text(
                  'Pendientes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 8),
                ..._pendingItems.map(
                  (item) => _buildShoppingItem(
                    name: item['name'],
                    category: item['category'],
                    quantity: item['quantity'],
                    isChecked: item['checked'],
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Comprados',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      '$purchasedCount items',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ..._purchasedItems.map(
                  (item) => _buildPurchasedItem(
                    name: item['name'],
                    category: item['category'],
                    quantity: item['quantity'],
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Añadir nuevo item...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      suffixIcon: Icon(
                        Icons.add_circle_outline,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingItem({
    required String name,
    required String category,
    required String quantity,
    required bool isChecked,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Checkbox(
          value: isChecked,
          onChanged: (value) {},
          activeColor: Colors.green,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
        subtitle: Text(
          '$category • $quantity',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert, size: 20),
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _buildPurchasedItem({
    required String name,
    required String category,
    required String quantity,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListTile(
        leading: Icon(Icons.check_circle, color: Colors.green[300], size: 24),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: Colors.grey[600],
            decoration: TextDecoration.lineThrough,
          ),
        ),
        subtitle: Text(
          '$category • $quantity',
          style: TextStyle(fontSize: 13, color: Colors.grey[500]),
        ),
        trailing: IconButton(
          icon: Icon(Icons.restore, size: 20, color: Colors.grey[600]),
          onPressed: () {},
        ),
      ),
    );
  }
}
