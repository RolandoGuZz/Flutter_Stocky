import 'package:flutter_test/flutter_test.dart';
import 'package:stocky/models/product.dart';
import 'package:stocky/models/shopping_item.dart';

void main() {
  group('ShoppingItem', () {
    test('debería crear item de compra con campos requeridos', () {
      final item = ShoppingItem(
        id: '1',
        name: 'Artículo de prueba',
        quantity: '5 unidades',
        isPurchased: false,
        createdAt: DateTime.now(),
      );

      expect(item.id, '1');
      expect(item.name, 'Artículo de prueba');
      expect(item.quantity, '5 unidades');
      expect(item.isPurchased, false);
    });

    test('debería crear item de compra con campos opcionales', () {
      final item = ShoppingItem(
        id: '1',
        name: 'Artículo de prueba',
        category: 'Frutas',
        quantity: '3 unidades',
        notes: 'Algunas notas',
        isPurchased: true,
        originalProductId: 'product-123',
        createdAt: DateTime.now(),
      );

      expect(item.category, 'Frutas');
      expect(item.notes, 'Algunas notas');
      expect(item.isPurchased, true);
      expect(item.originalProductId, 'product-123');
    });

    group('fromProduct', () {
      test('debería convertir producto sólido a item de compra', () {
        final product = Product(
          id: 'prod-1',
          name: 'Manzana',
          quantity: 5,
          liquidQuantity: 0,
          type: ProductType.solid,
          expiryDate: DateTime.now().add(const Duration(days: 7)),
          isExpired: false,
          createdAt: DateTime.now(),
        );

        final item = ShoppingItem.fromProduct(product);

        expect(item.name, 'Manzana');
        expect(item.quantity.contains('5'), true);
        expect(item.isPurchased, false);
        expect(item.originalProductId, 'prod-1');
        expect(item.id.isNotEmpty, true);
      });

      test(
        'debería convertir producto líquido a item de compra con litros',
        () {
          final product = Product(
            id: 'prod-1',
            name: 'Leche',
            quantity: 0,
            liquidQuantity: 2.5,
            type: ProductType.liquid,
            expiryDate: DateTime.now().add(const Duration(days: 7)),
            isExpired: false,
            createdAt: DateTime.now(),
          );

          final item = ShoppingItem.fromProduct(product);

          expect(item.name, 'Leche');
          expect(item.quantity.contains('L'), true);
          expect(item.quantity.contains('2.5'), true);
        },
      );

      test('debería asignar categoría Frutas para nombres de frutas', () {
        final product = Product(
          id: 'prod-1',
          name: 'Manzana',
          quantity: 3,
          liquidQuantity: 0,
          type: ProductType.solid,
          expiryDate: DateTime.now().add(const Duration(days: 7)),
          isExpired: false,
          createdAt: DateTime.now(),
        );

        final item = ShoppingItem.fromProduct(product);

        expect(item.category, 'Frutas');
      });

      test('debería asignar categoría Lácteos para productos lácteos', () {
        final product = Product(
          id: 'prod-1',
          name: 'Leche',
          quantity: 1,
          liquidQuantity: 0,
          type: ProductType.solid,
          expiryDate: DateTime.now().add(const Duration(days: 7)),
          isExpired: false,
          createdAt: DateTime.now(),
        );

        final item = ShoppingItem.fromProduct(product);

        expect(item.category, 'Lácteos');
      });

      test('debería asignar categoría Carnes para productos de carne', () {
        final product = Product(
          id: 'prod-1',
          name: 'Pollo',
          quantity: 1,
          liquidQuantity: 0,
          type: ProductType.solid,
          expiryDate: DateTime.now().add(const Duration(days: 7)),
          isExpired: false,
          createdAt: DateTime.now(),
        );

        final item = ShoppingItem.fromProduct(product);

        expect(item.category, 'Carnes');
      });

      test('debería asignar categoría Otros para productos no reconocidos', () {
        final product = Product(
          id: 'prod-1',
          name: 'Pan',
          quantity: 1,
          liquidQuantity: 0,
          type: ProductType.solid,
          expiryDate: DateTime.now().add(const Duration(days: 7)),
          isExpired: false,
          createdAt: DateTime.now(),
        );

        final item = ShoppingItem.fromProduct(product);

        expect(item.category, 'Otros');
      });

      test('debería incluir descripción del producto en notas', () {
        final product = Product(
          id: 'prod-1',
          name: 'Manzana',
          quantity: 3,
          liquidQuantity: 0,
          type: ProductType.solid,
          expiryDate: DateTime.now().add(const Duration(days: 7)),
          description: 'Roja y dulce',
          isExpired: false,
          createdAt: DateTime.now(),
        );

        final item = ShoppingItem.fromProduct(product);

        expect(item.notes, 'Roja y dulce');
      });
    });
  });
}
