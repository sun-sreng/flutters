import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter/gmana_flutter.dart';

void main() {
  group('SizedBoxHeight and SizedBoxWidth Widgets', () {
    testWidgets('SizedBoxHeight builds with specified height', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Column(
            children: [
              SizedBoxHeight(spacing: 24.0),
            ],
          ),
        ),
      );

      final box = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(box.height, equals(24.0));
    });

    testWidgets('SizedBoxWidth builds with specified width', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Row(
            children: [
              SizedBoxWidth(spacing: 16.0),
            ],
          ),
        ),
      );

      final box = tester.widget<SizedBox>(find.byType(SizedBox));
      expect(box.width, equals(16.0));
    });
  });
}
