import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stocky/widgets/confirmation_dialog.dart';
import 'package:stocky/widgets/shopping_add_input.dart';
import 'package:stocky/widgets/shopping_header.dart';
import 'package:stocky/widgets/shopping_pending_item.dart';
import 'package:stocky/widgets/shopping_progress_bar.dart';
import 'package:stocky/widgets/shopping_purchased_item.dart';
import '../../viewmodels/shopping_viewmodel.dart';
import '../../services/hive_service.dart';
import '../../widgets/bottom_navbar.dart';

class ShoppingListView extends StatelessWidget {
  const ShoppingListView({super.key});

  @override
  Widget build(BuildContext context) {
    final hiveService = Provider.of<HiveService>(context, listen: false);

    return ChangeNotifierProvider(
      create: (_) => ShoppingViewModel(hiveService),
      child: const ShoppingListContent(),
    );
  }
}

class ShoppingListContent extends StatelessWidget {
  const ShoppingListContent({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ShoppingViewModel>();
    final textController = TextEditingController();

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
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : Column(
              children: [
                ShoppingHeader(
                  purchasedCount: vm.purchasedCount,
                  onClearPressed: () async {
                    final confirm = await showConfirmationDialog(
                      context: context,
                      title: 'Limpiar comprados',
                      content: '¿Eliminar todos los items comprados?',
                      confirmText: 'Limpiar',
                      cancelText: 'Cancelar',
                    );
                    if (confirm == true) {
                      await vm.clearPurchased();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Lista limpiada'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  },
                ),
                ShoppingProgressBar(
                  pendingCount: vm.pendingCount,
                  purchasedCount: vm.purchasedCount,
                  progress: vm.progress,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: vm.loadItems,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        if (vm.pendingItems.isNotEmpty) ...[
                          Text(
                            'Pendientes',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...vm.pendingItems.map(
                            (item) => ShoppingPendingItem(
                              item: item,
                              vm: vm,
                              onDelete: () async {
                                final confirm = await showConfirmationDialog(
                                  context: context,
                                  title: 'Eliminar item',
                                  content:
                                      '¿Eliminar "${item.name}" de la lista?',
                                  confirmText: 'Eliminar',
                                  cancelText: 'Cancelar',
                                );
                                if (confirm == true) {
                                  await vm.deleteItem(item.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${item.name} eliminado'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        if (vm.purchasedItems.isNotEmpty) ...[
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
                                '${vm.purchasedCount} items',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ...vm.purchasedItems.map(
                            (item) => ShoppingPurchasedItem(
                              item: item,
                              vm: vm,
                              onDelete: () async {
                                final confirm = await showConfirmationDialog(
                                  context: context,
                                  title: 'Eliminar item',
                                  content:
                                      '¿Eliminar "${item.name}" de la lista?',
                                  confirmText: 'Eliminar',
                                  cancelText: 'Cancelar',
                                );
                                if (confirm == true) {
                                  await vm.deleteItem(item.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${item.name} eliminado'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        ShoppingAddInput(vm: vm, controller: textController),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/home');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/settings');
          }
        },
        selectedColor: Colors.green,
        unselectedColor: Colors.grey,
      ),
    );
  }
}
