import 'package:flutter/material.dart';
import '../models/shopping_item.dart';
import '../services/hive_service.dart';

class ShoppingViewModel extends ChangeNotifier {
  final HiveService _hiveService;

  List<ShoppingItem> _pendingItems = [];
  List<ShoppingItem> _purchasedItems = [];
  bool _isLoading = false;

  List<ShoppingItem> get pendingItems => _pendingItems;
  List<ShoppingItem> get purchasedItems => _purchasedItems;
  bool get isLoading => _isLoading;
  int get pendingCount => _pendingItems.length;
  int get purchasedCount => _purchasedItems.length;
  double get progress {
    final total = pendingCount + purchasedCount;
    return total > 0 ? purchasedCount / total : 0.0;
  }

  ShoppingViewModel(this._hiveService) {
    loadItems();
  }

  Future<void> loadItems() async {
    _isLoading = true;
    notifyListeners();

    _pendingItems = _hiveService.getPendingShoppingItems();
    _purchasedItems = _hiveService.getPurchasedShoppingItems();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> togglePurchased(String itemId) async {
    _pendingItems.firstWhere((i) => i.id == itemId);
    await _hiveService.markAsPurchased(itemId);
    await loadItems();
  }

  Future<void> restoreItem(String itemId) async {
    await _hiveService.restoreItem(itemId);
    await loadItems();
  }

  Future<void> deleteItem(String itemId) async {
    await _hiveService.removeFromShoppingList(itemId);
    await loadItems();
  }

  Future<void> clearPurchased() async {
    await _hiveService.clearPurchased();
    await loadItems();
  }

  Future<void> addManualItem(String name) async {
    if (name.trim().isEmpty) return;

    final item = ShoppingItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      quantity: '1 unidad',
      isPurchased: false,
      createdAt: DateTime.now(),
    );

    await _hiveService.addToShoppingList(item);
    await loadItems();
  }
}
