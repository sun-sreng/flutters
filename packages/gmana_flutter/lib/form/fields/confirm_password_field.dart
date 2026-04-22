import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/field_config.dart';
import '../validators/confirm_password_validator.dart';
import '../widgets/visibility_toggle.dart';
import 'base_field.dart';

class GConfirmPasswordField extends GBaseField {
  GConfirmPasswordField({
    super.key,
    required TextEditingController controller,
    required TextEditingController passwordController,
    String labelText = 'Confirm Password',
    String? hintText,
    TextInputAction? textInputAction,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? additionalValidator,
    void Function(String)? onChanged,
  }) : super(
         config: GFieldConfig(
           controller: controller,
           labelText: labelText,
           hintText: hintText ?? 'Re-enter your password',
           keyboardType: TextInputType.visiblePassword,
           textInputAction: textInputAction ?? TextInputAction.done,
           inputFormatters: inputFormatters,
           validator:
               ConfirmPasswordValidator(
                 passwordController: passwordController,
                 additionalValidator: additionalValidator,
               ).validate,
           onChanged: onChanged,
           prefixIcon: Icons.lock,
         ),
       );

  @override
  Widget build(BuildContext context) {
    return _GConfirmPasswordFieldContent(config: config);
  }
}

class _GConfirmPasswordFieldContent extends StatefulWidget {
  final GFieldConfig config;

  const _GConfirmPasswordFieldContent({required this.config});

  @override
  State<_GConfirmPasswordFieldContent> createState() =>
      _GConfirmPasswordFieldContentState();
}

class _GConfirmPasswordFieldContentState
    extends State<_GConfirmPasswordFieldContent> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.config.controller,
      obscureText: _obscureText,
      keyboardType: widget.config.keyboardType,
      textInputAction: widget.config.textInputAction,
      inputFormatters: widget.config.inputFormatters,
      validator: widget.config.validator,
      onChanged: widget.config.onChanged,
      decoration: InputDecoration(
        labelText: widget.config.labelText,
        hintText: widget.config.hintText,
        prefixIcon: Icon(widget.config.prefixIcon),
        suffixIcon: VisibilityToggle(
          onVisibilityChanged:
              (obscure) => setState(() => _obscureText = obscure),
        ),
      ),
    );
  }
}
