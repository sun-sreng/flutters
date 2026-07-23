// ignore_for_file: avoid_print
import 'package:gmana_functional/gmana_functional.dart';

Future<void> main() async {
  final parsed = parsePort(
    '8080',
  ).map((port) => port + 1).flatMap(validatePort);

  print('Either');
  print(
    '  parsed: ${parsed.fold((failure) => failure.message, (port) => port)}',
  );
  print('  fallback: ${parsePort('bad').getOrElse((_) => 3000)}');

  final useCase = GreetingUseCase();
  final greeting = await useCase(const NoParams());

  print('\nUseCase');
  print(
    '  greeting: ${greeting.fold((failure) => failure.message, (value) => value)}',
  );
  print('  unit: $unit');
}

Either<Failure, int> parsePort(String input) {
  final port = int.tryParse(input);
  return port == null
      ? const Left(Failure('Port must be a number', 'invalid_port'))
      : Right(port);
}

Either<Failure, int> validatePort(int port) {
  return port >= 1 && port <= 65535
      ? Right(port)
      : const Left(Failure('Port is out of range', 'port_out_of_range'));
}

class GreetingUseCase implements UseCase<String, NoParams> {
  @override
  FutureResult<String> call(NoParams params) async {
    return const Right<Failure, String>('Hello from a use case');
  }
}
