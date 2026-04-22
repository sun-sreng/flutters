import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/field_config.dart';
import '../widgets/obscurable_text_form_field.dart';
import 'base_field.dart';

class GPasswordField extends GBaseField {
  GPasswordField({
    super.key,
    required TextEditingController controller,
    String labelText = 'Password',
    String? hintText,
    TextInputAction? textInputAction,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) : super(
         config: GFieldConfig(
           controller: controller,
           labelText: labelText,
           hintText: hintText ?? 'Enter your password',
           keyboardType: TextInputType.visiblePassword,
           textInputAction: textInputAction ?? TextInputAction.done,
           inputFormatters: inputFormatters,
           validator: validator,
           onChanged: onChanged,
           prefixIcon: Icons.lock,
         ),
       );

  @override
  Widget build(BuildContext context) {
    return GObscurableTextFormField(config: config);
  }
}
