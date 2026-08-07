import 'package:flutter/material.dart';

import '../widgets/form.dart';

/// `yyyy-MM-dd` — locale-independent, and the default so this package does
/// not have to depend on `intl`.
String formatIsoDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');

  return '${date.year.toString().padLeft(4, '0')}-$month-$day';
}

/// Date picker rendered as a read-only form field.
///
/// Tapping opens [showDatePicker]. The value is a real [DateTime], so
/// validation and the typed value API work on dates rather than on strings.
///
/// ```dart
/// GDateField(
///   name: 'birthday',
///   label: 'Date of birth',
///   firstDate: DateTime(1900),
///   lastDate: DateTime.now(),
///   validator: (value) => value == null ? 'Pick a date' : null,
/// );
/// ```
class GDateField extends FormField<DateTime> {
  /// Creates a date field.
  ///
  /// Pass [format] to render the value differently — the default is
  /// [formatIsoDate]. Set [clearable] to show a button that resets the value
  /// to `null`.
  GDateField({
    super.key,
    String? name,
    super.initialValue,
    required DateTime firstDate,
    required DateTime lastDate,
    String label = 'Date',
    String? hint,
    IconData? prefixIcon = Icons.calendar_today,
    String Function(DateTime date)? format,
    ValueChanged<DateTime?>? onChanged,
    super.validator,
    super.autovalidateMode,
    super.onSaved,
    super.enabled,
    bool clearable = false,
    InputDecoration? decoration,
    String? helpText,
  }) : assert(
         !firstDate.isAfter(lastDate),
         'firstDate must not be after lastDate.',
       ),
       super(
         builder: (field) {
           final formatter = format ?? formatIsoDate;
           final controller =
               name == null ? null : GForm.maybeControllerOf(field.context);
           if (name != null) {
             controller?.field<DateTime>(name, initialValue: initialValue);
           }

           void commit(DateTime? value) {
             field.didChange(value);
             if (name != null) controller?.setValue<DateTime>(name, value);
             onChanged?.call(value);
           }

           Future<void> pick() async {
             final current = field.value;
             // showDatePicker asserts that initialDate sits inside the range,
             // so a stale or out-of-range value has to be clamped first.
             final seed = current ?? DateTime.now();
             final initial =
                 seed.isBefore(firstDate)
                     ? firstDate
                     : (seed.isAfter(lastDate) ? lastDate : seed);

             final picked = await showDatePicker(
               context: field.context,
               initialDate: initial,
               firstDate: firstDate,
               lastDate: lastDate,
               helpText: helpText,
             );

             if (picked != null && field.mounted) commit(picked);
           }

           final value = field.value;
           final showClear = clearable && value != null && enabled;

           final effectiveDecoration = (decoration ?? const InputDecoration())
               .copyWith(
                 labelText: decoration?.labelText ?? label,
                 hintText: decoration?.hintText ?? hint,
                 prefixIcon:
                     decoration?.prefixIcon ??
                     (prefixIcon == null ? null : Icon(prefixIcon)),
                 suffixIcon:
                     decoration?.suffixIcon ??
                     (showClear
                         ? IconButton(
                           icon: const Icon(Icons.clear),
                           tooltip: 'Clear date',
                           onPressed: () => commit(null),
                         )
                         : null),
                 errorText: field.errorText,
                 enabled: enabled,
               );

           return InkWell(
             onTap: enabled ? pick : null,
             child: InputDecorator(
               decoration: effectiveDecoration,
               isEmpty: value == null,
               child: value == null ? null : Text(formatter(value)),
             ),
           );
         },
       );
}
