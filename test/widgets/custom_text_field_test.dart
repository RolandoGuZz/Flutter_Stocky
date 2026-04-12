import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stocky/widgets/custom_text_field.dart';

void main() {
  group('CustomTextField', () {
    testWidgets('debería renderizar con texto de pista', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(hint: 'Ingresa nombre', onChanged: (_) {}),
          ),
        ),
      );

      expect(find.text('Ingresa nombre'), findsOneWidget);
    });

    testWidgets('debería renderizar con icono de prefijo', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              hint: 'Buscar',
              onChanged: (_) {},
              prefixIcon: Icons.search,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('debería llamar onChanged cuando se ingresa texto', (
      tester,
    ) async {
      String? capturedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              hint: 'Ingresa nombre',
              onChanged: (value) {
                capturedValue = value;
              },
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextFormField), 'Valor de prueba');
      await tester.pump();

      expect(capturedValue, 'Valor de prueba');
    });

    testWidgets('debería mostrar valor inicial cuando se proporciona', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              hint: 'Nombre',
              onChanged: (_) {},
              initialValue: 'Texto inicial',
            ),
          ),
        ),
      );

      expect(find.text('Texto inicial'), findsOneWidget);
    });

    testWidgets('debería soportar entrada multilínea', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              hint: 'Descripción',
              onChanged: (_) {},
              maxLines: 3,
            ),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Descripción'), findsOneWidget);
    });
  });
}
