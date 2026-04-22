import 'package:flutter/material.dart';

import '../models/field_config.dart';

class GConfiguredTextFormField extends StatelessWidget {
  const GConfiguredTextFormField({
    super.key,
    required this.config,
    this.obscureText = false,
    this.suffixIcon,
  });

  final GFieldConfig config;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: config.controller,
      obscureText: obscureText,
      keyboardType: config.keyboardType,
      textInputAction: config.textInputAction,
      inputFormatters: config.inputFormatters,
      validator: config.validator,
      onChanged: config.onChanged,
      decoration: InputDecoration(
        labelText: config.labelText,
        hintText: config.hintText,
        prefixIcon: config.prefixIcon != null ? Icon(config.prefixIcon) : null,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
