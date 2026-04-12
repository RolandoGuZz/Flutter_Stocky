import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stocky/widgets/quantity_selector.dart';

void main() {
  group('QuantitySelector', () {
    testWidgets('debería mostrar el valor de cantidad', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuantitySelector(
              quantity: 5,
              onIncrement: () {},
              onDecrement: () {},
            ),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('debería tener botón de incremento', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuantitySelector(
              quantity: 1,
              onIncrement: () {},
              onDecrement: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('debería tener botón de decremento', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuantitySelector(
              quantity: 1,
              onIncrement: () {},
              onDecrement: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.remove), findsOneWidget);
    });

    testWidgets(
      'debería llamar onIncrement cuando se toca el botón de agregar',
      (tester) async {
        bool incrementCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: QuantitySelector(
                quantity: 1,
                onIncrement: () {
                  incrementCalled = true;
                },
                onDecrement: () {},
              ),
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.add));
        await tester.pump();

        expect(incrementCalled, true);
      },
    );

    testWidgets(
      'debería llamar onDecrement cuando se toca el botón de remover',
      (tester) async {
        bool decrementCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: QuantitySelector(
                quantity: 2,
                onIncrement: () {},
                onDecrement: () {
                  decrementCalled = true;
                },
              ),
            ),
          ),
        );

        await tester.tap(find.byIcon(Icons.remove));
        await tester.pump();

        expect(decrementCalled, true);
      },
    );

    testWidgets('debería tener decoración de contenedor', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuantitySelector(
              quantity: 1,
              onIncrement: () {},
              onDecrement: () {},
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('debería mostrar cantidad cero', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuantitySelector(
              quantity: 0,
              onIncrement: () {},
              onDecrement: () {},
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('debería mostrar cantidad grande', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuantitySelector(
              quantity: 100,
              onIncrement: () {},
              onDecrement: () {},
            ),
          ),
        ),
      );

      expect(find.text('100'), findsOneWidget);
    });
  });
}
