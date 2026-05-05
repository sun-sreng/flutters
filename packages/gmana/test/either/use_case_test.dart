import 'package:gmana/gmana.dart';
import 'package:test/test.dart';

void main() {
  group('use case helpers', () {
    test('Failure has a clean default message and value semantics', () {
      expect(const Failure(), const Failure('An unexpected error occurred.'));
      expect(const Failure('boom'), const Failure('boom'));
      expect(
        const Failure('boom', 'network', {'retryable': true}),
        const Failure('boom', 'network', {'retryable': true}),
      );
      expect(
        const Failure('boom', 'network', {'retryable': true}),
        isNot(const Failure('boom', 'auth', {'retryable': true})),
      );
      expect(
        const Failure('boom', 'network', {'retryable': true}),
        isNot(const Failure('boom', 'network', {'retryable': false})),
      );
      expect(const Failure('boom').hashCode, const Failure('boom').hashCode);
      expect(const Failure('boom').toString(), 'Failure(message: boom)');
      expect(
        const Failure('boom', 'network', {'retryable': true}).toString(),
        'Failure(message: boom, code: network, details: {retryable: true})',
      );
    });

    test('NoParams behaves like a value marker', () {
      expect(const NoParams(), const NoParams());
      expect(const NoParams().hashCode, const NoParams().hashCode);
      expect(const NoParams().toString(), 'NoParams()');
    });

    test('unit is a stable singleton-style value', () {
      expect(unit, isA<Unit>());
      expect(unit, equals(unit));
      expect(unit.toString(), '()');
    });

    test('UseCase can be implemented with the shared typedefs', () async {
      const params = NoParams();
      final useCase = _GreetingUseCase();

      expect(await useCase(params), const Right<Failure, String>('hello'));
    });

    test('StreamUseCase can emit fallible stream values', () async {
      const params = NoParams();
      final useCase = _CounterUseCase();

      expect(
        useCase(params),
        emitsInOrder([
          const Right<Failure, int>(1),
          const Left<Failure, int>(Failure('stopped', 'counter')),
          emitsDone,
        ]),
      );
    });
  });
}

class _GreetingUseCase implements UseCase<String, NoParams> {
  @override
  FutureEither<String> call(NoParams params) async {
    return const Right<Failure, String>('hello');
  }
}

class _CounterUseCase implements StreamUseCase<int, NoParams> {
  @override
  StreamEither<int> call(NoParams params) async* {
    yield const Right<Failure, int>(1);
    yield const Left<Failure, int>(Failure('stopped', 'counter'));
  }
}
