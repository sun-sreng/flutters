# Money Value Object

`Money` is an ecommerce-focused value object for prices, totals, discounts,
taxes, refunds, installment plans, and payment API payloads.

It stores money as an integer count of minor units, paired with a `Currency`
enum. For USD, `1999` means `$19.99`; for JPY, `500` means `¥500`; for KWD,
`3500` means `KD 3.500`.

```dart
import 'package:gmana_value_objects/gmana_value_objects.dart';
```

```dart
final price = Money.fromDecimalString('19.99', Currency.usd);
final localPrice = Money.fromDecimalString('1200', Currency.khr);
const exactPrice = Money(minorUnits: 1234, currency: Currency.usd);

final lineTotal = price * 3;
final discounted = lineTotal.applyDiscountPercent(15);
```

| API                                               | Use it for                                                              |
| ------------------------------------------------- | ----------------------------------------------------------------------- |
| `Money(minorUnits: ..., currency: ...)`           | Create money from exact minor units, such as cents.                     |
| `Money.zero(currency)`                            | Create a zero amount for accumulators.                                  |
| `Money.ofMajor(major, minor, currency)`           | Create money from major and minor parts.                                |
| `Money.fromDecimalString(value, currency)`        | Parse customer/admin decimal text.                                      |
| `Money.fromNum(value, currency)`                  | Create from a numeric decimal value using half-up rounding.             |
| `Currency.fromCode(code)`                         | Resolve a supported ISO currency code.                                  |
| `MoneyAmount`                                     | Read validated `amount`, `currency`, `minorUnits`, and `decimalDigits`. |
| `MoneyValidationConfig()`                         | Configure default currency, allowed currencies, limits, and separators. |
| `MoneyValidationConfig.usd()`                     | USD-only, non-negative money with two decimal places.                   |
| `MoneyValidationConfig.khr()`                     | KHR-only, non-negative money with zero decimal places.                  |
| `MoneyValidationConfig.commonCurrencies()`        | USD, EUR, and KHR non-negative money.                                   |
| `MoneyValidationConfig.ecommerce()`               | Common ecommerce currencies with currency-aware decimal digits.         |
| `MoneyValidator(config).validate(input)`          | Validate money text without constructing `Money` directly.              |
| `MoneyValidator.validateMinorUnits(value)`        | Validate an exact minor-unit value without decimal parsing.             |
| `Money` operators `+`, `-`, `*`, comparisons      | Same-currency arithmetic and comparison using exact minor units.        |
| `Money.applyPercent(percent)`                     | Calculate tax, discount, or rate amounts.                               |
| `Money.applyDiscountPercent(percent)`             | Apply percentage discounts rounded to the nearest minor unit.           |
| `Money.allocate(ratios)`                          | Split payments/refunds/tax while preserving the original total exactly. |
| `Iterable<Money>.sum(emptyCurrency: ...)`         | Sum cart line totals.                                                   |
| `formatted`, `formattedWithCode`, `decimalString` | Deterministic display/API strings.                                      |
| `MoneyEmpty`                                      | Required money input is empty.                                          |
| `MoneyInvalidFormat`                              | Input is not a plain decimal amount.                                    |
| `MoneyNegativeNotAllowed`                         | Negative money is disallowed.                                           |
| `MoneyDecimalPlacesExceeded`                      | Decimal places exceed config.                                           |
| `MoneyInvalidCurrency`                            | Currency is not a three-letter code.                                    |
| `MoneyUnsupportedCurrency`                        | Currency is outside the configured allowed set.                         |
| `MoneyTooSmall`, `MoneyTooLarge`                  | Minor-unit amount is outside configured limits.                         |

## Why Minor Units

Do not store money as floating-point values in domain models. Floating-point
numbers cannot represent many decimal fractions exactly, so values like `0.1`
and `0.2` can produce rounding artifacts.

`Money` uses exact integer minor units for all authoritative arithmetic:

```dart
const price = Money(minorUnits: 1999, currency: Currency.usd); // $19.99
const yen = Money(minorUnits: 500, currency: Currency.jpy); // ¥500
const kwd = Money(minorUnits: 3500, currency: Currency.kwd); // KD 3.500
```

## Supported Currencies

| Currency       | Decimal places | Symbol | Example    |
| -------------- | -------------: | ------ | ---------- |
| `Currency.usd` |              2 | `$`    | `$19.99`   |
| `Currency.eur` |              2 | `€`    | `€19.99`   |
| `Currency.gbp` |              2 | `£`    | `£19.99`   |
| `Currency.jpy` |              0 | `¥`    | `¥500`     |
| `Currency.khr` |              0 | `៛`    | `៛4000`    |
| `Currency.idr` |              0 | `Rp`   | `Rp 50000` |
| `Currency.kwd` |              3 | `KD`   | `KD 3.500` |
| `Currency.bhd` |              3 | `BD`   | `BD 1.500` |
| `Currency.thb` |              2 | `฿`    | `฿199.00`  |
| `Currency.myr` |              2 | `RM`   | `RM 19.99` |
| `Currency.vnd` |              0 | `₫`    | `₫199000`  |
| `Currency.krw` |              0 | `₩`    | `₩1200`    |
| `Currency.aud` |              2 | `A$`   | `A$ 19.99` |
| `Currency.cad` |              2 | `C$`   | `C$ 19.99` |
| `Currency.cny` |              2 | `¥`    | `¥19.99`   |
| `Currency.sgd` |              2 | `S$`   | `S$ 19.99` |

Lookup by ISO code:

```dart
final currency = Currency.fromCode('USD'); // Currency.usd
final unknown = Currency.fromCode('XXX'); // null
```

## Constructors

### Minor Units

Use the primary constructor when an API or database already stores amounts in
minor units.

```dart
const price = Money(minorUnits: 1999, currency: Currency.usd);
const jpy = Money(minorUnits: 500, currency: Currency.jpy);
const kwd = Money(minorUnits: 3500, currency: Currency.kwd);
```

### Zero

Use `Money.zero` as an accumulator default.

```dart
var subtotal = Money.zero(Currency.usd);

for (final item in cartItems) {
  subtotal += item.lineTotal;
}
```

### Major And Minor Parts

Use `Money.ofMajor` when you have whole units and minor units separately.

```dart
final price = Money.ofMajor(19, 99, Currency.usd); // $19.99
final rent = Money.ofMajor(1200, 0, Currency.gbp); // £1200.00
final kwd = Money.ofMajor(3, 500, Currency.kwd); // KD 3.500
```

The minor part must be in range for the currency. USD minor units must be
`0..99`, while KWD minor units must be `0..999`.

### Decimal Strings

Use `Money.fromDecimalString` for form input or external decimal text.

```dart
Money.fromDecimalString('19.99', Currency.usd); // 1999
Money.fromDecimalString('19.9', Currency.usd); // 1990
Money.fromDecimalString('19', Currency.usd); // 1900
Money.fromDecimalString('500', Currency.jpy); // 500
Money.fromDecimalString('3.500', Currency.kwd); // 3500
```

The parser pads missing minor digits and rejects extra minor digits beyond the
currency precision. Invalid input throws `FormatException`.

```dart
try {
  final price = Money.fromDecimalString(priceController.text, Currency.usd);
  submit(price);
} on FormatException catch (error) {
  showValidationError(error.message);
}
```

### Numeric Values

Use `Money.fromNum` only when a numeric decimal value is already unavoidable.
It converts to minor units with half-up rounding.

```dart
final price = Money.fromNum(19.99, Currency.usd);
```

## Arithmetic

All arithmetic enforces same-currency values. Mixing currencies throws
`ArgumentError`.

```dart
const price = Money(minorUnits: 1999, currency: Currency.usd);
const tax = Money(minorUnits: 160, currency: Currency.usd);

final total = price + tax; // $21.59
```

Subtraction also rejects negative results. Use `canSubtract` before refunds or
discount caps.

```dart
if (orderTotal.canSubtract(refundAmount)) {
  final remaining = orderTotal - refundAmount;
}
```

## Quantity And Rates

Multiplication accepts `num` and uses half-up rounding.

```dart
const unitPrice = Money(minorUnits: 999, currency: Currency.usd);

final lineTotal = unitPrice * 3; // $29.97
final converted = unitPrice * 1.08; // rounded to nearest cent
```

## Percentages

Use `applyPercent` when you need a percentage amount, such as tax.

```dart
const price = Money(minorUnits: 10000, currency: Currency.usd); // $100.00

final tax = price.applyPercent(7); // $7.00
final discount = price.applyPercent(10); // $10.00
final total = price + tax - discount; // $97.00
```

Use `applyDiscountPercent` when you need the discounted final price.

```dart
final discounted = price.applyDiscountPercent(15); // $85.00
```

## Allocation

`allocate` splits an amount across ratios without losing minor units. Remainders
are distributed one minor unit at a time from the front.

Use it for split payments, line-item tax distribution, refunds, and installment
plans.

```dart
final parts = const Money(minorUnits: 1000, currency: Currency.usd)
    .allocate([1, 1, 1]);

print(parts.map((part) => part.formatted).toList());
// [$3.34, $3.33, $3.33]
```

Ratio examples:

```dart
final taxAndNet = gross.allocate([15, 85]);
final installments = total.allocate([1, 1, 1]);
```

## Comparison

Comparison operators require the same currency.

```dart
const freeShippingThreshold = Money(
  minorUnits: 5000,
  currency: Currency.usd,
);

if (cartSubtotal >= freeShippingThreshold) {
  applyFreeShipping();
}

final appliedDiscount = discount.min(cartSubtotal);

prices.sort();
```

## Formatting

Formatting is deterministic and uses currency metadata. It does not require a
locale.

```dart
const price = Money(minorUnits: 1999, currency: Currency.usd);

print(price.formatted); // $19.99
print(price.formattedWithCode); // USD 19.99
print(price.decimalString); // 19.99
print(price.toString()); // USD 19.99
```

Zero-decimal and three-decimal currencies format according to currency
precision:

```dart
const yen = Money(minorUnits: 500, currency: Currency.jpy);
const kwd = Money(minorUnits: 3500, currency: Currency.kwd);

print(yen.formatted); // ¥500
print(yen.decimalString); // 500
print(kwd.formatted); // KD 3.500
```

## Summing Lists

Use the iterable extension to sum cart or order line totals.

```dart
final subtotal = cartItems
    .map((item) => item.unitPrice * item.quantity)
    .sum(emptyCurrency: Currency.usd);

final empty = <Money>[].sum(emptyCurrency: Currency.usd); // $0.00
```

All non-empty items must use the same currency.

## Validation API

`Money` constructors throw for invalid input. If you need `Either`-style
validation for forms or domain pipelines, use `MoneyValidator`.

```dart
final result = MoneyValidator(MoneyValidationConfig.ecommerce())
    .validate('1,234.56', currency: 'USD');

result.fold(
  (error) => print(DefaultValidationErrorMessages().getMessage(error)),
  (amount) => print(amount.formattedWithCode),
);
```

Common validation errors:

| Error                        | Meaning                                            |
| ---------------------------- | -------------------------------------------------- |
| `MoneyEmpty`                 | Required money input is empty.                     |
| `MoneyInvalidFormat`         | Input is not a plain decimal amount.               |
| `MoneyNegativeNotAllowed`    | Negative money is disallowed.                      |
| `MoneyDecimalPlacesExceeded` | Decimal places exceed currency precision.          |
| `MoneyInvalidCurrency`       | Currency code is malformed or unsupported.         |
| `MoneyUnsupportedCurrency`   | Currency is outside the configured allowed set.    |
| `MoneyTooSmall`              | Minor-unit amount is below the configured minimum. |
| `MoneyTooLarge`              | Minor-unit amount is above the configured maximum. |

## DTO Mapping

Keep serialization in DTOs, not in the value object.

```dart
class ProductDto {
  final int priceInCents;
  final String currency;

  const ProductDto({
    required this.priceInCents,
    required this.currency,
  });

  Product toDomain() {
    return Product(
      price: Money(
        minorUnits: priceInCents,
        currency: Currency.fromCode(currency) ?? Currency.usd,
      ),
    );
  }
}
```

## Cart Example

```dart
class CartItem {
  final Money unitPrice;
  final int quantity;

  const CartItem({required this.unitPrice, required this.quantity});

  Money get lineTotal => unitPrice * quantity;
}

final items = [
  CartItem(
    unitPrice: Money.fromDecimalString('19.99', Currency.usd),
    quantity: 2,
  ),
  CartItem(
    unitPrice: Money.fromDecimalString('5.00', Currency.usd),
    quantity: 1,
  ),
];

final subtotal = items
    .map((item) => item.lineTotal)
    .sum(emptyCurrency: Currency.usd);
final total = subtotal.applyDiscountPercent(10);

print(total.formatted); // $40.48
```
