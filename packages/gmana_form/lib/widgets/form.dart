import 'package:flutter/material.dart';

import '../controllers/form_controller.dart';

/// Thin wrapper around Flutter's [Form] that uses a [GFormController].
///
/// Provides the controller to descendants via [controllerOf] / [maybeControllerOf]
/// so named gmana_form fields can resolve their text controllers automatically.
class GForm extends StatelessWidget {
  /// Controller that owns the form key and named text controllers.
  final GFormController controller;

  /// The child widget — usually a column of gmana_form fields.
  final Widget child;

  /// See [Form.autovalidateMode].
  final AutovalidateMode? autovalidateMode;

  /// See [Form.canPop].
  final bool canPop;

  /// See [Form.onPopInvokedWithResult].
  final PopInvokedWithResultCallback<Object?>? onPopInvokedWithResult;

  /// See [Form.onChanged].
  final void Function()? onChanged;

  /// Creates a [GForm] bound to [controller].
  const GForm({
    super.key,
    required this.controller,
    required this.child,
    this.autovalidateMode,
    this.canPop = true,
    this.onPopInvokedWithResult,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _GFormScope(
      controller: controller,
      child: Form(
        key: controller.key,
        autovalidateMode: autovalidateMode,
        canPop: canPop,
        onPopInvokedWithResult: onPopInvokedWithResult,
        onChanged: onChanged,
        child: child,
      ),
    );
  }

  /// Looks up the nearest enclosing [GFormController], or `null` if none.
  static GFormController? maybeControllerOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_GFormScope>()
        ?.controller;
  }

  /// Like [maybeControllerOf] but throws a [FlutterError] when no [GForm]
  /// is found above [context]. Use this from widgets that require a form.
  static GFormController controllerOf(BuildContext context) {
    final controller = maybeControllerOf(context);
    if (controller == null) {
      throw FlutterError(
        'No GForm found in context. '
        'Wrap named gmana_form fields with GForm or pass a controller directly.',
      );
    }
    return controller;
  }
}

class _GFormScope extends InheritedWidget {
  final GFormController controller;

  const _GFormScope({required this.controller, required super.child});

  @override
  bool updateShouldNotify(_GFormScope oldWidget) {
    return controller != oldWidget.controller;
  }
}
