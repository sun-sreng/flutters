import 'package:flutter/material.dart';

import '../widgets/form.dart';

/// Typed dropdown that participates in form validation and, when named,
/// reports into a `GFormController`'s typed values.
///
/// ```dart
/// GDropdownField<String>(
///   name: 'country',
///   label: 'Country',
///   items: const [
///     DropdownMenuItem(value: 'kh', child: Text('Cambodia')),
///     DropdownMenuItem(value: 'us', child: Text('United States')),
///   ],
///   validator: (value) => value == null ? 'Pick a country' : null,
/// );
/// ```
class GDropdownField<T> extends FormField<T> {
  /// Creates a validating dropdown.
  GDropdownField({
    super.key,
    String? name,
    super.initialValue,
    required List<DropdownMenuItem<T>> items,
    String? label,
    String? hint,
    IconData? prefixIcon,
    ValueChanged<T?>? onChanged,
    super.validator,
    super.autovalidateMode,
    super.onSaved,
    super.enabled,
    bool isExpanded = true,
    InputDecoration? decoration,
    Widget? icon,
  }) : super(
         builder: (field) {
           final controller =
               name == null ? null : GForm.maybeControllerOf(field.context);
           if (name != null) {
             controller?.field<T>(name, initialValue: initialValue);
           }

           void handleChanged(T? value) {
             field.didChange(value);
             if (name != null) controller?.setValue<T>(name, value);
             onChanged?.call(value);
           }

           final effectiveDecoration = (decoration ?? const InputDecoration())
               .copyWith(
                 labelText: decoration?.labelText ?? label,
                 hintText: decoration?.hintText ?? hint,
                 prefixIcon:
                     decoration?.prefixIcon ??
                     (prefixIcon == null ? null : Icon(prefixIcon)),
                 errorText: field.errorText,
                 enabled: enabled,
               );

           return InputDecorator(
             decoration: effectiveDecoration,
             isEmpty: field.value == null,
             child: DropdownButtonHideUnderline(
               child: DropdownButton<T>(
                 value: field.value,
                 items: items,
                 onChanged: enabled ? handleChanged : null,
                 isExpanded: isExpanded,
                 icon: icon,
                 hint: hint == null ? null : Text(hint),
               ),
             ),
           );
         },
       );

  /// Builds a dropdown from plain values, rendering each with [labelBuilder].
  ///
  /// Saves writing `DropdownMenuItem` boilerplate for the common case of a
  /// list of enum or model values.
  ///
  /// ```dart
  /// GDropdownField.fromValues<Role>(
  ///   name: 'role',
  ///   values: Role.values,
  ///   labelBuilder: (role) => role.name,
  /// );
  /// ```
  static GDropdownField<T> fromValues<T>({
    Key? key,
    String? name,
    T? initialValue,
    required Iterable<T> values,
    required String Function(T value) labelBuilder,
    String? label,
    String? hint,
    IconData? prefixIcon,
    ValueChanged<T?>? onChanged,
    FormFieldValidator<T>? validator,
    AutovalidateMode? autovalidateMode,
    void Function(T?)? onSaved,
    bool enabled = true,
    bool isExpanded = true,
    InputDecoration? decoration,
    Widget? icon,
  }) {
    return GDropdownField<T>(
      key: key,
      name: name,
      initialValue: initialValue,
      items: [
        for (final value in values)
          DropdownMenuItem<T>(value: value, child: Text(labelBuilder(value))),
      ],
      label: label,
      hint: hint,
      prefixIcon: prefixIcon,
      onChanged: onChanged,
      validator: validator,
      autovalidateMode: autovalidateMode,
      onSaved: onSaved,
      enabled: enabled,
      isExpanded: isExpanded,
      decoration: decoration,
      icon: icon,
    );
  }
}
