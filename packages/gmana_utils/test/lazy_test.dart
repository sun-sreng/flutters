import 'package:gmana_utils/gmana_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Lazy and ResettableLazy', () {
    test('Lazy evaluates only on demand and caches value', () {
      var evaluations = 0;
      final lazy = Lazy(() {
        evaluations++;
        return 42;
      });

      expect(lazy.isInitialized, isFalse);
      expect(evaluations, 0);

      expect(lazy.value, 42);
      expect(lazy.isInitialized, isTrue);
      expect(evaluations, 1);

      expect(lazy(), 42);
      expect(evaluations, 1);
    });

    test('ResettableLazy can be invalidated and re-evaluated', () {
      var evaluations = 0;
      final lazy = ResettableLazy(() {
        evaluations++;
        return 'eval_$evaluations';
      });

      expect(lazy.value, 'eval_1');
      expect(lazy.value, 'eval_1');
      expect(evaluations, 1);

      lazy.reset();
      expect(lazy.isInitialized, isFalse);

      expect(lazy.value, 'eval_2');
      expect(evaluations, 2);
    });
  });
}
