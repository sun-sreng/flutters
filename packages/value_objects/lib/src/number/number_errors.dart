import '../core/validation_error.dart';

sealed class NumberError extends ValidationError {
  const NumberError();
}

final class NumberEmpty extends NumberError {
  const NumberEmpty();
}

final class NumberInvalidFormat extends NumberError {
  const NumberInvalidFormat();
}

final class NumberTooSmall extends NumberError {
  final num currentValue;
  final num minValue;
  
  const NumberTooSmall({
    required this.currentValue,
    required this.minValue,
  });
}

final class NumberTooLarge extends NumberError {
  final num currentValue;
  final num maxValue;
  
  const NumberTooLarge({
    required this.currentValue,
    required this.maxValue,
  });
}

final class NumberNotInteger extends NumberError {
  final num currentValue;
  
  const NumberNotInteger(this.currentValue);
}

final class NumberNegativeNotAllowed extends NumberError {
  final num currentValue;
  
  const NumberNegativeNotAllowed(this.currentValue);
}

final class NumberNotInRange extends NumberError {
  final num currentValue;
  final num minValue;
  final num maxValue;
  
  const NumberNotInRange({
    required this.currentValue,
    required this.minValue,
    required this.maxValue,
  });
}

final class NumberDecimalPlacesExceeded extends NumberError {
  final int currentPlaces;
  final int maxPlaces;
  
  const NumberDecimalPlacesExceeded({
    required this.currentPlaces,
    required this.maxPlaces,
  });
}
