import 'package:gmana_functional/gmana_functional.dart';
import 'package:gmana_validation/gmana_validation.dart' as v;

import '../extensions/validation_adapter_extensions.dart';
import 'network_errors.dart';
import 'network_validation_config.dart';

/// A class responsible for validating string inputs as network addresses.
final class NetworkValidator {
  /// The configuration rules to apply during validation.
  final NetworkValidationConfig config;

  /// Creates a new [NetworkValidator].
  const NetworkValidator([this.config = const NetworkValidationConfig()]);

  /// Validates the given [input] string as a network address.
  Either<NetworkAddressError, String> validate(String input) {
    final vConfig = v.NetworkValidationConfig(
      allowEmpty: config.allowEmpty,
      trimWhitespace: config.trimWhitespace,
      requiredType: config.requiredType,
      ipVersion: config.ipVersion,
    );
    return v.NetworkValidator(vConfig)
        .validate(input)
        .fold((issue) => Left(issue.toNetworkAddressError()), Right.new);
  }
}
