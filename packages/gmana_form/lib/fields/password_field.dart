// Passthrough widget mirroring TextFormField props.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gmana_validation/gmana_validation.dart';

import '../models/field_config.dart';
import 'text_field.dart';

/// Password preset kept for discoverability.
class GPasswordField extends StatelessWidget {
  GPasswordField({
    super.key,
    String? name,
    TextEditingController? controller,
    String? initialValue,
    String label = 'Password',
    String hint = 'Enter your password',
    TextInputAction textInputAction = TextInputAction.done,
    List<TextInputFormatter>? inputFormatters,
    PasswordValidationConfig validationConfig =
        const PasswordValidationConfig(),
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
  }) : field = GTextField.password(
         name: name,
         controller: controller,
         initialValue: initialValue,
         label: label,
         hint: hint,
         textInputAction: textInputAction,
         inputFormatters: inputFormatters,
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

  final GTextField field;

  GTextFieldConfig get config => field.config;

  @override
  Widget build(BuildContext context) => field;
}