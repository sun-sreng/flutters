import '../../../functional.dart';
import 'package:meta/meta.dart';

import '../core/value_object.dart';
import '../core/value_object_exception.dart';
import '../../validation/network/network_validation_config.dart';
import '../../validation/network/network_validation_issue.dart';
import '../../validation/network/network_validator.dart';

/// Immutable domain value object representing a validated network address.
@immutable
final class NetworkAddressValue extends ValueObject<String> {
  @override
  final String value;

  const NetworkAddressValue._(this.value);

  /// Constructs a [NetworkAddressValue] from a trusted string.
  /// Throws [ValueObjectException] if input is invalid.
  factory NetworkAddressValue(
    String input, {
    NetworkValidationConfig config = const NetworkValidationConfig(),
  }) {
    return tryParse(
      input,
      config: config,
    ).fold((error) => throw ValueObjectException(error), (val) => val);
  }

  /// Attempts to parse [input] into a [NetworkAddressValue].
  /// Returns `Either<NetworkValidationIssue, NetworkAddressValue>`.
  static Either<NetworkValidationIssue, NetworkAddressValue> tryParse(
    String input, {
    NetworkValidationConfig config = const NetworkValidationConfig(),
  }) {
    return NetworkValidator(config).validate(input).map(NetworkAddressValue._);
  }
}
