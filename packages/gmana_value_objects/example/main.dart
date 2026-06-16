// ignore_for_file: avoid_print
import 'package:gmana_value_objects/gmana_value_objects.dart';

void main() {
  const messages = DefaultValidationErrorMessages();

  // Untrusted input: `tryParse` returns Either<Error, ValueObject>.
  final email = Email.tryParse(' User@Example.COM ');
  final displayName = TextValue.tryParse(
    '  Gmana User  ',
    config: const TextValidationConfig(minLength: 3),
  );
  final password = Password.tryParse('StrongP@ssw0rd');

  // Trusted literals: throwing constructors build the value directly.
  final quantity = NumberValue.fromNum(3);
  final subtotal = Money.fromDecimalString('19.99', Currency.usd) * 2;
  final tax = subtotal.applyPercent(7);
  final total = subtotal + tax;

  print('Value objects');
  print('  email: ${_describe(email, messages)}');
  print('  display name: ${_describe(displayName, messages)}');
  print('  password valid: ${password.isRight()}, sensitive: true');
  print('  quantity: ${quantity.asInt}');
  print('  subtotal: ${subtotal.formattedWithCode}');
  print('  tax: ${tax.formattedWithCode}');
  print('  total: ${total.formattedWithCode}');
}

String _describe(
  Either<ValidationError, ValueObject<Object>> result,
  ValidationErrorMessages messages,
) {
  return result.fold(
    (error) => 'invalid (${messages.getMessage(error)})',
    (value) => '${value.value}',
  );
}
