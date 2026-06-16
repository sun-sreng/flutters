# Number

```dart
// Untrusted input → Either<NumberError, NumberValue>.
final age = NumberValue.tryParse('25', config: NumberValidationConfig.age());

// Trusted literals → throw ValueObjectException if invalid.
final quantity = NumberValue.fromNum(
  10,
  config: NumberValidationConfig.positiveInteger(),
);
```

| API                                          | Use it for                                                          |
| -------------------------------------------- | ------------------------------------------------------------------- |
| `NumberValue.tryParse(input, config: ...)`   | Validate untrusted numeric text, returning `Either<NumberError, NumberValue>`. |
| `NumberValue.tryParseNum(value, config: ...)`| Validate an existing `num`, returning `Either<NumberError, NumberValue>`.       |
| `NumberValue(input, config: ...)`            | Parse a trusted literal; throws `ValueObjectException` if invalid.  |
| `NumberValue.fromNum(value, config: ...)`    | Build from a trusted `num`; throws if invalid.                      |
| `NumberValidationConfig()`                 | Configure bounds, integer-only mode, negatives, and decimal places. |
| `NumberValidationConfig.age()`             | Human age preset.                                                   |
| `NumberValidationConfig.price()`           | Price preset.                                                       |
| `NumberValidationConfig.rating()`          | Rating preset.                                                      |
| `NumberValidationConfig.percentage()`      | Percentage preset.                                                  |
| `NumberValidationConfig.positiveInteger()` | Positive integer preset.                                            |
| `NumberValidator(config).validate(input)`  | Validate number text without constructing `NumberValue` directly.   |
| `NumberEmpty`                              | Required number input is empty.                                     |
| `NumberInvalidFormat`                      | Input is not numeric.                                               |
| `NumberTooSmall`, `NumberTooLarge`         | Number is outside min/max bounds.                                   |
| `NumberNotInteger`                         | Integer-only config received a decimal.                             |
| `NumberNegativeNotAllowed`                 | Negative value is disallowed.                                       |
| `NumberNotInRange`                         | Number is outside a named range.                                    |
| `NumberDecimalPlacesExceeded`              | Decimal places exceed config.                                       |
