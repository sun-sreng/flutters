// Passthrough widget mirroring TextFormField props.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gmana_validation/gmana_validation.dart';

import '../controllers/form_controller.dart';
import '../models/field_config.dart';
import 'text_field.dart';

/// Phone number preset kept for discoverability.
class GPhoneField extends StatelessWidget {
  GPhoneField({
    super.key,
    String? name,
    TextEditingController? controller,
    String? initialValue,
    String label = 'Phone number',
    String hint = 'Enter your phone number',
    TextInputAction textInputAction = TextInputAction.next,
    List<TextInputFormatter>? inputFormatters,
    GFormValueParser? valueParser,
    PhoneValidationConfig validationConfig = const PhoneValidationConfig(),
    ValidationMessageResolver<PhoneValidationIssue>? validationMessageResolver,
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
    Iterable<String>? autofillHints = const [AutofillHints.telephoneNumber],
    InputDecoration? decoration,
  }) : field = GTextField.phone(
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
             validationMessageResolver ?? resolvePhoneValidationIssue,
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
