import 'package:hive_flutter/hive_flutter.dart';
import 'package:stocky/models/product.dart';
import 'package:stocky/models/shopping_item.dart';
import '../models/user_preferences.dart';

class HiveService {
  static const String _userBox = 'user_preferences_box';
  static const String _productsBox = 'product_box';
  static const String _shoppingBox = 'shopping_box';

  late Box<UserPreferences> _userBoxInstance;
  late Box<Product> _productsBoxInstance;
  late Box<ShoppingItem> _shoppingBoxInstance;

  Future<void> init() async {
    await Hive.initFlutter();

    // Registrar adaptadores
    Hive.registerAdapter(UserPreferencesAdapter());
    Hive.registerAdapter(ProductAdapter());
    Hive.registerAdapter(ProductTypeAdapter());
    Hive.registerAdapter(ShoppingItemAdapter());

    // Abrir cajas
    _userBoxInstance = await Hive.openBox<UserPreferences>(_userBox);
    _productsBoxInstance = await Hive.openBox<Product>(_productsBox);
    _shoppingBoxInstance = await Hive.openBox<ShoppingItem>(_shoppingBox);

    if (_userBoxInstance.isEmpty) {
      await _userBoxInstance.put(0, UserPreferences());
    }
  }

  // Métodos de los usuarios

  // Guardar nombre de usuario
  Future<void> saveUserName(String name) async {
    final userPrefs = _userBoxInstance.get(0) ?? UserPreferences();
    userPrefs.userName = name;
    userPrefs.isFirstLaunch = false;
    await _userBoxInstance.put(0, userPrefs);
  }

  // Obtener nombre de usuario
  String? getUserName() {
    return _userBoxInstance.get(0)?.userName;
  }

  // Verificar si es primera vez
  bool isFirstLaunch() {
    return _userBoxInstance.get(0)?.isFirstLaunch ?? true;
  }

  // Métodos del producto

  // Obtener todos los productos
  List<Product> getAllProducts() {
    return _productsBoxInstance.values.toList();
  }

  // Obtener productos vigentes (no vencidos)
  List<Product> getActiveProducts() {
    //final now = DateTime.now();
    return _productsBoxInstance.values
        .where((product) => !product.isExpired)
        .toList();
  }

  // Obtener productos vencidos
  List<Product> getExpiredProducts() {
    return _productsBoxInstance.values
        .where((product) => product.isExpired)
        .toList();
  }

  // Añadir un producto
  Future<void> addProduct(Product product) async {
    await _productsBoxInstance.put(product.id, product);
  }

  // Actualizar un producto
  Future<void> updateProduct(Product product) async {
    await _productsBoxInstance.put(product.id, product);
  }

  // Eliminar un producto
  Future<void> deleteProduct(String productId) async {
    await _productsBoxInstance.delete(productId);
  }

  // Obtener un producto por ID
  Product? getProduct(String productId) {
    return _productsBoxInstance.get(productId);
  }

  // Cerrar Hive (para cuando cierres la app)
  Future<void> close() async {
    await _userBoxInstance.close();
  }

  // Métodos de shopping list

  // Agregar a lista de compra
  Future<void> addToShoppingList(ShoppingItem item) async {
    await _shoppingBoxInstance.put(item.id, item);
  }

  // Obtener todos los items
  List<ShoppingItem> getAllShoppingItems() {
    return _shoppingBoxInstance.values.toList();
  }

  // Obtener pendientes
  List<ShoppingItem> getPendingShoppingItems() {
    return _shoppingBoxInstance.values
        .where((item) => !item.isPurchased)
        .toList();
  }

  // Obtener comprados
  List<ShoppingItem> getPurchasedShoppingItems() {
    return _shoppingBoxInstance.values
        .where((item) => item.isPurchased)
        .toList();
  }

  // Marcar como comprado
  Future<void> markAsPurchased(String itemId) async {
    final item = _shoppingBoxInstance.get(itemId);
    if (item != null) {
      final updated = ShoppingItem(
        id: item.id,
        name: item.name,
        category: item.category,
        quantity: item.quantity,
        notes: item.notes,
        isPurchased: true,
        originalProductId: item.originalProductId,
        createdAt: item.createdAt,
      );
      await _shoppingBoxInstance.put(itemId, updated);
    }
  }

  // Restaurar de comprado a pendiente
  Future<void> restoreItem(String itemId) async {
    final item = _shoppingBoxInstance.get(itemId);
    if (item != null) {
      final updated = ShoppingItem(
        id: item.id,
        name: item.name,
        category: item.category,
        quantity: item.quantity,
        notes: item.notes,
        isPurchased: false,
        originalProductId: item.originalProductId,
        createdAt: item.createdAt,
      );
      await _shoppingBoxInstance.put(itemId, updated);
    }
  }

  // Eliminar de lista de compra
  Future<void> removeFromShoppingList(String itemId) async {
    await _shoppingBoxInstance.delete(itemId);
  }

  // Limpiar comprados
  Future<void> clearPurchased() async {
    final purchased = getPurchasedShoppingItems();
    for (var item in purchased) {
      await _shoppingBoxInstance.delete(item.id);
    }
  }

  // Cuando un producto llega a 0, mandarlo a shopping list
  Future<void> productFinished(Product product) async {
    final shoppingItem = ShoppingItem.fromProduct(product);
    await addToShoppingList(shoppingItem);
  }
}
