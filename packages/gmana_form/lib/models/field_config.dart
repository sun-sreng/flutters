// Config mirrors TextFormField props verbatim.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Flutter `FormField.validator` compatible validator.
typedef GFormValidator = String? Function(String? value);

/// Shared configuration for every text-based form field in this package.
///
/// The config intentionally mirrors the most common `TextFormField` options so
/// teams can start with the built-in presets and still customize production
/// forms without dropping down to raw Flutter widgets.
final class GTextFieldConfig {
  final String? name;
  final TextEditingController? controller;
  final String? initialValue;
  final String? label;
  final String? hint;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final GFormValidator? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final void Function(String?)? onSaved;
  final IconData? prefixIcon;
  final Widget? prefix;
  final Widget? suffix;
  final Widget? suffixIcon;
  final FocusNode? focusNode;
  final AutovalidateMode? autovalidateMode;
  final bool? enabled;
  final bool readOnly;
  final bool obscureText;
  final String obscuringCharacter;
  final bool autocorrect;
  final bool enableSuggestions;
  final int? minLines;
  final int? maxLines;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final TextStyle? style;
  final Iterable<String>? autofillHints;
  final InputDecoration? decoration;

  const GTextFieldConfig({
    this.name,
    this.controller,
    this.initialValue,
    this.label,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onSaved,
    this.prefixIcon,
    this.prefix,
    this.suffix,
    this.suffixIcon,
    this.focusNode,
    this.autovalidateMode,
    this.enabled,
    this.readOnly = false,
    this.obscureText = false,
    this.obscuringCharacter = '*',
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.minLines,
    this.maxLines = 1,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.style,
    this.autofillHints,
    this.decoration,
  }) : assert(
         controller == null || initialValue == null,
         'Provide either controller or initialValue, not both.',
       );

  GTextFieldConfig copyWith({
    String? name,
    TextEditingController? controller,
    String? initialValue,
    String? label,
    String? hint,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    List<TextInputFormatter>? inputFormatters,
    GFormValidator? validator,
    void Function(String)? onChanged,
    void Function(String)? onFieldSubmitted,
    void Function(String?)? onSaved,
    IconData? prefixIcon,
    Widget? prefix,
    Widget? suffix,
    Widget? suffixIcon,
    FocusNode? focusNode,
    AutovalidateMode? autovalidateMode,
    bool? enabled,
    bool? readOnly,
    bool? obscureText,
    String? obscuringCharacter,
    bool? autocorrect,
    bool? enableSuggestions,
    int? minLines,
    int? maxLines,
    int? maxLength,
    TextCapitalization? textCapitalization,
    TextAlign? textAlign,
    TextStyle? style,
    Iterable<String>? autofillHints,
    InputDecoration? decoration,
  }) {
    return GTextFieldConfig(
      name: name ?? this.name,
      controller: controller ?? this.controller,
      initialValue: initialValue ?? this.initialValue,
      label: label ?? this.label,
      hint: hint ?? this.hint,
      keyboardType: keyboardType ?? this.keyboardType,
      textInputAction: textInputAction ?? this.textInputAction,
      inputFormatters: inputFormatters ?? this.inputFormatters,
      validator: validator ?? this.validator,
      onChanged: onChanged ?? this.onChanged,
      onFieldSubmitted: onFieldSubmitted ?? this.onFieldSubmitted,
      onSaved: onSaved ?? this.onSaved,
      prefixIcon: prefixIcon ?? this.prefixIcon,
      prefix: prefix ?? this.prefix,
      suffix: suffix ?? this.suffix,
      suffixIcon: suffixIcon ?? this.suffixIcon,
      focusNode: focusNode ?? this.focusNode,
      autovalidateMode: autovalidateMode ?? this.autovalidateMode,
      enabled: enabled ?? this.enabled,
      readOnly: readOnly ?? this.readOnly,
      obscureText: obscureText ?? this.obscureText,
      obscuringCharacter: obscuringCharacter ?? this.obscuringCharacter,
      autocorrect: autocorrect ?? this.autocorrect,
      enableSuggestions: enableSuggestions ?? this.enableSuggestions,
      minLines: minLines ?? this.minLines,
      maxLines: maxLines ?? this.maxLines,
      maxLength: maxLength ?? this.maxLength,
      textCapitalization: textCapitalization ?? this.textCapitalization,
      textAlign: textAlign ?? this.textAlign,
      style: style ?? this.style,
      autofillHints: autofillHints ?? this.autofillHints,
      decoration: decoration ?? this.decoration,
    );
  }
}