import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter/gmana_flutter.dart';

void main() {
  group('GStarRatingBar Widget', () {
    testWidgets('renders full, half, and empty star icons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: GStarRatingBar(ratingValue: 3.5, maxStars: 5)),
        ),
      );

      expect(find.byIcon(Icons.star), findsNWidgets(3));
      expect(find.byIcon(Icons.star_half), findsNWidgets(1));
      expect(find.byIcon(Icons.star_border), findsNWidgets(1));
    });
  });
}
