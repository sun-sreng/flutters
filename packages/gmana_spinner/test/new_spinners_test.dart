import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_spinner/gmana_spinner.dart';

void main() {
  group('new spinner widgets', () {
    testWidgets('GDualRingSpinner renders and animates', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GDualRingSpinner(
              color: Colors.blue,
              secondaryColor: Colors.orange,
              size: 48,
              strokeWidth: 4,
            ),
          ),
        ),
      );

      expect(find.byType(GDualRingSpinner), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(GDualRingSpinner), findsOneWidget);
    });

    testWidgets('GChasingDotsSpinner renders and animates', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GChasingDotsSpinner(
              color: Colors.red,
              size: 50,
            ),
          ),
        ),
      );

      expect(find.byType(GChasingDotsSpinner), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(GChasingDotsSpinner), findsOneWidget);
    });

    testWidgets('GFadingCubeSpinner renders and animates', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GFadingCubeSpinner(
              color: Colors.green,
              size: 40,
            ),
          ),
        ),
      );

      expect(find.byType(GFadingCubeSpinner), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(GFadingCubeSpinner), findsOneWidget);
    });

    testWidgets('GRippleSpinner renders and animates', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GRippleSpinner(
              color: Colors.purple,
              size: 60,
              rippleCount: 3,
            ),
          ),
        ),
      );

      expect(find.byType(GRippleSpinner), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byType(GRippleSpinner), findsOneWidget);
    });

    testWidgets('GOrbitSpinner renders and animates', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GOrbitSpinner(
              color: Colors.teal,
              size: 44,
              satelliteCount: 4,
            ),
          ),
        ),
      );

      expect(find.byType(GOrbitSpinner), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(GOrbitSpinner), findsOneWidget);
    });
  });
}
