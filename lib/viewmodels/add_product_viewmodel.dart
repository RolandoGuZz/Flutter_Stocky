// lib/viewmodels/add_product_viewmodel.dart
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/hive_service.dart';

class AddProductViewModel extends ChangeNotifier {
  final HiveService _hiveService;

  // Estados del formulario
  String _name = '';
  int _quantity = 1;
  DateTime _expiryDate = DateTime.now().add(const Duration(days: 7));
  String _description = '';

  // Estados de UI
  bool _isLoading = false;
  String? _errorMessage;

  // Getters para la View
  String get name => _name;
  int get quantity => _quantity;
  DateTime get expiryDate => _expiryDate;
  String get description => _description;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isFormValid => _name.trim().isNotEmpty && _quantity > 0;

  AddProductViewModel(this._hiveService);

  // Actualizar nombre
  void updateName(String value) {
    _name = value;
    notifyListeners();
  }

  // Actualizar cantidad
  void updateQuantity(int value) {
    _quantity = value;
    notifyListeners();
  }

  // Actualizar fecha
  void updateExpiryDate(DateTime date) {
    _expiryDate = date;
    notifyListeners();
  }

  // Actualizar descripción
  void updateDescription(String value) {
    _description = value;
    notifyListeners();
  }

  // Incrementar cantidad
  void incrementQuantity() {
    _quantity++;
    notifyListeners();
  }

  // Decrementar cantidad
  void decrementQuantity() {
    if (_quantity > 1) {
      _quantity--;
      notifyListeners();
    }
  }

  // Guardar producto
  Future<bool> saveProduct() async {
    if (!isFormValid) {
      _errorMessage = 'Nombre y cantidad son obligatorios';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final product = Product.create(
        name: _name,
        quantity: _quantity,
        expiryDate: _expiryDate,
        description: _description.isEmpty ? null : _description,
      );

      await _hiveService.addProduct(product);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al guardar: $e';
      notifyListeners();
      return false;
    }
  }

  // Resetear formulario
  void resetForm() {
    _name = '';
    _quantity = 1;
    _expiryDate = DateTime.now().add(const Duration(days: 7));
    _description = '';
    _errorMessage = null;
    notifyListeners();
  }
}
