import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stocky/models/product.dart';
import 'package:stocky/services/hive_service.dart';
import 'package:stocky/viewmodels/add_product_viewmodel.dart';

class MockHiveService extends Mock implements HiveService {}

void main() {
  late MockHiveService mockHiveService;
  late AddProductViewModel viewModel;

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
    viewModel = AddProductViewModel(mockHiveService);
  });

  group('AddProductViewModel', () {
    test('estado inicial debería tener valores por defecto', () {
      expect(viewModel.name, '');
      expect(viewModel.quantity, 1);
      expect(viewModel.description, '');
      expect(viewModel.selectedType, ProductType.solid);
      expect(viewModel.isLoading, false);
      expect(viewModel.errorMessage, null);
    });

    test('isFormValid debería retornar false cuando nombre está vacío', () {
      expect(viewModel.isFormValid, false);
    });

    test('isFormValid debería retornar false cuando cantidad es 0', () {
      viewModel.updateName('Test');
      viewModel.updateQuantity(0);
      expect(viewModel.isFormValid, false);
    });

    test(
      'isFormValid debería retornar true cuando nombre y cantidad son válidos',
      () {
        viewModel.updateName('Manzana');
        viewModel.updateQuantity(5);
        expect(viewModel.isFormValid, true);
      },
    );

    group('updateName', () {
      test('debería actualizar nombre', () {
        viewModel.updateName('Nuevo nombre');
        expect(viewModel.name, 'Nuevo nombre');
      });
    });

    group('updateQuantity', () {
      test('debería actualizar cantidad', () {
        viewModel.updateQuantity(10);
        expect(viewModel.quantity, 10);
      });
    });

    group('updateDescription', () {
      test('debería actualizar descripción', () {
        viewModel.updateDescription('Alguna descripción');
        expect(viewModel.description, 'Alguna descripción');
      });
    });

    group('updateExpiryDate', () {
      test('debería actualizar fecha de vencimiento', () {
        final newDate = DateTime.now().add(const Duration(days: 30));
        viewModel.updateExpiryDate(newDate);
        expect(viewModel.expiryDate, newDate);
      });
    });

    group('setProductType', () {
      test('debería establecer tipo de producto a sólido', () {
        viewModel.setProductType(ProductType.solid);
        expect(viewModel.selectedType, ProductType.solid);
        expect(viewModel.isLiquid, false);
      });

      test('debería establecer tipo de producto a líquido', () {
        viewModel.setProductType(ProductType.liquid);
        expect(viewModel.selectedType, ProductType.liquid);
        expect(viewModel.isLiquid, true);
      });
    });

    group('updateLiquidQuantity', () {
      test('debería actualizar cantidad líquida', () {
        viewModel.setProductType(ProductType.liquid);
        viewModel.updateLiquidQuantity(2.5);
        expect(viewModel.liquidQuantity, 2.5);
      });
    });

    group('incrementQuantity', () {
      test('debería incrementar cantidad en 1', () {
        viewModel.updateQuantity(5);
        viewModel.incrementQuantity();
        expect(viewModel.quantity, 6);
      });
    });

    group('decrementQuantity', () {
      test('debería decrementar cantidad en 1', () {
        viewModel.updateQuantity(5);
        viewModel.decrementQuantity();
        expect(viewModel.quantity, 4);
      });

      test('no debería decrementar por debajo de 1', () {
        viewModel.updateQuantity(1);
        viewModel.decrementQuantity();
        expect(viewModel.quantity, 1);
      });
    });

    group('saveProduct', () {
      test('debería retornar false cuando formulario es inválido', () async {
        viewModel.updateName('');

        final result = await viewModel.saveProduct();

        expect(result, false);
        expect(viewModel.errorMessage, 'Nombre y cantidad son obligatorios');
      });

      test('debería guardar producto exitosamente', () async {
        viewModel.updateName('Manzana');
        viewModel.updateQuantity(5);

        when(() => mockHiveService.addProduct(any())).thenAnswer((_) async {});

        final result = await viewModel.saveProduct();

        expect(result, true);
        expect(viewModel.isLoading, false);
        verify(() => mockHiveService.addProduct(any())).called(1);
      });

      test('debería retornar false en caso de error', () async {
        viewModel.updateName('Test');
        viewModel.updateQuantity(1);

        when(
          () => mockHiveService.addProduct(any()),
        ).thenThrow(Exception('Error de BD'));

        final result = await viewModel.saveProduct();

        expect(result, false);
        expect(viewModel.errorMessage, contains('Error al guardar'));
        expect(viewModel.isLoading, false);
      });
    });

    group('resetForm', () {
      test('debería resetear todos los campos a valores por defecto', () {
        viewModel.updateName('Producto de prueba');
        viewModel.updateQuantity(10);
        viewModel.updateDescription('Descripción');

        viewModel.resetForm();

        expect(viewModel.name, '');
        expect(viewModel.quantity, 1);
        expect(viewModel.description, '');
        expect(viewModel.errorMessage, null);
      });

      test(
        'debería establecer fecha de vencimiento por defecto a 7 días desde ahora',
        () {
          viewModel.resetForm();

          final expectedDate = DateTime.now().add(const Duration(days: 7));
          final difference = viewModel.expiryDate
              .difference(expectedDate)
              .inDays
              .abs();

          expect(difference <= 1, true);
        },
      );
    });
  });
}
