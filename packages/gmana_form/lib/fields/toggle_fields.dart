import 'package:flutter/material.dart';

import '../widgets/form.dart';

/// Renders a [FormField]'s error message in the theme's error style.
///
/// [FormField]s that are not built on `InputDecorator` have to paint their own
/// error text; without this a failed validation would be silent.
Widget buildFieldErrorText(FormFieldState<Object?> field) {
  final theme = Theme.of(field.context);

  return Padding(
    padding: const EdgeInsetsDirectional.only(start: 16, top: 4),
    child: Text(
      field.errorText ?? '',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.error,
      ),
    ),
  );
}

/// Checkbox tile that participates in form validation.
///
/// The usual reason to need validation on a checkbox is a "must accept the
/// terms" gate, which a bare [Checkbox] cannot express:
///
/// ```dart
/// GCheckboxField(
///   name: 'terms',
///   title: const Text('I accept the terms'),
///   validator: (value) => value == true ? null : 'You must accept the terms',
/// );
/// ```
class GCheckboxField extends FormField<bool> {
  /// Creates a validating checkbox tile.
  ///
  /// When [name] is set and a [GForm] is above this widget, the value is
  /// mirrored into the controller's typed values.
  GCheckboxField({
    super.key,
    String? name,
    super.initialValue = false,
    required Widget title,
    Widget? subtitle,
    Widget? secondary,
    ValueChanged<bool>? onChanged,
    super.validator,
    super.autovalidateMode,
    super.onSaved,
    super.enabled,
    ListTileControlAffinity controlAffinity = ListTileControlAffinity.leading,
    EdgeInsetsGeometry? contentPadding,
    Color? activeColor,
  }) : super(
         builder: (field) {
           final controller =
               name == null ? null : GForm.maybeControllerOf(field.context);
           if (name != null) {
             controller?.field<bool>(name, initialValue: initialValue);
           }

           // Signature dictated by CheckboxListTile.onChanged.
           // ignore: avoid_positional_boolean_parameters
           void handleChanged(bool? value) {
             final next = value ?? false;
             field.didChange(next);
             if (name != null) controller?.setValue<bool>(name, next);
             onChanged?.call(next);
           }

           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             mainAxisSize: MainAxisSize.min,
             children: [
               CheckboxListTile(
                 value: field.value ?? false,
                 onChanged: enabled ? handleChanged : null,
                 title: title,
                 subtitle: subtitle,
                 secondary: secondary,
                 controlAffinity: controlAffinity,
                 contentPadding: contentPadding,
                 activeColor: activeColor,
               ),
               if (field.hasError) buildFieldErrorText(field),
             ],
           );
         },
       );
}

/// Switch tile that participates in form validation.
///
/// Behaves exactly like [GCheckboxField]; pick whichever control matches the
/// platform convention you are following.
class GSwitchField extends FormField<bool> {
  /// Creates a validating switch tile.
  GSwitchField({
    super.key,
    String? name,
    super.initialValue = false,
    required Widget title,
    Widget? subtitle,
    Widget? secondary,
    ValueChanged<bool>? onChanged,
    super.validator,
    super.autovalidateMode,
    super.onSaved,
    super.enabled,
    EdgeInsetsGeometry? contentPadding,
    Color? activeColor,
  }) : super(
         builder: (field) {
           final controller =
               name == null ? null : GForm.maybeControllerOf(field.context);
           if (name != null) {
             controller?.field<bool>(name, initialValue: initialValue);
           }

           // Signature dictated by SwitchListTile.onChanged.
           // ignore: avoid_positional_boolean_parameters
           void handleChanged(bool value) {
             field.didChange(value);
             if (name != null) controller?.setValue<bool>(name, value);
             onChanged?.call(value);
           }

           return Column(
             crossAxisAlignment: CrossAxisAlignment.start,
             mainAxisSize: MainAxisSize.min,
             children: [
               SwitchListTile(
                 value: field.value ?? false,
                 onChanged: enabled ? handleChanged : null,
                 title: title,
                 subtitle: subtitle,
                 secondary: secondary,
                 contentPadding: contentPadding,
                 activeThumbColor: activeColor,
               ),
               if (field.hasError) buildFieldErrorText(field),
             ],
           );
         },
       );
}
