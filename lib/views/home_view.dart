import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stocky/views/add_product_view.dart';
import 'package:stocky/views/update_product_view.dart';
import '../../models/product.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../services/hive_service.dart';
import '../../widgets/section_header.dart';
import '../../widgets/product_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/bottom_navbar.dart';

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
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                ),
              ),
              backgroundColor: Colors.green,
              elevation: 0,
              actions: [
                IconButton(
                  icon: Icon(Icons.search, color: Colors.white),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.notifications_none, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
            body: vm.isLoading
                ? Center(child: CircularProgressIndicator())
                : !vm.hasProducts
                ? EmptyState(
                    onAddPressed: () => _navigateToAddProduct(context, vm),
                  )
                : RefreshIndicator(
                    onRefresh: vm.refresh,
                    child: ListView(
                      padding: EdgeInsets.all(16),
                      children: [
                        if (vm.urgentProducts.isNotEmpty) ...[
                          SectionHeader(
                            title: 'URGENTE',
                            subtitle: '1-2 DÍAS',
                            color: Colors.red,
                          ),
                          ...vm.urgentProducts.map(
                            (p) => ProductCard(
                              product: p,
                              color: vm.getExpiryColor(p),
                              onTap: () =>
                                  _navigateToUpdateProduct(context, vm, p),
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                        if (vm.soonProducts.isNotEmpty) ...[
                          SectionHeader(
                            title: 'PRÓXIMOS',
                            subtitle: '3-7 DÍAS',
                            color: Colors.orange,
                          ),
                          ...vm.soonProducts.map(
                            (p) => ProductCard(
                              product: p,
                              color: vm.getExpiryColor(p),
                              onTap: () =>
                                  _navigateToUpdateProduct(context, vm, p),
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                        if (vm.stableProducts.isNotEmpty) ...[
                          SectionHeader(
                            title: 'ESTABLES',
                            subtitle: '+1 SEMANA',
                            color: Colors.green,
                          ),
                          ...vm.stableProducts.map(
                            (p) => ProductCard(
                              product: p,
                              color: vm.getExpiryColor(p),
                              onTap: () =>
                                  _navigateToUpdateProduct(context, vm, p),
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                        if (vm.expiredProducts.isNotEmpty) ...[
                          SectionHeader(
                            title: 'VENCIDOS',
                            subtitle: 'CONSUMIR YA',
                            color: Colors.grey,
                          ),
                          ...vm.expiredProducts.map(
                            (p) => ProductCard(
                              product: p,
                              color: Colors.grey,
                              onTap: () =>
                                  _navigateToUpdateProduct(context, vm, p),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _navigateToAddProduct(context, vm),
              backgroundColor: Colors.green,
              child: Icon(Icons.add, color: Colors.white),
            ),
            bottomNavigationBar: BottomNavbar(
              currentIndex: vm.selectedIndex,
              onTap: (index) => vm.changeTab(index, context),
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
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddProductView(hiveService: hiveService),
      ),
    );

    if (result == true && context.mounted) {
      await vm.loadProducts();
    }
  }

  Future<void> _navigateToUpdateProduct(
    BuildContext context,
    HomeViewModel vm,
    Product product,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            UpdateProductView(hiveService: hiveService, product: product),
      ),
    );

    if (result == true && context.mounted) {
      await vm.loadProducts();
    }
  }
}
