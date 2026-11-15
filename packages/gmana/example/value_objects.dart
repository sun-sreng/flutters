// ignore_for_file: avoid_print
import 'package:gmana/gmana.dart';

void main() {
  // Untrusted input: `tryParse` returns Either<ValidationIssue, ValueObject>.
  final email = Email.tryParse(' User@Example.COM ');
  final displayName = TextValue.tryParse(
    '  Gmana User  ',
    config: TextValue.defaultConfig.copyWith(minLength: 3),
  );
  final password = Password.tryParse('StrongP@ssw0rd');

  // Trusted literals: throwing constructors build the value directly.
  final quantity = NumberValue.fromNum(3);
  final subtotal = Money.fromDecimalString('19.99', Currency.usd) * 2;
  final tax = subtotal.applyPercent(7);
  final total = subtotal + tax;

  print('Value objects');
  print('  email: ${_describe(email)}');
  print('  display name: ${_describe(displayName)}');
  print('  password valid: ${password.isRight()}, sensitive: true');
  print('  quantity: ${quantity.asInt}');
  print('  subtotal: ${subtotal.formattedWithCode}');
  print('  tax: ${tax.formattedWithCode}');
  print('  total: ${total.formattedWithCode}');
}

String _describe(Either<ValidationIssue, ValueObject<Object>> result) {
  return result.fold(
    (issue) => 'invalid (${resolveValidationIssue(issue)})',
    (value) => '${value.value}',
  );
}
