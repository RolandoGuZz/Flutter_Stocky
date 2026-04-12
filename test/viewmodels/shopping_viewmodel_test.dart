import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stocky/models/shopping_item.dart';
import 'package:stocky/services/hive_service.dart';
import 'package:stocky/viewmodels/shopping_viewmodel.dart';

class MockHiveService extends Mock implements HiveService {}

void main() {
  late MockHiveService mockHiveService;
  late ShoppingViewModel viewModel;

  setUpAll(() {
    registerFallbackValue(
      ShoppingItem(
        id: 'fallback',
        name: 'Fallback',
        quantity: '1',
        isPurchased: false,
        createdAt: DateTime.now(),
      ),
    );
  });

  setUp(() {
    mockHiveService = MockHiveService();
    when(() => mockHiveService.getPendingShoppingItems()).thenReturn([]);
    when(() => mockHiveService.getPurchasedShoppingItems()).thenReturn([]);
    viewModel = ShoppingViewModel(mockHiveService);
  });

  ShoppingItem createShoppingItem({
    String id = '1',
    String name = 'Artículo de prueba',
    String quantity = '1 unidad',
    bool isPurchased = false,
  }) {
    return ShoppingItem(
      id: id,
      name: name,
      quantity: quantity,
      isPurchased: isPurchased,
      createdAt: DateTime.now(),
    );
  }

  group('ShoppingViewModel', () {
    test('estado inicial debería tener listas vacías', () {
      expect(viewModel.pendingItems, []);
      expect(viewModel.purchasedItems, []);
      expect(viewModel.isLoading, false);
    });

    test('pendingCount debería retornar conteo correcto', () {
      when(
        () => mockHiveService.getPendingShoppingItems(),
      ).thenReturn([createShoppingItem(), createShoppingItem(id: '2')]);

      viewModel = ShoppingViewModel(mockHiveService);

      expect(viewModel.pendingCount, 2);
    });

    test('purchasedCount debería retornar conteo correcto', () {
      when(
        () => mockHiveService.getPurchasedShoppingItems(),
      ).thenReturn([createShoppingItem(isPurchased: true)]);

      viewModel = ShoppingViewModel(mockHiveService);

      expect(viewModel.purchasedCount, 1);
    });

    group('progress', () {
      test('debería retornar 0 cuando no hay items', () {
        expect(viewModel.progress, 0.0);
      });

      test('debería retornar 0.5 cuando la mitad está comprada', () {
        when(
          () => mockHiveService.getPendingShoppingItems(),
        ).thenReturn([createShoppingItem()]);
        when(
          () => mockHiveService.getPurchasedShoppingItems(),
        ).thenReturn([createShoppingItem(isPurchased: true)]);

        viewModel = ShoppingViewModel(mockHiveService);

        expect(viewModel.progress, 0.5);
      });

      test('debería retornar 1.0 cuando todo está comprado', () {
        when(() => mockHiveService.getPendingShoppingItems()).thenReturn([]);
        when(
          () => mockHiveService.getPurchasedShoppingItems(),
        ).thenReturn([createShoppingItem(isPurchased: true)]);

        viewModel = ShoppingViewModel(mockHiveService);

        expect(viewModel.progress, 1.0);
      });
    });

    group('loadItems', () {
      test('debería cargar items pendientes y comprados', () async {
        final pending = [createShoppingItem(id: '1')];
        final purchased = [createShoppingItem(id: '2', isPurchased: true)];

        when(
          () => mockHiveService.getPendingShoppingItems(),
        ).thenReturn(pending);
        when(
          () => mockHiveService.getPurchasedShoppingItems(),
        ).thenReturn(purchased);

        viewModel = ShoppingViewModel(mockHiveService);
        await viewModel.loadItems();

        expect(viewModel.pendingItems.length, 1);
        expect(viewModel.purchasedItems.length, 1);
      });
    });

    group('restoreItem', () {
      test('debería llamar restoreItem', () async {
        when(() => mockHiveService.restoreItem('1')).thenAnswer((_) async {});
        when(() => mockHiveService.getPendingShoppingItems()).thenReturn([]);
        when(() => mockHiveService.getPurchasedShoppingItems()).thenReturn([]);

        await viewModel.restoreItem('1');

        verify(() => mockHiveService.restoreItem('1')).called(1);
      });
    });

    group('deleteItem', () {
      test('debería llamar removeFromShoppingList', () async {
        when(
          () => mockHiveService.removeFromShoppingList('1'),
        ).thenAnswer((_) async {});
        when(() => mockHiveService.getPendingShoppingItems()).thenReturn([]);
        when(() => mockHiveService.getPurchasedShoppingItems()).thenReturn([]);

        await viewModel.deleteItem('1');

        verify(() => mockHiveService.removeFromShoppingList('1')).called(1);
      });
    });

    group('clearPurchased', () {
      test('debería llamar clearPurchased', () async {
        when(() => mockHiveService.clearPurchased()).thenAnswer((_) async {});
        when(() => mockHiveService.getPendingShoppingItems()).thenReturn([]);
        when(() => mockHiveService.getPurchasedShoppingItems()).thenReturn([]);

        await viewModel.clearPurchased();

        verify(() => mockHiveService.clearPurchased()).called(1);
      });
    });

    group('addManualItem', () {
      test('debería agregar item con nombre dado', () async {
        when(
          () => mockHiveService.addToShoppingList(any()),
        ).thenAnswer((_) async {});
        when(() => mockHiveService.getPendingShoppingItems()).thenReturn([]);
        when(() => mockHiveService.getPurchasedShoppingItems()).thenReturn([]);

        await viewModel.addManualItem('Nuevo artículo');

        verify(() => mockHiveService.addToShoppingList(any())).called(1);
      });

      test('no debería agregar item con nombre vacío', () async {
        await viewModel.addManualItem('   ');

        verifyNever(() => mockHiveService.addToShoppingList(any()));
      });

      test('no debería agregar item con solo espacios', () async {
        await viewModel.addManualItem('');

        verifyNever(() => mockHiveService.addToShoppingList(any()));
      });
    });
  });
}
