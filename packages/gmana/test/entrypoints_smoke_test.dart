import 'package:gmana/extensions.dart' as extensions;
import 'package:gmana/functional.dart' as functional;
import 'package:gmana/gmana.dart' as gmana;
import 'package:gmana/utilities.dart' as utilities;
import 'package:gmana/validation.dart' as validation;
import 'package:gmana/value_objects.dart' as value_objects;
import 'package:test/test.dart';

void main() {
  test('focused entrypoints expose the curated API surface', () {
    final either = const functional.Right<String, int>(
      21,
    ).map((value) => value * 2);
    const functional.ResultUnit result =
        functional.Right<functional.Failure, functional.Unit>(functional.unit);
    final emailResult = const validation.EmailValidator().validate(
      ' User@Example.com ',
    );
    final emailVo = value_objects.Email('user@example.com');
    final gmanaEmailVo = gmana.Email('user@example.com');


    final debouncer = utilities.Debouncer(milliseconds: 1);
    final throttler = utilities.Throttler(milliseconds: 1);

    expect(either.getRight(), 42);
    expect(
      result,
      const functional.Right<functional.Failure, functional.Unit>(
        functional.unit,
      ),
    );
    expect(extensions.StringX('hello world').toTitleCase, 'Hello World');
    expect(
      extensions.StringValidation('user@example.com').isValidEmail,
      isTrue,
    );
    expect(gmana.StringValidation('user@example.com').isValidEmail, isTrue);
    expect(emailResult.getRight(), 'user@example.com');
    expect(emailVo.value, 'user@example.com');
    expect(gmanaEmailVo.value, 'user@example.com');


    debouncer.dispose();
    throttler.dispose();
  });
}

