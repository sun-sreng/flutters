// Passthrough widget mirroring TextFormField props.
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gmana_validation/gmana_validation.dart';

import '../controllers/form_controller.dart';
import '../models/field_config.dart';
import '../validators/confirm_password_validator.dart';
import '../validators/form_validator_adapter.dart';
import '../widgets/configured_text_form_field.dart';
import '../widgets/form.dart';
import '../widgets/obscurable_text_form_field.dart';

/// Generic text form field with named constructors for common form inputs.
class GTextField extends StatelessWidget {
  const GTextField({
    super.key,
    required this.config,
    this.obscurable = false,
    this.resolveConfig,
  });

  factory GTextField.text({
    Key? key,
    String? name,
    TextEditingController? controller,
    String? initialValue,
    String label = 'Text',
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    List<TextInputFormatter>? inputFormatters,
    GFormValueParser? valueParser,
    TextValidationConfig validationConfig = const TextValidationConfig(),
    ValidationMessageResolver<TextValidationIssue> validationMessageResolver =
        resolveTextValidationIssue,
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
    int? minLines,
    int? maxLines = 1,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextAlign textAlign = TextAlign.start,
    TextStyle? style,
    Iterable<String>? autofillHints,
    InputDecoration? decoration,
  }) {
    final config = GTextFieldConfig(
      controller: controller,
      name: name,
      initialValue: initialValue,
      label: label,
      hint: hint,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      valueParser: valueParser,
      validator: asFormValidator(
        validate: TextValidator(validationConfig).validate,
        resolve: validationMessageResolver,
        validatorOverride: validator,
      ),
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      onSaved: onSaved,
      prefixIcon: prefixIcon ?? Icons.text_fields,
      focusNode: focusNode,
      autovalidateMode: autovalidateMode,
      enabled: enabled,
      readOnly: readOnly,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      textAlign: textAlign,
      style: style,
      autofillHints: autofillHints,
      decoration: decoration,
    );

    return GTextField(key: key, config: configure?.call(config) ?? config);
  }

  /// Multi-line text area.
  ///
  /// Every other preset pins `maxLines: 1`, so notes and descriptions had to
  /// be assembled by hand. This one defaults to a growing box and an Enter key
  /// that inserts a newline instead of moving to the next field.
  factory GTextField.multiline({
    Key? key,
    String? name,
    TextEditingController? controller,
    String? initialValue,
    String label = 'Notes',
    String? hint,
    TextInputAction textInputAction = TextInputAction.newline,
    List<TextInputFormatter>? inputFormatters,
    GFormValueParser? valueParser,
    TextValidationConfig validationConfig = const TextValidationConfig(),
    ValidationMessageResolver<TextValidationIssue> validationMessageResolver =
        resolveTextValidationIssue,
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
    int minLines = 3,
    int maxLines = 6,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
    TextAlign textAlign = TextAlign.start,
    TextStyle? style,
    Iterable<String>? autofillHints,
    InputDecoration? decoration,
  }) {
    final config = GTextFieldConfig(
      controller: controller,
      name: name,
      initialValue: initialValue,
      label: label,
      hint: hint,
      keyboardType: TextInputType.multiline,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      valueParser: valueParser,
      validator: asFormValidator(
        validate: TextValidator(validationConfig).validate,
        resolve: validationMessageResolver,
        validatorOverride: validator,
      ),
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      onSaved: onSaved,
      prefixIcon: prefixIcon,
      focusNode: focusNode,
      autovalidateMode: autovalidateMode,
      enabled: enabled,
      readOnly: readOnly,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      textAlign: textAlign,
      style: style,
      autofillHints: autofillHints,
      decoration: decoration,
    );

    return GTextField(key: key, config: configure?.call(config) ?? config);
  }

  factory GTextField.email({
    Key? key,
    String? name,
    TextEditingController? controller,
    String? initialValue,
    String label = 'Email',
    String hint = 'Enter your email',
    TextInputAction textInputAction = TextInputAction.next,
    List<TextInputFormatter>? inputFormatters,
    GFormValueParser? valueParser,
    EmailValidationConfig validationConfig = const EmailValidationConfig(),
    ValidationMessageResolver<EmailValidationIssue> validationMessageResolver =
        resolveEmailValidationIssue,
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
    Iterable<String>? autofillHints = const [AutofillHints.email],
    InputDecoration? decoration,
  }) {
    final config = GTextFieldConfig(
      controller: controller,
      name: name,
      initialValue: initialValue,
      label: label,
      hint: hint,
      keyboardType: TextInputType.emailAddress,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      valueParser: valueParser,
      validator: asFormValidator(
        validate: EmailValidator(validationConfig).validate,
        resolve: validationMessageResolver,
        validatorOverride: validator,
      ),
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      onSaved: onSaved,
      prefixIcon: prefixIcon ?? Icons.email,
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

    return GTextField(key: key, config: configure?.call(config) ?? config);
  }

  factory GTextField.number({
    Key? key,
    String? name,
    TextEditingController? controller,
    String? initialValue,
    String label = 'Number',
    String? hint,
    TextInputAction textInputAction = TextInputAction.next,
    List<TextInputFormatter>? inputFormatters,
    GFormValueParser? valueParser,
    NumberValidationConfig validationConfig = const NumberValidationConfig(
      allowNegative: false,
      integerOnly: true,
    ),
    ValidationMessageResolver<NumberValidationIssue> validationMessageResolver =
        resolveNumberValidationIssue,
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
    Iterable<String>? autofillHints,
    InputDecoration? decoration,
  }) {
    final config = GTextFieldConfig(
      controller: controller,
      name: name,
      initialValue: initialValue,
      label: label,
      hint: hint,
      keyboardType: TextInputType.numberWithOptions(
        signed: validationConfig.allowNegative,
        decimal: !validationConfig.integerOnly,
      ),
      textInputAction: textInputAction,
      inputFormatters: [
        _numberFormatter(validationConfig),
        if (inputFormatters != null) ...inputFormatters,
      ],
      valueParser: valueParser ?? _numberParser(validationConfig),
      validator: asFormValidator(
        validate: NumberValidator(validationConfig).validate,
        resolve: validationMessageResolver,
        validatorOverride: validator,
      ),
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      onSaved: onSaved,
      prefixIcon: prefixIcon ?? Icons.onetwothree,
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

    return GTextField(key: key, config: configure?.call(config) ?? config);
  }

  factory GTextField.password({
    Key? key,
    String? name,
    TextEditingController? controller,
    String? initialValue,
    String label = 'Password',
    String hint = 'Enter your password',
    TextInputAction textInputAction = TextInputAction.done,
    List<TextInputFormatter>? inputFormatters,
    GFormValueParser? valueParser,
    PasswordValidationConfig validationConfig =
        const PasswordValidationConfig(),
    ValidationMessageResolver<PasswordValidationIssue>
        validationMessageResolver =
        resolvePasswordValidationIssue,
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
  }) {
    final config = GTextFieldConfig(
      controller: controller,
      name: name,
      initialValue: initialValue,
      label: label,
      hint: hint,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      valueParser: valueParser,
      validator: asFormValidator(
        validate: PasswordValidator(validationConfig).validate,
        resolve: validationMessageResolver,
        validatorOverride: validator,
      ),
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      onSaved: onSaved,
      prefixIcon: prefixIcon ?? Icons.lock,
      focusNode: focusNode,
      autovalidateMode: autovalidateMode,
      enabled: enabled,
      readOnly: readOnly,
      obscureText: true,
      autocorrect: false,
      enableSuggestions: false,
      maxLength: maxLength,
      textAlign: textAlign,
      style: style,
      autofillHints: autofillHints,
      decoration: decoration,
    );

    return GTextField(
      key: key,
      config: configure?.call(config) ?? config,
      obscurable: true,
    );
  }

  factory GTextField.confirmPassword({
    Key? key,
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
    ValidationMessageResolver<ConfirmPasswordValidationIssue>
        validationMessageResolver =
        resolveConfirmPasswordValidationIssue,
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
  }) {
    assert(
      passwordController != null || passwordName != null,
      'Provide either passwordController or passwordName.',
    );

    GFormValidator confirmValidator(TextEditingController passwordController) {
      return (value) {
        final message = ConfirmPasswordValidator(validationConfig)
            .validate(
              password: passwordController.text,
              confirmation: value ?? '',
            )
            .fold(validationMessageResolver, (_) => null);
        return message ?? validator?.call(value);
      };
    }

    final config = GTextFieldConfig(
      controller: controller,
      name: name,
      initialValue: initialValue,
      label: label,
      hint: hint,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      valueParser: valueParser,
      validator:
          passwordController == null
              ? null
              : confirmValidator(passwordController),
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      onSaved: onSaved,
      prefixIcon: prefixIcon ?? Icons.lock,
      focusNode: focusNode,
      autovalidateMode: autovalidateMode,
      enabled: enabled,
      readOnly: readOnly,
      obscureText: true,
      autocorrect: false,
      enableSuggestions: false,
      maxLength: maxLength,
      textAlign: textAlign,
      style: style,
      autofillHints: autofillHints,
      decoration: decoration,
    );

    return GTextField(
      key: key,
      config: configure?.call(config) ?? config,
      obscurable: true,
      resolveConfig:
          passwordName == null
              ? null
              : (context, config) {
                final controller = GForm.controllerOf(
                  context,
                ).textController(passwordName);
                return config.copyWith(validator: confirmValidator(controller));
              },
    );
  }

  factory GTextField.url({
    Key? key,
    String? name,
    TextEditingController? controller,
    String? initialValue,
    String label = 'URL',
    String hint = 'Enter a valid URL',
    TextInputAction textInputAction = TextInputAction.next,
    List<TextInputFormatter>? inputFormatters,
    GFormValueParser? valueParser,
    UrlValidationConfig validationConfig = const UrlValidationConfig(),
    ValidationMessageResolver<UrlValidationIssue> validationMessageResolver =
        resolveUrlValidationIssue,
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
    Iterable<String>? autofillHints = const [AutofillHints.url],
    InputDecoration? decoration,
  }) {
    final config = GTextFieldConfig(
      controller: controller,
      name: name,
      initialValue: initialValue,
      label: label,
      hint: hint,
      keyboardType: TextInputType.url,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      valueParser: valueParser,
      validator: asFormValidator(
        validate: UrlValidator(validationConfig).validate,
        resolve: validationMessageResolver,
        validatorOverride: validator,
      ),
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      onSaved: onSaved,
      prefixIcon: prefixIcon ?? Icons.link,
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

    return GTextField(key: key, config: configure?.call(config) ?? config);
  }

  factory GTextField.phone({
    Key? key,
    String? name,
    TextEditingController? controller,
    String? initialValue,
    String label = 'Phone number',
    String hint = 'Enter your phone number',
    TextInputAction textInputAction = TextInputAction.next,
    List<TextInputFormatter>? inputFormatters,
    GFormValueParser? valueParser,
    PhoneValidationConfig validationConfig = const PhoneValidationConfig(),
    ValidationMessageResolver<PhoneValidationIssue> validationMessageResolver =
        resolvePhoneValidationIssue,
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
  }) {
    final config = GTextFieldConfig(
      controller: controller,
      name: name,
      initialValue: initialValue,
      label: label,
      hint: hint,
      keyboardType: TextInputType.phone,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      valueParser: valueParser,
      validator: asFormValidator(
        validate: PhoneValidator(validationConfig).validate,
        resolve: validationMessageResolver,
        validatorOverride: validator,
      ),
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      onSaved: onSaved,
      prefixIcon: prefixIcon ?? Icons.phone,
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

    return GTextField(key: key, config: configure?.call(config) ?? config);
  }

  final GTextFieldConfig config;
  final bool obscurable;
  final GTextFieldConfig Function(
    BuildContext context,
    GTextFieldConfig config,
  )?
  resolveConfig;

  @override
  Widget build(BuildContext context) {
    final config = resolveConfig?.call(context, this.config) ?? this.config;
    if (obscurable) {
      return GObscurableTextFormField(config: config);
    }
    return GConfiguredTextFormField(config: config);
  }

  static TextInputFormatter _numberFormatter(NumberValidationConfig config) {
    return switch ((config.integerOnly, config.allowNegative)) {
      (true, false) => FilteringTextInputFormatter.digitsOnly,
      (true, true) => FilteringTextInputFormatter.allow(RegExp(r'^-?\d*$')),
      (false, false) => FilteringTextInputFormatter.allow(
        RegExp(r'^\d*\.?\d*$'),
      ),
      (false, true) => FilteringTextInputFormatter.allow(
        RegExp(r'^-?\d*\.?\d*$'),
      ),
    };
  }

  static GFormValueParser _numberParser(NumberValidationConfig config) {
    return config.integerOnly ? int.tryParse : double.tryParse;
  }
}
