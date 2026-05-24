// ignore_for_file: avoid_print
import 'package:gmana_validation/gmana_validation.dart';

void main() {
  final email = const EmailValidator().validate(' User@Example.COM ');
  final password = const PasswordValidator().validate('StrongP@ssw0rd');
  final name = TextValidator(TextValidationConfig.required(minLength: 3, trimWhitespace: true)).validate('  Gmana  ');
  final quantity = NumberValidator(NumberValidationConfig.positiveInteger(min: 1, max: 99)).validate('12');
  final strength = PasswordStrength.of('StrongP@ssw0rd');

  print('Validation');
  print('  email: ${email.fold(resolveEmailValidationIssue, (value) => value)}');
  print('  password: ${password.fold(resolvePasswordValidationIssue, (_) => 'valid')}');
  print('  text: ${name.fold(resolveTextValidationIssue, (value) => value)}');
  print('  quantity: ${quantity.fold(resolveNumberValidationIssue, (value) => value)}');
  print('  password strength score: ${strength.score}/5');
  print('  unmet requirements: ${strength.unmetRequirements}');
}