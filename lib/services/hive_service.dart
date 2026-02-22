import 'package:hive_flutter/hive_flutter.dart';
import 'package:stocky/models/product.dart';
import '../models/user_preferences.dart';

class HiveService {
  static const String _userBox = 'user_preferences_box';
  static const String _productsBox = 'product_box';

  late Box<UserPreferences> _userBoxInstance;
  late Box<Product> _productsBoxInstance;

  Future<void> init() async {
    await Hive.initFlutter();

    // Registrar adaptadores
    Hive.registerAdapter(UserPreferencesAdapter());
    Hive.registerAdapter(ProductAdapter());

    // Abrir cajas
    _userBoxInstance = await Hive.openBox<UserPreferences>(_userBox);
    _productsBoxInstance = await Hive.openBox<Product>(_productsBox);

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
}
