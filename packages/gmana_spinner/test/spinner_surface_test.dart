import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_spinner/gmana_spinner.dart';

void main() {
  group('spinner widgets', () {
    testWidgets('canonical spinner widgets render', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                GCircularSpinner(),
                GLinearSpinner(),
                GDotSpinner(color: Colors.red),
                GDotSpinner(),
                GWaveDotSpinner(size: 24),
                GBarWaveSpinner(color: Colors.purple),
                SizedBox(
                  width: 48,
                  height: 48,
                  child: GWaveSpinner(color: Colors.green),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(GCircularSpinner), findsOneWidget);
      expect(find.byType(GLinearSpinner), findsOneWidget);
      expect(find.byType(GDotSpinner), findsNWidgets(2));
      expect(find.byType(GWaveDotSpinner), findsOneWidget);
      expect(find.byType(GBarWaveSpinner), findsOneWidget);
      expect(find.byType(GWaveSpinner), findsOneWidget);
    });

    test('animation helpers remain available', () {
      final config = DotAnimationConfig.forIndex(
        index: 0,
        dotCount: 5,
        baseSize: 24,
        isEven: false,
      );

      expect(config.maxHeight, closeTo(9.6, 0.000001));
      expect(DelayedAnimationTween(delay: 0), isA<Tween<double>>());
    });
  });
}
