import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter_extensions/gmana_flutter_extensions.dart';


void main() {
  testWidgets('AnimationControllerX toggle and restart', (tester) async {
    final controller = AnimationController(
      vsync: const TestVSync(),
      duration: const Duration(milliseconds: 200),
    );

    expect(controller.status, equals(AnimationStatus.dismissed));

    unawaited(controller.toggle());
    expect(controller.status, equals(AnimationStatus.forward));

    controller.stop();
    unawaited(controller.restart());
    expect(controller.status, equals(AnimationStatus.forward));


    controller.dispose();
  });
}
