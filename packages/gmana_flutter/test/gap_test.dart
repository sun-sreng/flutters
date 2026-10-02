import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter/gmana_flutter.dart';

void main() {
  testWidgets('GGap.vertical renders SizedBox with height only', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: [Text('Top'), GGap.vertical(16.0), Text('Bottom')],
        ),
      ),
    );

    final box = tester.widget<SizedBox>(find.byType(SizedBox).first);
    expect(box.height, equals(16.0));
    expect(box.width, isNull);
  });

  testWidgets('GGap.horizontal renders SizedBox with width only', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          children: [Text('Left'), GGap.horizontal(12.0), Text('Right')],
        ),
      ),
    );

    final box = tester.widget<SizedBox>(find.byType(SizedBox).first);
    expect(box.width, equals(12.0));
    expect(box.height, isNull);
  });

  testWidgets('GGap square renders SizedBox with both width and height', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(textDirection: TextDirection.ltr, child: GGap(20.0)),
    );

    final box = tester.widget<SizedBox>(find.byType(SizedBox).first);
    expect(box.width, equals(20.0));
    expect(box.height, equals(20.0));
  });
}
