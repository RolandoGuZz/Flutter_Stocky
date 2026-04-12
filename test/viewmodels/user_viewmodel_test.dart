import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stocky/services/hive_service.dart';
import 'package:stocky/viewmodels/user_viewmodel.dart';

class MockHiveService extends Mock implements HiveService {}

void main() {
  late MockHiveService mockHiveService;

  setUp(() {
    mockHiveService = MockHiveService();
  });

  group('UserViewModel', () {
    test('debería cargar datos de usuario al inicializar', () {
      when(() => mockHiveService.getUserName()).thenReturn('Juan');
      when(() => mockHiveService.isFirstLaunch()).thenReturn(false);

      final viewModel = UserViewModel(hiveService: mockHiveService);

      expect(viewModel.userName, 'Juan');
      expect(viewModel.isFirstLaunch, false);
    });

    test('debería retornar null para userName cuando no está configurado', () {
      when(() => mockHiveService.getUserName()).thenReturn(null);
      when(() => mockHiveService.isFirstLaunch()).thenReturn(true);

      final viewModel = UserViewModel(hiveService: mockHiveService);

      expect(viewModel.userName, null);
      expect(viewModel.isFirstLaunch, true);
    });

    test('saveUserName debería guardar nombre y actualizar estado', () async {
      when(() => mockHiveService.getUserName()).thenReturn(null);
      when(() => mockHiveService.isFirstLaunch()).thenReturn(true);
      when(() => mockHiveService.saveUserName('Juan')).thenAnswer((_) async {});

      final viewModel = UserViewModel(hiveService: mockHiveService);
      await viewModel.saveUserName('Juan');

      verify(() => mockHiveService.saveUserName('Juan')).called(1);
      expect(viewModel.userName, 'Juan');
      expect(viewModel.isFirstLaunch, false);
    });
  });
}
