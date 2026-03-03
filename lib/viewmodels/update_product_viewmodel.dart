import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/hive_service.dart';

class UpdateProductViewModel extends ChangeNotifier {
  final HiveService _hiveService;
  final Product _originalProduct;

  late String _name;
  late int _quantity;
  late double _liquidQuantity;
  late ProductType _type;
  late DateTime _expiryDate;
  late String _description;

  bool _isLoading = false;
  String? _errorMessage;

  String get name => _name;
  int get quantity => _quantity;
  double get liquidQuantity => _liquidQuantity;
  ProductType get type => _type;
  bool get isLiquid => _type == ProductType.liquid;
  DateTime get expiryDate => _expiryDate;
  String get description => _description;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isFormValid => _name.trim().isNotEmpty;
  bool get hasChanges {
    return _name != _originalProduct.name ||
        _quantity != _originalProduct.quantity ||
        _liquidQuantity != _originalProduct.liquidQuantity ||
        _type != _originalProduct.type ||
        _expiryDate != _originalProduct.expiryDate ||
        _description != (_originalProduct.description ?? '');
  }

  UpdateProductViewModel(this._hiveService, this._originalProduct) {
    _name = _originalProduct.name;
    _quantity = _originalProduct.quantity;
    _liquidQuantity = _originalProduct.liquidQuantity;
    _type = _originalProduct.type;
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

  void updateLiquidQuantity(double value) {
    _liquidQuantity = value;
    notifyListeners();
  }

  void setProductType(ProductType type) {
    _type = type;
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

  Future<void> markAsUsed() async {
    if (_type == ProductType.liquid) {
      if (_liquidQuantity > 0.5) {
        _liquidQuantity -= 0.5;
      } else {
        await _hiveService.deleteProduct(_originalProduct.id);
        notifyListeners();
        return;
      }
    } else {
      if (_quantity > 1) {
        _quantity--;
      } else {
        await _hiveService.deleteProduct(_originalProduct.id);
        notifyListeners();
        return;
      }
    }

    final updatedProduct = Product(
      id: _originalProduct.id,
      name: _name,
      quantity: _type == ProductType.solid ? _quantity : 0,
      liquidQuantity: _type == ProductType.liquid ? _liquidQuantity : 0.0,
      type: _type,
      expiryDate: _expiryDate,
      description: _description.isEmpty ? null : _description,
      isExpired: _expiryDate.isBefore(DateTime.now()),
      createdAt: _originalProduct.createdAt,
    );

    await _hiveService.updateProduct(updatedProduct);
    notifyListeners();
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
        quantity: _type == ProductType.solid ? _quantity : 0,
        liquidQuantity: _type == ProductType.liquid ? _liquidQuantity : 0.0,
        type: _type,
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
