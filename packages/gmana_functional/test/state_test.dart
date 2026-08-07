import 'package:gmana_functional/gmana_functional.dart';
import 'package:test/test.dart';

void main() {
  group('State monad', () {
    test('get, set, modify, map, flatMap', () {
      final increment = State.get<int>().flatMap(
        (val) => State.set(val + 1).map((_) => 'incremented from $val'),
      );

      final (msg, finalState) = increment.run(10);
      expect(msg, equals('incremented from 10'));
      expect(finalState, equals(11));

      expect(increment.evalState(10), equals('incremented from 10'));
      expect(increment.execState(10), equals(11));

      final doubleState = State.modify<int>((s) => s * 2);
      expect(doubleState.execState(5), equals(10));
    });
  });
}
