import 'package:value_objects/value_objects.dart';

void main() {
  print('--- Value Objects Example ---\n');

  // 1. Email Example
  print('1. Email Validation');
  final validEmail = Email('test@example.com');
  final invalidEmail = Email('invalid-email');

  print('Valid Email - value: ${validEmail.valueOrNull}, isValid: ${validEmail.isValid}');
  print('Invalid Email - error: ${invalidEmail.errorOrNull.runtimeType}, isInvalid: ${invalidEmail.isInvalid}');
  
  invalidEmail.value.match(
    (error) => print('  -> Failed with: ${error.runtimeType}'),
    (email) => print('  -> Success: $email'),
  );
  print('');

  // 2. Password Example
  print('2. Password Validation');
  // Strict config requires 12 chars, complexity 4 (upper, lower, num, symbol)
  final strictConfig = PasswordValidationConfig.strict();
  final weakPassword = Password('pass123', config: strictConfig);
  final strongPassword = Password('Str0ngP@sswo', config: strictConfig);

  print('Weak Password (strict) - isValid: ${weakPassword.isValid}, error: ${weakPassword.errorOrNull.runtimeType}');
  print('Strong Password (strict) - isValid: ${strongPassword.isValid}');
  
  // Example of using pattern matching to gracefully resolve errors
  weakPassword.value.match(
    (error) {
      if (error is PasswordComplexityRequired) {
        print('  -> Password is too simple. Need more complexity.');
      } else if (error is PasswordTooShort) {
        print('  -> Password must be at least ${error.minLength} characters.');
      } else {
        print('  -> Invalid password: ${error.runtimeType}');
      }
    },
    (pass) => print('  -> Password is valid!'),
  );
  print('');

  // 3. Number Example
  print('3. Number Validation');
  final ageConfig = NumberValidationConfig.age(); // Allows 0-150
  
  final validAge = NumberValue('25', config: ageConfig);
  final invalidAgeText = NumberValue('twenty', config: ageConfig);
  final invalidAgeValue = NumberValue('200', config: ageConfig); 

  print('Valid Age: $validAge');
  print('Invalid Age (text): ${invalidAgeText.errorOrNull.runtimeType}');
  print('Invalid Age (value): ${invalidAgeValue.errorOrNull.runtimeType}');
  print('');

  // 4. Text Example
  print('4. Text Validation');
  final usernameConfig = TextValidationConfig.username(); // Letters, numbers, hyphens, underscores
  
  final validText = TextValue('john_doe', config: usernameConfig);
  final invalidText = TextValue('john@doe', config: usernameConfig);
  final tooShortText = TextValue('jo', config: usernameConfig);

  print('Valid Username: ${validText.valueOrNull}');
  print('Invalid Username (format): ${invalidText.errorOrNull.runtimeType}');
  print('Invalid Username (length): ${tooShortText.errorOrNull.runtimeType}');
  print('');
}
