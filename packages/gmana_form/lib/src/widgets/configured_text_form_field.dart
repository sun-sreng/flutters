// Passthrough widget mirroring TextFormField props.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

import '../models/field_config.dart';
import 'form.dart';

class GConfiguredTextFormField extends StatelessWidget {
  const GConfiguredTextFormField({
    super.key,
    required this.config,
    this.suffixIcon,
  });

  final GTextFieldConfig config;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final formController =
        config.name == null ? null : GForm.controllerOf(context);
    final controller =
        config.controller ??
        (config.name == null
            ? null
            : formController!.textController(
              config.name!,
              text: config.initialValue,
            ));

    if (config.name != null && controller != null) {
      formController!
        ..bindTextController(
          config.name!,
          controller,
          parser: config.valueParser,
        )
        ..bindTextValidator(config.name!, config.validator);
    }

    // A named field without its own node borrows the controller's, so
    // GFormController.requestFocus and focusFirstInvalid can reach it.
    final focusNode =
        config.focusNode ??
        (config.name == null ? null : formController!.focusNode(config.name!));

    return TextFormField(
      controller: controller,
      initialValue: controller == null ? config.initialValue : null,
      focusNode: focusNode,
      autofocus: config.autofocus,
      onTap: config.onTap,
      onEditingComplete: config.onEditingComplete,
      obscureText: config.obscureText,
      obscuringCharacter: config.obscuringCharacter,
      autocorrect: config.autocorrect,
      enableSuggestions: config.enableSuggestions,
      keyboardType: config.keyboardType,
      textInputAction: config.textInputAction,
      inputFormatters: config.inputFormatters,
      validator: config.validator,
      onChanged: config.onChanged,
      onFieldSubmitted: config.onFieldSubmitted,
      onSaved: config.onSaved,
      autovalidateMode: config.autovalidateMode,
      enabled: config.enabled,
      readOnly: config.readOnly,
      minLines: config.minLines,
      maxLines: config.obscureText ? 1 : config.maxLines,
      maxLength: config.maxLength,
      textCapitalization: config.textCapitalization,
      textAlign: config.textAlign,
      style: config.style,
      autofillHints: config.autofillHints,
      decoration: (config.decoration ?? const InputDecoration()).copyWith(
        labelText: config.decoration?.labelText ?? config.label,
        hintText: config.decoration?.hintText ?? config.hint,
        prefix: config.decoration?.prefix ?? config.prefix,
        prefixIcon:
            config.decoration?.prefixIcon ??
            (config.prefixIcon != null ? Icon(config.prefixIcon) : null),
        suffix: config.decoration?.suffix ?? config.suffix,
        suffixIcon:
            config.decoration?.suffixIcon ?? suffixIcon ?? config.suffixIcon,
      ),
    );
  }
}
