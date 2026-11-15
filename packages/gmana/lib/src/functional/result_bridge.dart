import 'dart:async';

import 'either.dart';
import 'g_result.dart';
import 'left.dart';
import 'right.dart';

/// Extension methods to convert [Either] into [GResult] / [GResult].
extension GmanaEitherToResultX<L, R> on Either<L, R> {
  /// Converts this [Either] to a [GResult], mapping [Left] to [GFailure] and [Right] to [GSuccess].
  GResult<R, L> toResult() {
    return fold(GResult.failure, GResult.success);
  }
}

/// Extension methods to convert [GResult] into [Either].
extension GmanaResultToEitherX<T, E> on GResult<T, E> {
  /// Converts this [GResult] to an [Either], mapping [GSuccess] to [Right] and [GFailure] to [Left].
  Either<E, T> toEither() => switch (this) {
    GSuccess(:final value) => Right(value),
    GFailure(:final error) => Left(error),
  };
}

/// Extension methods to convert asynchronous [Future<Either>] into [Future<GResult>].
extension GmanaFutureEitherToResultX<L, R> on Future<Either<L, R>> {
  /// Awaits this future and converts the resulting [Either] to a [GResult].
  Future<GResult<R, L>> toResultAsync() async {
    final either = await this;
    return either.toResult();
  }
}

/// Extension methods to convert asynchronous [Future<GResult>] into [Future<Either>].
extension GmanaFutureResultToEitherX<T, E> on Future<GResult<T, E>> {
  /// Awaits this future and converts the resulting [GResult] to an [Either].
  Future<Either<E, T>> toEitherAsync() async {
    final result = await this;
    return result.toEither();
  }
}
