import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/hive_service.dart';

class UpdateProductViewModel extends ChangeNotifier {
  final HiveService _hiveService;
  final Product _originalProduct;

  late String _name;
  late int _quantity;
  late DateTime _expiryDate;
  late String _description;

  bool _isLoading = false;
  String? _errorMessage;

  String get name => _name;
  int get quantity => _quantity;
  DateTime get expiryDate => _expiryDate;
  String get description => _description;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isFormValid => _name.trim().isNotEmpty && _quantity > 0;
  bool get hasChanges {
    return _name != _originalProduct.name ||
        _quantity != _originalProduct.quantity ||
        _expiryDate != _originalProduct.expiryDate ||
        _description != (_originalProduct.description ?? '');
  }

  UpdateProductViewModel(this._hiveService, this._originalProduct) {
    _name = _originalProduct.name;
    _quantity = _originalProduct.quantity;
    _expiryDate = _originalProduct.expiryDate;
    _description = _originalProduct.description ?? '';
  }

  void updateName(String value) {
    _name = value;
    notifyListeners();
  }

  void updateQuantity(int value) {
    _quantity = value;
    notifyListeners();
  }

  void updateExpiryDate(DateTime date) {
    _expiryDate = date;
    notifyListeners();
  }

  void updateDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void incrementQuantity() {
    _quantity++;
    notifyListeners();
  }

  void decrementQuantity() {
    if (_quantity > 1) {
      _quantity--;
      notifyListeners();
    }
  }

  Future<bool> updateProduct() async {
    if (!isFormValid) {
      _errorMessage = 'El nombre es obligatorio';
      notifyListeners();
      return false;
    }

    if (!hasChanges) {
      _errorMessage = 'No hay cambios para guardar';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedProduct = Product(
        id: _originalProduct.id,
        name: _name,
        quantity: _quantity,
        expiryDate: _expiryDate,
        description: _description.isEmpty ? null : _description,
        isExpired: _expiryDate.isBefore(DateTime.now()),
        createdAt: _originalProduct.createdAt,
      );

      await _hiveService.updateProduct(updatedProduct);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al actualizar: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduct() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _hiveService.deleteProduct(_originalProduct.id);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Error al eliminar';
      notifyListeners();
      return false;
    }
  }
}
