import 'package:flutter/material.dart';

import '../models/field_config.dart';
import 'configured_text_form_field.dart';
import 'visibility_toggle.dart';

class GObscurableTextFormField extends StatefulWidget {
  const GObscurableTextFormField({super.key, required this.config});

  final GFieldConfig config;

  @override
  State<GObscurableTextFormField> createState() =>
      _GObscurableTextFormFieldState();
}

class _GObscurableTextFormFieldState extends State<GObscurableTextFormField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return GConfiguredTextFormField(
      config: widget.config,
      obscureText: _obscureText,
      suffixIcon: VisibilityToggle(
        onVisibilityChanged: (obscure) {
          setState(() {
            _obscureText = obscure;
          });
        },
      ),
    );
  }
}
