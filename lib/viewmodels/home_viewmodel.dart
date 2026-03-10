import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../models/product.dart';

class HomeViewModel extends ChangeNotifier {
  final HiveService _hiveService;

  List<Product> _products = [];
  bool _isLoading = true;
  int _selectedIndex = 0;
  String? _errorMessage;
  String _searchQuery = '';

  // Getters básicos
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  int get selectedIndex => _selectedIndex;
  String? get errorMessage => _errorMessage;
  bool get hasProducts => _products.isNotEmpty;

  // Getters de búsqueda
  bool get isSearching => _searchQuery.isNotEmpty;
  int get searchResultsCount => displayedProducts.length;

  List<Product> get displayedProducts {
    if (_searchQuery.isEmpty) {
      return _products;
    }

    final query = _searchQuery.toLowerCase();
    return _products.where((product) {
      return product.name.toLowerCase().contains(query) ||
          (product.description?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  List<Product> get urgentProducts => displayedProducts.where((p) {
    final daysLeft = p.expiryDate.difference(DateTime.now()).inDays;
    return daysLeft <= 2 && daysLeft >= 0 && !p.isExpired;
  }).toList();

  List<Product> get soonProducts => displayedProducts.where((p) {
    final daysLeft = p.expiryDate.difference(DateTime.now()).inDays;
    return daysLeft > 2 && daysLeft <= 7 && !p.isExpired;
  }).toList();

  List<Product> get stableProducts => displayedProducts.where((p) {
    final daysLeft = p.expiryDate.difference(DateTime.now()).inDays;
    return daysLeft > 7 && !p.isExpired;
  }).toList();

  List<Product> get expiredProducts =>
      displayedProducts.where((p) => p.isExpired).toList();

  // Color según urgencia
  Color getExpiryColor(Product product) {
    if (product.isExpired) return Colors.grey;
    final daysLeft = product.expiryDate.difference(DateTime.now()).inDays;
    if (daysLeft <= 2) return Colors.red;
    if (daysLeft <= 7) return Colors.orange;
    return Colors.green;
  }

  // Constructor
  HomeViewModel(this._hiveService) {
    loadProducts();
  }

  // Cargar productos
  Future<void> loadProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _products = _hiveService.getAllProducts();
      _isLoading = false;
    } catch (e) {
      _errorMessage = 'Error al cargar productos';
      _isLoading = false;
    }

    notifyListeners();
  }

  // Eliminar producto
  Future<bool> deleteProduct(Product product) async {
    try {
      await _hiveService.deleteProduct(product.id);
      await loadProducts();
      return true;
    } catch (e) {
      _errorMessage = 'Error al eliminar';
      notifyListeners();
      return false;
    }
  }

  // Cambiar pestaña
  void changeTab(int index, BuildContext context) {
    _selectedIndex = index;
    notifyListeners();

    switch (index) {
      case 0:
        break;

      case 1:
        Navigator.pushNamed(context, '/shopping-list').then((_) {
          _selectedIndex = 0;
          notifyListeners();
        });
        break;

      case 2:
        Navigator.pushNamed(context, '/settings').then((_) {
          _selectedIndex = 0;
          notifyListeners();
        });
        break;
    }
  }

  // Refresh manual
  Future<void> refresh() async {
    await loadProducts();
  }

  // Métodos de búsqueda
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
}

class SettingsView {
  const SettingsView();
}
