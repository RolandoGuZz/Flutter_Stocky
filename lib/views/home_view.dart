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
import '../../widgets/search_bar.dart';

class HomeView extends StatefulWidget {
  final String userName;
  final HiveService hiveService;

  const HomeView({
    super.key,
    required this.userName,
    required this.hiveService,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _showSearch = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(widget.hiveService),
      child: Consumer<HomeViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              title: _showSearch
                  ? null
                  : Text(
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
                  icon: Icon(_showSearch ? Icons.close : Icons.search),
                  color: Colors.white,
                  onPressed: () {
                    setState(() {
                      _showSearch = !_showSearch;
                      if (!_showSearch) {
                        vm.clearSearch();
                      }
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.notifications_none, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
            body: Column(
              children: [
                if (_showSearch)
                  CustomSearchBar(
                    onChanged: vm.updateSearchQuery,
                    onClose: () {
                      setState(() {
                        _showSearch = false;
                        vm.clearSearch();
                      });
                    },
                    isSearching: vm.isSearching,
                    resultCount: vm.searchResultsCount,
                  ),

                Expanded(
                  child: vm.isLoading
                      ? Center(child: CircularProgressIndicator())
                      : !vm.hasProducts
                      ? EmptyState(
                          onAddPressed: () =>
                              _navigateToAddProduct(context, vm),
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
                                    onTap: () => _navigateToUpdateProduct(
                                      context,
                                      vm,
                                      p,
                                    ),
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
                                    onTap: () => _navigateToUpdateProduct(
                                      context,
                                      vm,
                                      p,
                                    ),
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
                                    onTap: () => _navigateToUpdateProduct(
                                      context,
                                      vm,
                                      p,
                                    ),
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
                                    onTap: () => _navigateToUpdateProduct(
                                      context,
                                      vm,
                                      p,
                                    ),
                                  ),
                                ),
                              ],

                              if (vm.isSearching &&
                                  vm.searchResultsCount == 0) ...[
                                SizedBox(height: 40),
                                Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.search_off,
                                        size: 60,
                                        color: Colors.grey[400],
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'No se encontraron productos',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Intenta con otra búsqueda',
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                ),
              ],
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
        builder: (_) => AddProductView(hiveService: widget.hiveService),
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
        builder: (_) => UpdateProductView(
          hiveService: widget.hiveService,
          product: product,
        ),
      ),
    );

    if (result == true && context.mounted) {
      await vm.loadProducts();
    }
  }
}
