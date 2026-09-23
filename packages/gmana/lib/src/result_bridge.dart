import 'dart:async';

import 'package:gmana_functional/gmana_functional.dart' hide Failure, Result;
import 'package:gmana_utils/gmana_utils.dart';

/// Extension methods to convert [Either] into [Result] / [GResult].
extension GmanaEitherToResultX<L, R> on Either<L, R> {
  /// Converts this [Either] to a [Result], mapping [Left] to [Failure] and [Right] to [Success].
  Result<R, L> toResult() {
    return fold(Result.failure, Result.success);
  }
}

/// Extension methods to convert [Result] into [Either].
extension GmanaResultToEitherX<T, E> on Result<T, E> {
  /// Converts this [Result] to an [Either], mapping [Success] to [Right] and [Failure] to [Left].
  Either<E, T> toEither() => switch (this) {
    Success(:final value) => Right(value),
    Failure(:final error) => Left(error),
  };
}

/// Extension methods to convert asynchronous [Future<Either>] into [Future<Result>].
extension GmanaFutureEitherToResultX<L, R> on Future<Either<L, R>> {
  /// Awaits this future and converts the resulting [Either] to a [Result].
  Future<Result<R, L>> toResultAsync() async {
    final either = await this;
    return either.toResult();
  }
}

/// Extension methods to convert asynchronous [Future<Result>] into [Future<Either>].
extension GmanaFutureResultToEitherX<T, E> on Future<Result<T, E>> {
  /// Awaits this future and converts the resulting [Result] to an [Either].
  Future<Either<E, T>> toEitherAsync() async {
    final result = await this;
    return result.toEither();
  }
}
