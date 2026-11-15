// Passthrough widget mirroring TextFormField props.
// ignore_for_file: public_member_api_docs

import 'package:flutter/services.dart';
import 'package:gmana/validation.dart';
import 'package:material_ui/material_ui.dart';

import '../controllers/form_controller.dart';
import '../models/field_config.dart';
import 'text_field.dart';

/// Password preset kept for discoverability.
///
/// Defaults to [PasswordValidationConfig.balanced], the policy the `Password`
/// value object uses, so any password this field accepts also parses as a
/// `Password`.
class GPasswordField extends StatelessWidget {
  final GTextFormField field;

  GPasswordField({
    super.key,
    String? name,
    TextEditingController? controller,
    String? initialValue,
    String label = 'Password',
    String hint = 'Enter your password',
    TextInputAction textInputAction = TextInputAction.done,
    List<TextInputFormatter>? inputFormatters,
    GFormValueParser? valueParser,
    PasswordValidationConfig validationConfig =
        PasswordValidationConfig.balanced,
    ValidationMessageResolver<PasswordValidationIssue>?
    validationMessageResolver,
    GFormValidator? validator,
    GTextFieldConfig Function(GTextFieldConfig config)? configure,
    void Function(String)? onChanged,
    void Function(String)? onFieldSubmitted,
    void Function(String?)? onSaved,
    IconData? prefixIcon,
    FocusNode? focusNode,
    AutovalidateMode? autovalidateMode,
    bool? enabled,
    bool readOnly = false,
    int? maxLength,
    TextAlign textAlign = TextAlign.start,
    TextStyle? style,
    Iterable<String>? autofillHints = const [AutofillHints.password],
    InputDecoration? decoration,
  }) : field = GTextFormField.password(
         name: name,
         controller: controller,
         initialValue: initialValue,
         label: label,
         hint: hint,
         textInputAction: textInputAction,
         inputFormatters: inputFormatters,
         valueParser: valueParser,
         validationConfig: validationConfig,
         validationMessageResolver:
             validationMessageResolver ?? resolvePasswordValidationIssue,
         validator: validator,
         configure: configure,
         onChanged: onChanged,
         onFieldSubmitted: onFieldSubmitted,
         onSaved: onSaved,
         prefixIcon: prefixIcon,
         focusNode: focusNode,
         autovalidateMode: autovalidateMode,
         enabled: enabled,
         readOnly: readOnly,
         maxLength: maxLength,
         textAlign: textAlign,
         style: style,
         autofillHints: autofillHints,
         decoration: decoration,
       );

  GTextFieldConfig get config => field.config;

  @override
  Widget build(BuildContext context) => field;
}
