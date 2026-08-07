import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gmana_validation/gmana_validation.dart';

import '../controllers/form_controller.dart';
import '../models/field_config.dart';
import '../validators/form_validator_adapter.dart';
import '../widgets/configured_text_form_field.dart';

/// Form field widget for identifier inputs (UUID, ULID, IMEI, EAN, CreditCard, MongoId, SemVer, NanoId).
class GIdentifierField extends StatelessWidget {
  /// Creates a [GIdentifierField].
  GIdentifierField({
    super.key,
    String? name,
    TextEditingController? controller,
    String? initialValue,
    String label = 'Identifier',
    String hint = 'Enter identifier',
    TextInputAction textInputAction = TextInputAction.next,
    List<TextInputFormatter>? inputFormatters,
    GFormValueParser? valueParser,
    IdentifierValidationConfig validationConfig =
        const IdentifierValidationConfig(),
    ValidationMessageResolver<IdentifierValidationIssue>
    validationMessageResolver = resolveIdentifierValidationIssue,
    GFormValidator? validator,
    GTextFieldConfig Function(GTextFieldConfig config)? configure,
    void Function(String)? onChanged,
    void Function(String)? onFieldSubmitted,
    void Function(String?)? onSaved,
    IconData prefixIcon = Icons.badge_outlined,
    FocusNode? focusNode,
    AutovalidateMode? autovalidateMode,
    bool? enabled,
    bool readOnly = false,
    int? maxLength,
    TextAlign textAlign = TextAlign.start,
    TextStyle? style,
    InputDecoration? decoration,
  }) {
    final adapter = asFormValidator(
      validate: IdentifierValidator(validationConfig).validate,
      resolve: validationMessageResolver,
      validatorOverride: validator,
    );

    var fieldConfig = GTextFieldConfig(
      controller: controller,
      name: name,
      initialValue: initialValue,
      label: label,
      hint: hint,
      keyboardType: TextInputType.text,
      textInputAction: textInputAction,
      inputFormatters: inputFormatters,
      valueParser: valueParser,
      validator: adapter,
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
      decoration: decoration,
    );

    if (configure != null) {
      fieldConfig = configure(fieldConfig);
    }

    config = fieldConfig;
  }

  /// Field configuration.
  late final GTextFieldConfig config;

  @override
  Widget build(BuildContext context) {
    return GConfiguredTextFormField(config: config);
  }
}

