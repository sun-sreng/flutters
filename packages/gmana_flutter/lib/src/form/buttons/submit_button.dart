import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../widgets/button.dart';
import '../controllers/form_controller.dart';
import '../widgets/form.dart';

/// Submit button wired to a [GFormController].
///
/// Renders a [GButton] that shows its loading state while the controller is
/// submitting. For a button with a manually driven loading state, use
/// [GButton] with `isLoading` directly.
class GFormSubmitButton extends StatelessWidget {
  /// The form controller to submit. Defaults to the nearest [GForm]'s.
  final GFormController? controller;

  /// Called with the form's named values after validation succeeds.
  final FutureOr<void> Function(Map<String, String> values) onSubmit;

  /// Whether to reset the form after [onSubmit] completes.
  final bool resetOnSuccess;

  /// The text label displayed on the button.
  final String label;

  /// Visual variant passed to [GButton].
  final GButtonVariant variant;

  /// Size preset passed to [GButton].
  final GButtonSize size;

  /// Optional leading icon passed to [GButton].
  final Widget? icon;

  /// Whether the button expands to fill the available width.
  final bool fullWidth;

  /// Creates a [GFormSubmitButton].
  const GFormSubmitButton({
    super.key,
    this.controller,
    required this.onSubmit,
    required this.label,
    this.resetOnSuccess = false,
    this.variant = GButtonVariant.primary,
    this.size = GButtonSize.medium,
    this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveController = controller ?? GForm.controllerOf(context);

    return ListenableBuilder(
      listenable: effectiveController,
      builder: (context, _) {
        return GButton(
          label: label,
          isLoading: effectiveController.submitting,
          onPressed:
              () => effectiveController.submit(
                onSubmit,
                resetOnSuccess: resetOnSuccess,
              ),
          variant: variant,
          size: size,
          icon: icon,
          fullWidth: fullWidth,
        );
      },
    );
  }
}
