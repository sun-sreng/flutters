# Number

```dart
// Untrusted input → Either<NumberValidationIssue, NumberValue>.
final age = NumberValue.tryParse('25', config: NumberValidationConfig.age());

// Trusted literals → throw ValueObjectException if invalid.
final quantity = NumberValue.fromNum(
  10,
  config: NumberValidationConfig.positiveInteger(),
);
```

| API                                          | Use it for                                                          |
| -------------------------------------------- | ------------------------------------------------------------------- |
| `NumberValue.tryParse(input, config: ...)`   | Validate untrusted numeric text, returning `Either<NumberValidationIssue, NumberValue>`. |
| `NumberValue.tryParseNum(value, config: ...)`| Validate an existing `num`, returning `Either<NumberValidationIssue, NumberValue>`.       |
| `NumberValue(input, config: ...)`            | Parse a trusted literal; throws `ValueObjectException` if invalid.  |
| `NumberValue.fromNum(value, config: ...)`    | Build from a trusted `num`; throws if invalid.                      |
| `NumberValidationConfig()`                 | Configure bounds, integer-only mode, negatives, and decimal places. |
| `NumberValidationConfig.age()`             | Human age preset.                                                   |
| `NumberValidationConfig.price()`           | Price preset.                                                       |
| `NumberValidationConfig.rating()`          | Rating preset.                                                      |
| `NumberValidationConfig.percentage()`      | Percentage preset.                                                  |
| `NumberValidationConfig.positiveInteger()` | Positive integer preset.                                            |
| `NumberValidator(config).validate(input)`  | Validate number text without constructing `NumberValue` directly.   |
| `NumberEmptyIssue`                              | Required number input is empty.                                     |
| `NumberInvalidFormatIssue`                      | Input is not numeric.                                               |
| `NumberTooSmallIssue`, `NumberTooLargeIssue`         | Number is outside min/max bounds.                                   |
| `NumberNotIntegerIssue`                         | Integer-only config received a decimal.                             |
| `NumberNegativeNotAllowedIssue`                 | Negative value is disallowed.                                       |
| `NumberDecimalPlacesExceededIssue`              | Decimal places exceed config.                                       |
