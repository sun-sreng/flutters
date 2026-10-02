// The pre-`lib/src` library paths must keep resolving until they are removed.
import 'package:gmana_predicates/annotations.dart';
import 'package:gmana_predicates/predicates/string_predicates.dart';
import 'package:test/test.dart';

void main() {
  test('deprecated library paths still export their declarations', () {
    expect(isEmail('user@example.com'), isTrue);
    expect(experimental, isA<Experimental>());
  });
}
