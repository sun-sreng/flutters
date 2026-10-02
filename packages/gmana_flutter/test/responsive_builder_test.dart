import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter/gmana_flutter.dart';

void main() {
  testWidgets('GResponsiveBuilder renders mobile layout by default', (
    tester,
  ) async {
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

  testWidgets(
    'GResponsiveBuilder renders desktop layout at the desktop breakpoint',
    (tester) async {
      tester.view.physicalSize = const Size(Breakpoints.desktop, 800);
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
    },
  );

  testWidgets('GResponsiveBuilder switches at the shared breakpoints', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    Future<void> pumpAt(double width) async {
      tester.view.physicalSize = Size(width, 800);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GResponsiveBuilder(
              mobile: (context) => const Text('Mobile Layout'),
              tablet: (context) => const Text('Tablet Layout'),
              desktop: (context) => const Text('Desktop Layout'),
            ),
          ),
        ),
      );
    }

    await pumpAt(Breakpoints.tablet - 1);
    expect(find.text('Mobile Layout'), findsOneWidget);

    await pumpAt(Breakpoints.tablet);
    expect(find.text('Tablet Layout'), findsOneWidget);

    await pumpAt(Breakpoints.desktop - 1);
    expect(find.text('Tablet Layout'), findsOneWidget);

    await pumpAt(Breakpoints.desktop);
    expect(find.text('Desktop Layout'), findsOneWidget);
  });

  testWidgets('GResponsiveBuilder honours explicit breakpoints', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(700, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GResponsiveBuilder(
            mobileBreakpoint: 600,
            tabletBreakpoint: 1024,
            mobile: (context) => const Text('Mobile Layout'),
            tablet: (context) => const Text('Tablet Layout'),
          ),
        ),
      ),
    );

    expect(find.text('Tablet Layout'), findsOneWidget);
  });
}
