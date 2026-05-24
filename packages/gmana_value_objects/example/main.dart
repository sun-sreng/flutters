// ignore_for_file: avoid_print
import 'package:gmana_value_objects/gmana_value_objects.dart';

void main() {
  const messages = DefaultValidationErrorMessages();

  final email = Email(' User@Example.COM ');
  final password = Password('StrongP@ssw0rd');
  final displayName = TextValue(
    '  Gmana User  ',
    config: const TextValidationConfig(minLength: 3, trimWhitespace: true),
  );
  final quantity = NumberValue.fromNum(3);
  final subtotal = Money.fromDecimalString('19.99', Currency.usd) * 2;
  final tax = subtotal.applyPercent(7);
  final total = subtotal + tax;

  print('Value objects');
  print('  email: ${_describe(email, messages)}');
  print('  password valid: ${password.isValid}, sensitive: ${password.isSensitive}');
  print('  display name: ${_describe(displayName, messages)}');
  print('  quantity: ${quantity.asInt}');
  print('  subtotal: ${subtotal.formattedWithCode}');
  print('  tax: ${tax.formattedWithCode}');
  print('  total: ${total.formattedWithCode}');
}

String _describe(ValueObject<Object> value, ValidationErrorMessages messages) {
  final error = value.errorOrNull;
  if (error != null) {
    return messages.getMessage(error);
  }
  return '${value.valueOrNull}';
}