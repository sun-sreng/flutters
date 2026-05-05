# Number

```dart
final age = NumberValue('25', config: NumberValidationConfig.age());
final quantity = NumberValue.fromNum(
  10,
  config: NumberValidationConfig.positiveInteger(),
);
```

| API                                        | Use it for                                                          |
| ------------------------------------------ | ------------------------------------------------------------------- |
| `NumberValue(input, config: ...)`          | Parse and validate numeric text.                                    |
| `NumberValue.fromNum(value, config: ...)`  | Validate an existing `num`.                                         |
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
