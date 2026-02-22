import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../models/product.dart';

class HomeViewModel extends ChangeNotifier {
  final HiveService _hiveService;

  List<Product> _products = [];
  bool _isLoading = true;
  int _selectedIndex = 0;
  String? _errorMessage;

  // Getters
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  int get selectedIndex => _selectedIndex;
  String? get errorMessage => _errorMessage;
  bool get hasProducts => _products.isNotEmpty;

  // Productos filtrados por estado
  List<Product> get urgentProducts => _products.where((p) {
    final daysLeft = p.expiryDate.difference(DateTime.now()).inDays;
    return daysLeft <= 2 && daysLeft >= 0 && !p.isExpired;
  }).toList();

  List<Product> get soonProducts => _products.where((p) {
    final daysLeft = p.expiryDate.difference(DateTime.now()).inDays;
    return daysLeft > 2 && daysLeft <= 7 && !p.isExpired;
  }).toList();

  List<Product> get stableProducts => _products.where((p) {
    final daysLeft = p.expiryDate.difference(DateTime.now()).inDays;
    return daysLeft > 7 && !p.isExpired;
  }).toList();

  List<Product> get expiredProducts =>
      _products.where((p) => p.isExpired).toList();

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

  // Marcar como usado
  Future<bool> markAsUsed(Product product) async {
    return false;
  }

  // Cambiar pestaña del bottom nav
  void changeTab(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  // Refresh manual
  Future<void> refresh() async {
    await loadProducts();
  }
}
