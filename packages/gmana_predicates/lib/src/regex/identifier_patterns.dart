// ignore_for_file: public_member_api_docs

final creditCardReg = RegExp(
  r'^(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|6(?:011|5[0-9][0-9])[0-9]{12}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|(?:2131|1800|35\d{3})\d{11})$',
);
final isbn10MaybeReg = RegExp(r'^(?:[0-9]{9}X|[0-9]{10})$');
final isbn13MaybeReg = RegExp(r'^(?:[0-9]{13})$');

final fqdnTldReg = RegExp(r'^[a-z]{2,}$');
final fqdnLabelReg = RegExp(r'^[a-z¡-￿0-9-]+$', caseSensitive: false);

final Map<String, RegExp> uuidReg = {
  '3': RegExp(
    r'^[0-9A-F]{8}-[0-9A-F]{4}-3[0-9A-F]{3}-[0-9A-F]{4}-[0-9A-F]{12}$',
  ),
  '4': RegExp(
    r'^[0-9A-F]{8}-[0-9A-F]{4}-4[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$',
  ),
  '5': RegExp(
    r'^[0-9A-F]{8}-[0-9A-F]{4}-5[0-9A-F]{3}-[89AB][0-9A-F]{3}-[0-9A-F]{12}$',
  ),
  'all': RegExp(
    r'^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}$',
  ),
};

// Digit-count patterns used by postalCodePatterns below.
final _threeDigit = RegExp(r'^\d{3}$');
final _fourDigit = RegExp(r'^\d{4}$');
final _fiveDigit = RegExp(r'^\d{5}$');
final _sixDigit = RegExp(r'^\d{6}$');

/// Locale-keyed postal code patterns.
final Map<String, RegExp> postalCodePatterns = {
  'AD': RegExp(r'^AD\d{3}$'),

  'AT': _fourDigit,
  'AU': _fourDigit,
  'BE': _fourDigit,
  'BG': _fourDigit,
  'DK': _fourDigit,
  'HU': _fourDigit,
  'LU': _fourDigit,
  'NO': _fourDigit,
  'SI': _fourDigit,
  'TN': _fourDigit,
  'ZA': _fourDigit,

  'CA': RegExp(
    r'^[ABCEGHJKLMNPRSTVXY]\d[ABCEGHJ-NPRSTV-Z][\s\-]?\d[ABCEGHJ-NPRSTV-Z]\d$',
    caseSensitive: false,
  ),

  'CZ': RegExp(r'^\d{3}\s?\d{2}$'),
  'GR': RegExp(r'^\d{3}\s?\d{2}$'),
  'SK': RegExp(r'^\d{3}\s?\d{2}$'),
  'SE': RegExp(r'^\d{3}\s?\d{2}$'),

  'DE': _fiveDigit,
  'DZ': _fiveDigit,
  'EE': _fiveDigit,
  'ES': _fiveDigit,
  'FI': _fiveDigit,
  'IT': _fiveDigit,
  'ID': _fiveDigit,
  'IL': _fiveDigit,
  'IN': _sixDigit,
  'MX': _fiveDigit,
  'PL': RegExp(r'^\d{2}\-\d{3}$'),
  'RO': _sixDigit,
  'RU': _sixDigit,
  'SA': _fiveDigit,
  'UA': _fiveDigit,
  'ZM': _fiveDigit,

  'FR': RegExp(r'^\d{2}\s?\d{3}$'),

  'GB': RegExp(
    r'^(gir\s?0aa|[a-z]{1,2}\d[\da-z]?\s?(\d[a-z]{2})?)$',
    caseSensitive: false,
  ),

  'HR': RegExp(r'^([1-5]\d{4}$)'),

  'IS': _threeDigit,

  'JP': RegExp(r'^\d{3}\-\d{4}$'),

  'KE': _fiveDigit,
  'KM': _fiveDigit,

  'LI': RegExp(r'^(948[5-9]|949[0-7])$'),

  'LT': RegExp(r'^LT\-\d{5}$'),
  'LV': RegExp(r'^LV\-\d{4}$'),

  'NL': RegExp(r'^\d{4}\s?[a-z]{2}$', caseSensitive: false),

  'PT': RegExp(r'^\d{4}\-\d{3}?$'),

  'TW': RegExp(r'^\d{3}(\d{2})?$'),

  'US': RegExp(r'^\d{5}(-\d{4})?$'),
};
