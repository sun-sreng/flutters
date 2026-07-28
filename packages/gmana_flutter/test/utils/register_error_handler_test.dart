import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter/gmana_flutter.dart';

void main() {
  group('registerErrorHandlers', () {
    test('installs error handlers without throwing', () {
      var flutterErrorHandled = false;

      registerErrorHandlers(
        presentFlutterErrors: false,
        onFlutterError: (details) {
          flutterErrorHandled = true;
        },
      );

      FlutterError.reportError(
        FlutterErrorDetails(
          exception: Exception('Test exception'),
          library: 'test',
        ),
      );

      expect(flutterErrorHandled, isTrue);
    });
  });
}
