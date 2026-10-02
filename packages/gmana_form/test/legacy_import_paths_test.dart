// The pre-`lib/src` library paths must keep resolving until they are removed.
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_form/buttons/elevated_button.dart';
import 'package:gmana_form/validators/validators.dart';

void main() {
  test('deprecated library paths still export their declarations', () {
    final button = GSubmitButton.text(
      label: 'Save',
      loading: false,
      onPressed: null,
    );

    expect(button, isA<GSubmitButton>());
    expect(GValidators.required()(''), isNotNull);
  });
}
