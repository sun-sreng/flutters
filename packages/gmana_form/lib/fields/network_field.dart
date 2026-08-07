import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gmana_validation/gmana_validation.dart';

import '../controllers/form_controller.dart';
import '../models/field_config.dart';
import '../validators/form_validator_adapter.dart';
import '../widgets/configured_text_form_field.dart';

/// Form field widget for network address inputs (IP, IPv4, IPv6, CIDR, MAC, Port).
class GNetworkField extends StatelessWidget {
  /// Creates a [GNetworkField].
  GNetworkField({
    super.key,
    String? name,
    TextEditingController? controller,
    String? initialValue,
    String label = 'Network Address',
    String hint = 'e.g. 192.168.1.1',
    TextInputAction textInputAction = TextInputAction.next,
    List<TextInputFormatter>? inputFormatters,
    GFormValueParser? valueParser,
    NetworkValidationConfig validationConfig = const NetworkValidationConfig(),
    ValidationMessageResolver<NetworkValidationIssue>
    validationMessageResolver = resolveNetworkValidationIssue,
    GFormValidator? validator,
    GTextFieldConfig Function(GTextFieldConfig config)? configure,
    void Function(String)? onChanged,
    void Function(String)? onFieldSubmitted,
    void Function(String?)? onSaved,
    IconData prefixIcon = Icons.lan_outlined,
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
      validate: NetworkValidator(validationConfig).validate,
      resolve: validationMessageResolver,
      validatorOverride: validator,
    );

    var fieldConfig = GTextFieldConfig(
      controller: controller,
      name: name,
      initialValue: initialValue,
      label: label,
      hint: hint,
      keyboardType: validationConfig.requiredType == NetworkAddressType.port
          ? TextInputType.number
          : TextInputType.url,
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

