import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stocky/models/product.dart';
import 'package:stocky/views/add_product_view.dart';
import 'package:stocky/widgets/bottom_navbar.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../widgets/section_header.dart';
import '../../widgets/product_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../services/hive_service.dart';

class HomeView extends StatelessWidget {
  final String userName;
  final HiveService hiveService;

  const HomeView({
    super.key,
    required this.userName,
    required this.hiveService,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(hiveService),
      child: Consumer<HomeViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              title: Text(
                'Stocky',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
              ),
              backgroundColor: Colors.green,
              elevation: 0,
              actions: [
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {
                    // TODO: Implementar búsqueda
                  },
                ),
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    // TODO: Implementar notificaciones
                  },
                ),
              ],
            ),
            body: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : !vm.hasProducts
                ? EmptyState(
                    onAddPressed: () => _navigateToAddProduct(context, vm),
                  )
                : RefreshIndicator(
                    onRefresh: vm.refresh,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (vm.urgentProducts.isNotEmpty) ...[
                          const SectionHeader(
                            title: 'URGENTE',
                            subtitle: '1-2 DÍAS',
                            color: Colors.red,
                          ),
                          ...vm.urgentProducts.map(
                            (p) => ProductCard(
                              product: p,
                              color: vm.getExpiryColor(p),
                              onDelete: () => _confirmAndDelete(context, vm, p),
                              onEdit: () {
                                // TODO: Implementar edición
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        if (vm.soonProducts.isNotEmpty) ...[
                          const SectionHeader(
                            title: 'PRÓXIMOS',
                            subtitle: '3-7 DÍAS',
                            color: Colors.orange,
                          ),
                          ...vm.soonProducts.map(
                            (p) => ProductCard(
                              product: p,
                              color: vm.getExpiryColor(p),
                              onDelete: () => _confirmAndDelete(context, vm, p),
                              onEdit: () {
                                // TODO: Implementar edición
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        if (vm.stableProducts.isNotEmpty) ...[
                          const SectionHeader(
                            title: 'ESTABLES',
                            subtitle: '+1 SEMANA',
                            color: Colors.green,
                          ),
                          ...vm.stableProducts.map(
                            (p) => ProductCard(
                              product: p,
                              color: vm.getExpiryColor(p),
                              onDelete: () => _confirmAndDelete(context, vm, p),
                              onEdit: () {
                                // TODO: Implementar edición
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        if (vm.expiredProducts.isNotEmpty) ...[
                          const SectionHeader(
                            title: 'VENCIDOS',
                            subtitle: 'CONSUMIR YA',
                            color: Colors.grey,
                          ),
                          ...vm.expiredProducts.map(
                            (p) => ProductCard(
                              product: p,
                              color: Colors.grey,
                              onDelete: () => _confirmAndDelete(context, vm, p),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

            floatingActionButton: FloatingActionButton(
              onPressed: () => _navigateToAddProduct(context, vm),
              backgroundColor: Colors.green,
              child: const Icon(Icons.add),
            ),

            bottomNavigationBar: BottomNavbar(
              currentIndex: vm.selectedIndex,
              onTap: vm.changeTab,
              selectedColor: Colors.green,
              unselectedColor: Colors.grey,
            ),
          );
        },
      ),
    );
  }

  Future<void> _navigateToAddProduct(
    BuildContext context,
    HomeViewModel vm,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddProductView(hiveService: hiveService),
      ),
    );
  }

  Future<void> _confirmAndDelete(
    BuildContext context,
    HomeViewModel vm,
    Product product,
  ) async {
    final confirmed = await showConfirmationDialog(
      context: context,
      title: 'Eliminar producto',
      content: '¿Eliminar ${product.name} de tu despensa?',
    );

    if (confirmed == true && context.mounted) {
      final success = await vm.deleteProduct(product);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} eliminado'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
