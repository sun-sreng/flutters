// Passthrough widget mirroring TextFormField props.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gmana_validation/gmana_validation.dart';

import '../controllers/form_controller.dart';
import '../models/field_config.dart';
import '../validators/confirm_password_validator.dart';
import 'text_field.dart';

/// Confirm-password preset kept for discoverability.
class GConfirmPasswordField extends StatelessWidget {
  GConfirmPasswordField({
    super.key,
    String? name,
    TextEditingController? controller,
    String? initialValue,
    TextEditingController? passwordController,
    String? passwordName,
    String label = 'Confirm password',
    String hint = 'Re-enter your password',
    TextInputAction textInputAction = TextInputAction.done,
    List<TextInputFormatter>? inputFormatters,
    GFormValueParser? valueParser,
    ConfirmPasswordValidationConfig validationConfig =
        const ConfirmPasswordValidationConfig(),
    ValidationMessageResolver<ConfirmPasswordValidationIssue>?
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
  }) : field = GTextField.confirmPassword(
         name: name,
         controller: controller,
         initialValue: initialValue,
         passwordController: passwordController,
         passwordName: passwordName,
         label: label,
         hint: hint,
         textInputAction: textInputAction,
         inputFormatters: inputFormatters,
         valueParser: valueParser,
         validationConfig: validationConfig,
         validationMessageResolver:
             validationMessageResolver ?? resolveConfirmPasswordValidationIssue,
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
