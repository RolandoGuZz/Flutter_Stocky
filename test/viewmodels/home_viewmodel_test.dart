import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stocky/models/product.dart';
import 'package:stocky/services/hive_service.dart';
import 'package:stocky/viewmodels/home_viewmodel.dart';

class MockHiveService extends Mock implements HiveService {}

void main() {
  late MockHiveService mockHiveService;
  late HomeViewModel viewModel;

  setUp(() {
    mockHiveService = MockHiveService();
  });

  Product createProduct({
    String id = '1',
    String name = 'Producto de prueba',
    int quantity = 5,
    ProductType type = ProductType.solid,
    int daysFromNow = 7,
    bool isExpiredOverride = false,
  }) {
    return Product(
      id: id,
      name: name,
      quantity: quantity,
      liquidQuantity: type == ProductType.liquid ? 2.0 : 0,
      type: type,
      expiryDate: isExpiredOverride
          ? DateTime.now().subtract(const Duration(days: 1))
          : DateTime.now().add(Duration(days: daysFromNow)),
      isExpired: isExpiredOverride,
      createdAt: DateTime.now(),
    );
  }

  group('HomeViewModel', () {
    test('debería cargar productos al inicializar', () async {
      final products = [
        createProduct(id: '1', name: 'Manzana'),
        createProduct(id: '2', name: 'Leche'),
      ];
      when(() => mockHiveService.getAllProducts()).thenReturn(products);

      viewModel = HomeViewModel(mockHiveService);

      await Future.delayed(const Duration(milliseconds: 100));

      expect(viewModel.products.length, 2);
      expect(viewModel.isLoading, false);
    });

    test('debería retornar false para hasProducts cuando está vacío', () {
      when(() => mockHiveService.getAllProducts()).thenReturn([]);

      viewModel = HomeViewModel(mockHiveService);

      expect(viewModel.hasProducts, false);
    });

    test('debería retornar true para hasProducts cuando no está vacío', () {
      when(
        () => mockHiveService.getAllProducts(),
      ).thenReturn([createProduct()]);

      viewModel = HomeViewModel(mockHiveService);

      expect(viewModel.hasProducts, true);
    });

    group('funcionalidad de búsqueda', () {
      test('debería filtrar productos por nombre', () async {
        final products = [
          createProduct(id: '1', name: 'Manzana'),
          createProduct(id: '2', name: 'Leche'),
          createProduct(id: '3', name: 'Mantequilla'),
        ];
        when(() => mockHiveService.getAllProducts()).thenReturn(products);

        viewModel = HomeViewModel(mockHiveService);
        await Future.delayed(const Duration(milliseconds: 100));

        viewModel.updateSearchQuery('man');

        expect(viewModel.displayedProducts.length, 2);
        expect(viewModel.searchResultsCount, 2);
      });

      test('debería filtrar productos por descripción', () async {
        final products = [
          createProduct(id: '1', name: 'Manzana', quantity: 5),
          createProduct(id: '2', name: 'Leche', quantity: 5),
        ];
        when(() => mockHiveService.getAllProducts()).thenReturn(products);

        viewModel = HomeViewModel(mockHiveService);
        await Future.delayed(const Duration(milliseconds: 100));

        viewModel.updateSearchQuery('manzana');

        expect(viewModel.displayedProducts.length, 1);
      });

      test(
        'debería retornar todos los productos cuando búsqueda está vacía',
        () async {
          final products = [
            createProduct(id: '1', name: 'Manzana'),
            createProduct(id: '2', name: 'Leche'),
          ];
          when(() => mockHiveService.getAllProducts()).thenReturn(products);

          viewModel = HomeViewModel(mockHiveService);
          await Future.delayed(const Duration(milliseconds: 100));

          expect(viewModel.isSearching, false);
          expect(viewModel.displayedProducts.length, 2);
        },
      );

      test('debería limpiar búsqueda', () async {
        final products = [
          createProduct(id: '1', name: 'Manzana'),
          createProduct(id: '2', name: 'Leche'),
        ];
        when(() => mockHiveService.getAllProducts()).thenReturn(products);

        viewModel = HomeViewModel(mockHiveService);
        await Future.delayed(const Duration(milliseconds: 100));

        viewModel.updateSearchQuery('man');
        expect(viewModel.displayedProducts.length, 1);

        viewModel.clearSearch();
        expect(viewModel.displayedProducts.length, 2);
        expect(viewModel.isSearching, false);
      });

      test('debería sercase insensitive', () async {
        final products = [
          createProduct(id: '1', name: 'Manzana'),
          createProduct(id: '2', name: 'leche'),
        ];
        when(() => mockHiveService.getAllProducts()).thenReturn(products);

        viewModel = HomeViewModel(mockHiveService);
        await Future.delayed(const Duration(milliseconds: 100));

        viewModel.updateSearchQuery('MANZANA');

        expect(viewModel.displayedProducts.length, 1);
      });
    });

    group('filtros de productos', () {
      test(
        'debería retornar productos urgentes (vencen en <= 2 días)',
        () async {
          final products = [
            createProduct(id: '1', name: 'Urgente', daysFromNow: 1),
            createProduct(id: '2', name: 'Leche', daysFromNow: 5),
            createProduct(id: '3', name: 'Pan', daysFromNow: 10),
          ];
          when(() => mockHiveService.getAllProducts()).thenReturn(products);

          viewModel = HomeViewModel(mockHiveService);
          await Future.delayed(const Duration(milliseconds: 100));

          expect(viewModel.urgentProducts.length, 1);
          expect(viewModel.urgentProducts.first.name, 'Urgente');
        },
      );

      test(
        'debería retornar productos proximos (vencen en 3-7 días)',
        () async {
          final products = [
            createProduct(id: '1', name: 'Próximo', daysFromNow: 5),
            createProduct(id: '2', name: 'Urgente', daysFromNow: 1),
            createProduct(id: '3', name: 'Estable', daysFromNow: 10),
          ];
          when(() => mockHiveService.getAllProducts()).thenReturn(products);

          viewModel = HomeViewModel(mockHiveService);
          await Future.delayed(const Duration(milliseconds: 100));

          expect(viewModel.soonProducts.length, 1);
          expect(viewModel.soonProducts.first.name, 'Próximo');
        },
      );

      test(
        'debería retornar productos estables (vencen en > 7 días)',
        () async {
          final products = [
            createProduct(id: '1', name: 'Estable', daysFromNow: 10),
            createProduct(id: '2', name: 'Próximo', daysFromNow: 5),
          ];
          when(() => mockHiveService.getAllProducts()).thenReturn(products);

          viewModel = HomeViewModel(mockHiveService);
          await Future.delayed(const Duration(milliseconds: 100));

          expect(viewModel.stableProducts.length, 1);
          expect(viewModel.stableProducts.first.name, 'Estable');
        },
      );

      test('debería retornar productos vencidos', () async {
        final products = [
          createProduct(id: '1', name: 'Vencido', isExpiredOverride: true),
          createProduct(id: '2', name: 'Fresco', daysFromNow: 10),
        ];
        when(() => mockHiveService.getAllProducts()).thenReturn(products);

        viewModel = HomeViewModel(mockHiveService);
        await Future.delayed(const Duration(milliseconds: 100));

        expect(viewModel.expiredProducts.length, 1);
        expect(viewModel.expiredProducts.first.name, 'Vencido');
      });
    });

    group('color de vencimiento', () {
      test('debería retornar gris para productos vencidos', () {
        final product = createProduct(isExpiredOverride: true);

        final color = viewModel.getExpiryColor(product);

        expect(color, Colors.grey);
      });

      test('debería retornar rojo para productos urgentes (<=2 días)', () {
        final product = createProduct(daysFromNow: 1);

        final color = viewModel.getExpiryColor(product);

        expect(color, Colors.red);
      });

      test('debería retornar naranja para productos próximos (3-7 días)', () {
        final product = createProduct(daysFromNow: 5);

        final color = viewModel.getExpiryColor(product);

        expect(color, Colors.orange);
      });

      test('debería retornar verde para productos estables (>7 días)', () {
        final product = createProduct(daysFromNow: 10);

        final color = viewModel.getExpiryColor(product);

        expect(color, Colors.green);
      });
    });

    group('eliminar producto', () {
      test('debería eliminar producto exitosamente', () async {
        final product = createProduct(id: '1');
        when(() => mockHiveService.getAllProducts()).thenReturn([product]);
        when(() => mockHiveService.deleteProduct('1')).thenAnswer((_) async {});

        viewModel = HomeViewModel(mockHiveService);
        await Future.delayed(const Duration(milliseconds: 100));

        final result = await viewModel.deleteProduct(product);

        expect(result, true);
        verify(() => mockHiveService.deleteProduct('1')).called(1);
      });

      test('debería retornar false en error de eliminación', () async {
        final product = createProduct(id: '1');
        when(() => mockHiveService.getAllProducts()).thenReturn([product]);
        when(
          () => mockHiveService.deleteProduct('1'),
        ).thenThrow(Exception('Error'));

        viewModel = HomeViewModel(mockHiveService);
        await Future.delayed(const Duration(milliseconds: 100));

        final result = await viewModel.deleteProduct(product);

        expect(result, false);
        expect(viewModel.errorMessage, isNotNull);
      });
    });
  });
}
