import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gmana/validator/number_field_validator.dart';

import '../models/field_config.dart';
import '../widgets/configured_text_form_field.dart';
import 'base_field.dart';

/// A number input field with min/max validation.
class GNumberField extends GBaseField {
  GNumberField({
    super.key,
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    TextInputAction? textInputAction,
    List<TextInputFormatter>? additionalFormatters,
    String? Function(String?)? additionalValidator,
    void Function(String)? onChanged,
    int? minValue,
    int? maxValue,
  }) : super(
         config: GFieldConfig(
           controller: controller,
           labelText: labelText,
           hintText: hintText ?? '',
           keyboardType: TextInputType.number,
           textInputAction: textInputAction ?? TextInputAction.next,
           inputFormatters: [
             FilteringTextInputFormatter.digitsOnly,
             if (additionalFormatters != null) ...additionalFormatters,
           ],
           validator:
               NumberFieldValidator(
                 minValue: minValue,
                 maxValue: maxValue,
                 additionalValidator: additionalValidator,
               ).validate,
           onChanged: onChanged,
           prefixIcon: Icons.onetwothree,
         ),
       );

  @override
  Widget build(BuildContext context) {
    return GConfiguredTextFormField(config: config);
  }
}
