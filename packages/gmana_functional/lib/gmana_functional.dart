/// Pure Dart functional programming primitives.
///
/// Provides [Either], [Left], [Right], result type aliases ([Result],
/// [FutureResult], [StreamResult]), [Failure], [Unit], and [UseCase] /
/// [StreamUseCase] interfaces for clean-architecture use cases.
library;

import 'gmana_functional.dart' show Either, Left, Right, Result, FutureResult, StreamResult, Failure, Unit, UseCase, StreamUseCase;

export 'src/either.dart';
export 'src/left.dart';
export 'src/right.dart';
export 'src/use_case.dart';
