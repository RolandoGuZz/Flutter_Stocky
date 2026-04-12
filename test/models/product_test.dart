import 'package:flutter_test/flutter_test.dart';
import 'package:stocky/models/product.dart';

void main() {
  group('Product', () {
    test('debería crear producto con todos los campos requeridos', () {
      final product = Product(
        id: '1',
        name: 'Producto de prueba',
        quantity: 5,
        liquidQuantity: 0,
        type: ProductType.solid,
        expiryDate: DateTime.now().add(const Duration(days: 10)),
        isExpired: false,
        createdAt: DateTime.now(),
      );

      expect(product.id, '1');
      expect(product.name, 'Producto de prueba');
      expect(product.quantity, 5);
      expect(product.type, ProductType.solid);
    });

    test('Product.create debería crear producto sólido con cantidad', () {
      final product = Product.create(
        name: 'Manzana',
        quantity: 10,
        liquidQuantity: 0,
        type: ProductType.solid,
        expiryDate: DateTime.now().add(const Duration(days: 7)),
      );

      expect(product.name, 'Manzana');
      expect(product.quantity, 10);
      expect(product.liquidQuantity, 0);
      expect(product.type, ProductType.solid);
      expect(product.id.isNotEmpty, true);
    });

    test(
      'Product.create debería crear producto líquido con cantidad líquida',
      () {
        final product = Product.create(
          name: 'Leche',
          quantity: 0,
          liquidQuantity: 2.5,
          type: ProductType.liquid,
          expiryDate: DateTime.now().add(const Duration(days: 7)),
        );

        expect(product.name, 'Leche');
        expect(product.quantity, 0);
        expect(product.liquidQuantity, 2.5);
        expect(product.type, ProductType.liquid);
      },
    );

    test('Product.create debería设置 isExpired a true para fecha pasada', () {
      final product = Product.create(
        name: 'Producto vencido',
        quantity: 5,
        liquidQuantity: 0,
        type: ProductType.solid,
        expiryDate: DateTime.now().subtract(const Duration(days: 1)),
      );

      expect(product.isExpired, true);
    });

    test('Product.create debería设置 isExpired a false para fecha futura', () {
      final product = Product.create(
        name: 'Producto fresco',
        quantity: 5,
        liquidQuantity: 0,
        type: ProductType.solid,
        expiryDate: DateTime.now().add(const Duration(days: 10)),
      );

      expect(product.isExpired, false);
    });

    test('Product.create debería aceptar descripción opcional', () {
      final product = Product.create(
        name: 'Producto con descripción',
        quantity: 5,
        liquidQuantity: 0,
        type: ProductType.solid,
        expiryDate: DateTime.now().add(const Duration(days: 7)),
        description: 'Esta es una descripción',
      );

      expect(product.description, 'Esta es una descripción');
    });

    test('Product.create debería设置 createdAt a la hora actual', () {
      final before = DateTime.now();
      final product = Product.create(
        name: 'Test',
        quantity: 1,
        liquidQuantity: 0,
        type: ProductType.solid,
        expiryDate: DateTime.now().add(const Duration(days: 7)),
      );
      final after = DateTime.now();

      expect(
        product.createdAt.isAfter(before.subtract(const Duration(seconds: 1))),
        true,
      );
      expect(
        product.createdAt.isBefore(after.add(const Duration(seconds: 1))),
        true,
      );
    });
  });

  group('ProductType', () {
    test('debería tener tipos sólido y líquido', () {
      expect(ProductType.values.length, 2);
      expect(ProductType.values.contains(ProductType.solid), true);
      expect(ProductType.values.contains(ProductType.liquid), true);
    });
  });
}
