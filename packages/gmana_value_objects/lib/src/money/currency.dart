/// Supported ISO 4217 currencies for ecommerce money values.
enum Currency {
  /// United States dollar.
  usd('USD', 2, r'$'),

  /// Euro.
  eur('EUR', 2, '€'),

  /// British pound sterling.
  gbp('GBP', 2, '£'),

  /// Japanese yen.
  jpy('JPY', 0, '¥'),

  /// Cambodian riel.
  khr('KHR', 0, '៛'),

  /// Indonesian rupiah.
  idr('IDR', 0, 'Rp'),

  /// Kuwaiti dinar.
  kwd('KWD', 3, 'KD'),

  /// Bahraini dinar.
  bhd('BHD', 3, 'BD'),

  /// Thai baht.
  thb('THB', 2, '฿'),

  /// Malaysian ringgit.
  myr('MYR', 2, 'RM'),

  /// Vietnamese dong.
  vnd('VND', 0, '₫'),

  /// South Korean won.
  krw('KRW', 0, '₩'),

  /// Australian dollar.
  aud('AUD', 2, r'A$'),

  /// Canadian dollar.
  cad('CAD', 2, r'C$'),

  /// Chinese yuan.
  cny('CNY', 2, '¥'),

  /// Singapore dollar.
  sgd('SGD', 2, r'S$');

  /// Creates a [Currency] with ISO metadata.
  const Currency(this.code, this.decimalPlaces, this.symbol);

  /// ISO 4217 currency code.
  final String code;

  /// Number of decimal places used by the currency.
  final int decimalPlaces;

  /// Display symbol for deterministic formatting.
  final String symbol;

  /// Minor-unit scale, such as 100 for USD or 1 for JPY.
  int get subunitFactor {
    var factor = 1;
    for (var i = 0; i < decimalPlaces; i++) {
      factor *= 10;
    }
    return factor;
  }

  /// Looks up a currency by ISO code.
  static Currency? fromCode(String code) {
    final normalizedCode = code.trim().toUpperCase();
    for (final currency in Currency.values) {
      if (currency.code == normalizedCode) {
        return currency;
      }
    }

    return null;
  }
}
