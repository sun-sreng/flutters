import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter/gmana_flutter.dart';

void main() {
  testWidgets('GResponsiveBuilder renders mobile layout by default', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(400, 800)),
          child: Scaffold(
            body: GResponsiveBuilder(
              mobile: (context) => const Text('Mobile Layout'),
              desktop: (context) => const Text('Desktop Layout'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Mobile Layout'), findsOneWidget);
    expect(find.text('Desktop Layout'), findsNothing);
  });

  testWidgets('GResponsiveBuilder renders desktop layout when screen width >= 1024', (tester) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GResponsiveBuilder(
            mobile: (context) => const Text('Mobile Layout'),
            desktop: (context) => const Text('Desktop Layout'),
          ),
        ),
      ),
    );

    expect(find.text('Desktop Layout'), findsOneWidget);
    expect(find.text('Mobile Layout'), findsNothing);
  });

}
