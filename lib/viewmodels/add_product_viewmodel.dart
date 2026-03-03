import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/hive_service.dart';

class AddProductViewModel extends ChangeNotifier {
  final HiveService _hiveService;

  String _name = '';
  int _quantity = 1;
  DateTime _expiryDate = DateTime.now();
  String _description = '';

  bool _isLoading = false;
  String? _errorMessage;

  ProductType _selectedType = ProductType.solid;
  double _liquidQuantity = 1.0;

  String get name => _name;
  int get quantity => _quantity;
  DateTime get expiryDate => _expiryDate;
  String get description => _description;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isFormValid => _name.trim().isNotEmpty && _quantity > 0;
  ProductType get selectedType => _selectedType;
  double get liquidQuantity => _liquidQuantity;
  bool get isLiquid => _selectedType == ProductType.liquid;

  AddProductViewModel(this._hiveService);

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

  void setProductType(ProductType type) {
    _selectedType = type;
    notifyListeners();
  }

  void updateLiquidQuantity(double value) {
    _liquidQuantity = value;
    notifyListeners();
  }

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
        quantity: _selectedType == ProductType.solid ? _quantity : 0,
        liquidQuantity: _selectedType == ProductType.liquid
            ? _liquidQuantity
            : 0.0,
        type: _selectedType,
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

  void resetForm() {
    _name = '';
    _quantity = 1;
    _expiryDate = DateTime.now().add(const Duration(days: 7));
    _description = '';
    _errorMessage = null;
    notifyListeners();
  }
}
