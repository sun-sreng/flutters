import 'dart:ui';

import 'package:flutter/material.dart';

/// Installs global error handlers for Flutter framework errors and async
/// platform errors.
///
/// Pass [onFlutterError] / [onPlatformError] to forward errors to your crash
/// reporter. Set [presentFlutterErrors] to `false` to suppress the red error
/// screen. Optionally override the error widget builder with [errorWidgetBuilder].
void registerErrorHandlers({
  void Function(FlutterErrorDetails details)? onFlutterError,
  ErrorWidgetBuilder? errorWidgetBuilder,
  bool presentFlutterErrors = true,
  bool handlePlatformErrors = true,
  bool Function(Object error, StackTrace stack)? onPlatformError,
}) {
  FlutterError.onError = (FlutterErrorDetails details) {
    if (presentFlutterErrors) {
      FlutterError.presentError(details);
    }
    if (onFlutterError != null) {
      onFlutterError(details);
    } else {
      debugPrint(details.toString());
    }
  };

  if (handlePlatformErrors) {
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      if (onPlatformError != null) {
        return onPlatformError(error, stack);
      }
      debugPrint(error.toString());
      return true;
    };
  }

  if (errorWidgetBuilder != null) {
    ErrorWidget.builder = errorWidgetBuilder;
  }
}
