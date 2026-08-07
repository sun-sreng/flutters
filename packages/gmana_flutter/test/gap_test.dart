import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter/gmana_flutter.dart';

void main() {
  testWidgets('GGap renders SizedBox with specified dimensions', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: [
            Text('Top'),
            GGap.vertical(16.0),
            Text('Bottom'),
          ],
        ),
      ),
    );

    final box = tester.widget<SizedBox>(find.byType(SizedBox).first);
    expect(box.height, equals(16.0));
  });
}
