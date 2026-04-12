import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stocky/models/product.dart';
import 'package:stocky/services/hive_service.dart';
import 'package:stocky/viewmodels/update_product_viewmodel.dart';

class MockHiveService extends Mock implements HiveService {}

void main() {
  late MockHiveService mockHiveService;
  late Product testProduct;
  late UpdateProductViewModel viewModel;

  setUpAll(() {
    registerFallbackValue(
      Product(
        id: 'fallback',
        name: 'Fallback',
        quantity: 0,
        liquidQuantity: 0,
        type: ProductType.solid,
        expiryDate: DateTime.now(),
        isExpired: false,
        createdAt: DateTime.now(),
      ),
    );
  });

  setUp(() {
    mockHiveService = MockHiveService();
    testProduct = Product(
      id: 'prod-1',
      name: 'Producto de prueba',
      quantity: 5,
      liquidQuantity: 2.0,
      type: ProductType.solid,
      expiryDate: DateTime.now().add(const Duration(days: 7)),
      description: 'Descripción de prueba',
      isExpired: false,
      createdAt: DateTime.now(),
    );
    viewModel = UpdateProductViewModel(mockHiveService, testProduct);
  });

  group('UpdateProductViewModel', () {
    test('estado inicial debería cargar valores del producto', () {
      expect(viewModel.name, 'Producto de prueba');
      expect(viewModel.quantity, 5);
      expect(viewModel.liquidQuantity, 2.0);
      expect(viewModel.type, ProductType.solid);
      expect(viewModel.description, 'Descripción de prueba');
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, null);
    });

    test('isFormValid debería retornar true cuando nombre no está vacío', () {
      expect(viewModel.isFormValid, true);
    });

    test('isFormValid debería retornar false cuando nombre está vacío', () {
      viewModel.updateName('');
      expect(viewModel.isFormValid, false);
    });

    group('hasChanges', () {
      test('debería retornar false cuando no hay cambios', () {
        expect(viewModel.hasChanges, false);
      });

      test('debería retornar true cuando nombre cambia', () {
        viewModel.updateName('Nuevo nombre');
        expect(viewModel.hasChanges, true);
      });

      test('debería retornar true cuando cantidad cambia', () {
        viewModel.updateQuantity(10);
        expect(viewModel.hasChanges, true);
      });

      test('debería retornar true cuando descripción cambia', () {
        viewModel.updateDescription('Nueva descripción');
        expect(viewModel.hasChanges, true);
      });
    });

    group('updateName', () {
      test('debería actualizar nombre', () {
        viewModel.updateName('Nombre actualizado');
        expect(viewModel.name, 'Nombre actualizado');
      });
    });

    group('updateQuantity', () {
      test('debería actualizar cantidad', () {
        viewModel.updateQuantity(10);
        expect(viewModel.quantity, 10);
      });
    });

    group('updateLiquidQuantity', () {
      test('debería actualizar cantidad líquida', () {
        viewModel.updateLiquidQuantity(3.5);
        expect(viewModel.liquidQuantity, 3.5);
      });
    });

    group('setProductType', () {
      test('debería establecer tipo de producto', () {
        viewModel.setProductType(ProductType.liquid);
        expect(viewModel.type, ProductType.liquid);
        expect(viewModel.isLiquid, true);
      });
    });

    group('updateExpiryDate', () {
      test('debería actualizar fecha de vencimiento', () {
        final newDate = DateTime.now().add(const Duration(days: 30));
        viewModel.updateExpiryDate(newDate);
        expect(viewModel.expiryDate, newDate);
      });
    });

    group('updateDescription', () {
      test('debería actualizar descripción', () {
        viewModel.updateDescription('Nueva descripción');
        expect(viewModel.description, 'Nueva descripción');
      });
    });

    group('incrementQuantity', () {
      test('debería incrementar cantidad', () {
        viewModel.incrementQuantity();
        expect(viewModel.quantity, 6);
      });
    });

    group('decrementQuantity', () {
      test('debería decrementar cantidad', () {
        viewModel.decrementQuantity();
        expect(viewModel.quantity, 4);
      });

      test('no debería decrementar por debajo de 1', () {
        viewModel.updateQuantity(1);
        viewModel.decrementQuantity();
        expect(viewModel.quantity, 1);
      });
    });

    group('updateProduct', () {
      test('debería retornar false cuando formulario es inválido', () async {
        viewModel.updateName('');

        final result = await viewModel.updateProduct();

        expect(result, false);
        expect(viewModel.errorMessage, 'El nombre es obligatorio');
      });

      test('debería retornar false cuando no hay cambios', () async {
        final result = await viewModel.updateProduct();

        expect(result, false);
        expect(viewModel.errorMessage, 'No hay cambios para guardar');
      });

      test('debería actualizar producto exitosamente', () async {
        viewModel.updateName('Nuevo nombre');
        when(
          () => mockHiveService.updateProduct(any()),
        ).thenAnswer((_) async {});

        final result = await viewModel.updateProduct();

        expect(result, true);
        verify(() => mockHiveService.updateProduct(any())).called(1);
      });

      test('debería retornar false en caso de error', () async {
        viewModel.updateName('Nuevo nombre');
        when(
          () => mockHiveService.updateProduct(any()),
        ).thenThrow(Exception('Error de BD'));

        final result = await viewModel.updateProduct();

        expect(result, false);
        expect(viewModel.errorMessage, contains('Error al actualizar'));
      });
    });

    group('deleteProduct', () {
      test('debería eliminar producto exitosamente', () async {
        when(
          () => mockHiveService.deleteProduct('prod-1'),
        ).thenAnswer((_) async {});

        final result = await viewModel.deleteProduct();

        expect(result, true);
        verify(() => mockHiveService.deleteProduct('prod-1')).called(1);
      });

      test('debería retornar false en caso de error', () async {
        when(
          () => mockHiveService.deleteProduct('prod-1'),
        ).thenThrow(Exception('Error'));

        final result = await viewModel.deleteProduct();

        expect(result, false);
        expect(viewModel.errorMessage, 'Error al eliminar');
      });
    });

    group('markAsUsed', () {
      test('debería decrementar cantidad de producto sólido', () async {
        final solidProduct = Product(
          id: 'prod-1',
          name: 'Test',
          quantity: 5,
          liquidQuantity: 0,
          type: ProductType.solid,
          expiryDate: DateTime.now().add(const Duration(days: 7)),
          isExpired: false,
          createdAt: DateTime.now(),
        );

        viewModel = UpdateProductViewModel(mockHiveService, solidProduct);
        when(
          () => mockHiveService.updateProduct(any()),
        ).thenAnswer((_) async {});

        await viewModel.markAsUsed();

        verify(() => mockHiveService.updateProduct(any())).called(1);
        expect(viewModel.quantity, 4);
      });

      test('debería eliminar producto cuando cantidad llega a 0', () async {
        final solidProduct = Product(
          id: 'prod-1',
          name: 'Test',
          quantity: 1,
          liquidQuantity: 0,
          type: ProductType.solid,
          expiryDate: DateTime.now().add(const Duration(days: 7)),
          isExpired: false,
          createdAt: DateTime.now(),
        );

        viewModel = UpdateProductViewModel(mockHiveService, solidProduct);
        when(
          () => mockHiveService.productFinished(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockHiveService.deleteProduct('prod-1'),
        ).thenAnswer((_) async {});

        await viewModel.markAsUsed();

        verify(() => mockHiveService.productFinished(any())).called(1);
        verify(() => mockHiveService.deleteProduct('prod-1')).called(1);
      });
    });
  });
}
