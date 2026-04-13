import 'package:flutter/material.dart';
import 'package:stocky/services/notification_service.dart';
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
  bool get isFormValid {
    if (_name.trim().isEmpty) return false;
    if (_selectedType == ProductType.solid) return _quantity > 0;
    // Para líquidos: debe tener al menos 0.1 litros al agregar
    return _liquidQuantity > 0;
  }

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

  Future<int?> _scheduleNotification(Product product) async {
    final notificationDate = product.expiryDate.subtract(
      const Duration(seconds: 10),
    );

    if (notificationDate.isAfter(DateTime.now())) {
      final notificationId = product.id.hashCode;

      await NotificationService().scheduleNotification(
        id: notificationId,
        title: '📅 Producto por caducar',
        body: '${product.name} caduca en 2 días',
        scheduledDate: notificationDate,
        payload: product.id,
      );

      return notificationId;
    }
    return null;
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
      // Calcular correctamente: vencido solo si la fecha es ANTERIOR a hoy
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final isExpired = _expiryDate.isBefore(todayStart);

      final tempProduct = Product(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _name,
        quantity: _selectedType == ProductType.solid ? _quantity : 0,
        liquidQuantity: _selectedType == ProductType.liquid
            ? _liquidQuantity
            : 0.0,
        type: _selectedType,
        expiryDate: _expiryDate,
        description: _description.isEmpty ? null : _description,
        isExpired: isExpired,
        createdAt: DateTime.now(),
        notificationId: null,
      );

      final notificationId = await _scheduleNotification(tempProduct);

      final product = Product(
        id: tempProduct.id,
        name: tempProduct.name,
        quantity: tempProduct.quantity,
        liquidQuantity: tempProduct.liquidQuantity,
        type: tempProduct.type,
        expiryDate: tempProduct.expiryDate,
        description: tempProduct.description,
        isExpired: tempProduct.isExpired,
        createdAt: tempProduct.createdAt,
        notificationId: notificationId,
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

  // Future<bool> saveProduct() async {
  //   if (!isFormValid) {
  //     _errorMessage = 'Nombre y cantidad son obligatorios';
  //     notifyListeners();
  //     return false;
  //   }

  //   _isLoading = true;
  //   _errorMessage = null;
  //   notifyListeners();

  //   try {
  //     final product = Product.create(
  //       name: _name,
  //       quantity: _selectedType == ProductType.solid ? _quantity : 0,
  //       liquidQuantity: _selectedType == ProductType.liquid
  //           ? _liquidQuantity
  //           : 0.0,
  //       type: _selectedType,
  //       expiryDate: _expiryDate,
  //       description: _description.isEmpty ? null : _description,
  //     );

  //     await _hiveService.addProduct(product);

  //     _isLoading = false;
  //     notifyListeners();
  //     return true;
  //   } catch (e) {
  //     _isLoading = false;
  //     _errorMessage = 'Error al guardar: $e';
  //     notifyListeners();
  //     return false;
  //   }
  // }

  void resetForm() {
    _name = '';
    _quantity = 1;
    _expiryDate = DateTime.now().add(const Duration(days: 7));
    _description = '';
    _errorMessage = null;
    notifyListeners();
  }
}
