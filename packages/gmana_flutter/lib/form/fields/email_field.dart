import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gmana/validator/email_field_validator.dart';
import 'package:gmana_flutter/form/models/field_config.dart';

import 'base_field.dart';

/// A customizable email input field with default validation and email-specific keyboard.
class GEmailField extends GBaseField {
  GEmailField({
    super.key,
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    TextInputAction? textInputAction,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? additionalValidator,
    void Function(String)? onChanged,
    IconData? prefixIcon,
  }) : super(
         config: GFieldConfig(
           controller: controller,
           labelText: labelText,
           hintText: hintText ?? 'Enter your email',
           keyboardType: TextInputType.emailAddress,
           textInputAction: textInputAction ?? TextInputAction.next,
           inputFormatters: inputFormatters,
           validator:
               EmailFieldValidator(
                 additionalValidator: additionalValidator,
               ).validate,
           onChanged: onChanged,
           prefixIcon: prefixIcon ?? Icons.email,
         ),
       );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: config.controller,
      keyboardType: config.keyboardType,
      textInputAction: config.textInputAction,
      inputFormatters: config.inputFormatters,
      validator: config.validator,
      onChanged: config.onChanged,
      decoration: InputDecoration(
        labelText: config.labelText,
        hintText: config.hintText,
        prefixIcon: Icon(config.prefixIcon),
      ),
    );
  }
}
