import 'date_predicates.dart' as date_p;
import 'identifier_predicates.dart' as id_p;
import 'network_predicates.dart' as net_p;
import 'numeric_predicates.dart' as num_p;
import 'string_predicates.dart' as str_p;

/// Convenient extension methods on nullable [String] values.
extension GmanaNullableStringPredicatesExt on String? {
  /// Returns `true` if this string is `null` or empty.
  bool get isNullOrEmpty => str_p.isNullOrEmpty(this);

  /// Returns `true` if this string is `null`, empty, or whitespace-only.
  bool get isBlank => str_p.isBlank(this);

  /// Returns `true` if this string is not `null` and contains non-whitespace characters.
  bool get isNotBlank => str_p.isNotBlank(this);

  /// Returns `true` if this string is a valid UUID (optional [version]).
  bool isUuid([String? version]) => id_p.isUuid(this, version);

  /// Returns `true` if this string is a valid ISBN-10 or ISBN-13.
  bool isISBN([String? version]) => id_p.isISBN(this, version);

  /// Returns `true` if this string is a valid postal code for [locale].
  bool isPostalCode(String locale, {bool Function()? orElse}) =>
      net_p.isPostalCode(this, locale, orElse: orElse);
}

/// Convenient extension methods on non-null [String] values.
extension GmanaStringPredicatesExt on String {
  /// Returns `true` if this string contains only ASCII alphabetic characters.
  bool get isAlpha => str_p.isAlpha(this);

  /// Returns `true` if this string contains only ASCII alphanumeric characters.
  bool get isAlphaNumeric => str_p.isAlphaNumeric(this);

  /// Returns `true` if this string contains only printable ASCII characters.
  bool get isAscii => str_p.isAscii(this);

  /// Returns `true` if this string is Base64 encoded.
  bool get isBase64 => str_p.isBase64(this);

  /// Returns `true` if this string is a valid email address.
  bool get isEmail => str_p.isEmail(this);

  /// Returns `true` if this string represents a floating-point number.
  bool get isFloat => str_p.isFloat(this);

  /// Returns `true` if this string is valid hexadecimal.
  bool get isHexadecimal => str_p.isHexadecimal(this);

  /// Returns `true` if this string is a valid hex color.
  bool get isHexColor => str_p.isHexColor(this);

  /// Returns `true` if this string represents an integer.
  bool get isInt => str_p.isInt(this);

  /// Returns `true` if this string is valid JSON.
  bool get isJson => str_p.isJson(this);

  /// Returns `true` if this string is entirely lowercase.
  bool get isLowerCase => str_p.isLowerCase(this);

  /// Returns `true` if this string contains only numeric digits.
  bool get isNumeric => str_p.isNumeric(this);

  /// Returns `true` if this string is entirely uppercase.
  bool get isUpperCase => str_p.isUpperCase(this);

  /// Returns `true` if this string is a valid URL slug.
  bool get isSlug => str_p.isSlug(this);

  /// Returns `true` if this string starts with an uppercase letter.
  bool get isCapitalized => str_p.isCapitalized(this);

  /// Returns `true` if this string is in camelCase.
  bool get isCamelCase => str_p.isCamelCase(this);

  /// Returns `true` if this string is in PascalCase.
  bool get isPascalCase => str_p.isPascalCase(this);

  /// Returns `true` if this string is in snake_case.
  bool get isSnakeCase => str_p.isSnakeCase(this);

  /// Returns `true` if this string is in kebab-case.
  bool get isKebabCase => str_p.isKebabCase(this);

  /// Returns `true` if this string matches JWT structure.
  bool get isJwt => str_p.isJwt(this);

  /// Returns `true` if this string is a valid MIME type.
  bool get isMimeType => str_p.isMimeType(this);

  /// Returns `true` if this string is a palindrome.
  bool isPalindrome({
    bool ignoreCase = true,
    bool ignoreNonAlphanumeric = true,
  }) => str_p.isPalindrome(
    this,
    ignoreCase: ignoreCase,
    ignoreNonAlphanumeric: ignoreNonAlphanumeric,
  );

  /// Returns `true` if byte-length is within [`min`, `max`].
  bool isByteLength(int min, [int? max]) => str_p.isByteLength(this, min, max);

  /// Returns `true` if display-length is within [`min`, `max`].
  bool isLength(int min, [int? max]) => str_p.isLength(this, min, max);

  /// Returns `true` if this string contains [seed].
  bool containsSeed(String seed) => str_p.contains(this, seed);

  /// Returns `true` if this string contains [seed], ignoring case.
  bool containsIgnoreCase(String seed) => str_p.containsIgnoreCase(this, seed);

  /// Returns `true` if this string matches regex [pattern].
  bool matches(String pattern) => str_p.matches(this, pattern);

  /// Returns `true` if this string is a valid hash for [algorithm].
  bool isHash(String algorithm) => str_p.isHash(this, algorithm);

  // Identifier predicates

  /// Returns `true` if this string is a valid credit card number.
  bool get isCreditCard => id_p.isCreditCard(this);

  /// Returns `true` if this string is a valid MongoId.
  bool get isMongoId => id_p.isMongoId(this);

  /// Returns `true` if this string is a valid Semantic Version.
  bool get isSemVer => id_p.isSemVer(this);

  /// Returns `true` if this string passes Luhn validation.
  bool get isLuhnValid => id_p.isLuhnValid(this);

  /// Returns `true` if this string is a valid IMEI number.
  bool get isIMEI => id_p.isIMEI(this);

  /// Returns `true` if this string is a valid ULID.
  bool get isULID => id_p.isULID(this);

  /// Returns `true` if this string is a valid EAN-8 or EAN-13 barcode.
  bool isEAN([String? version]) => id_p.isEAN(this, version);

  /// Returns `true` if this string matches a Nano ID format.
  bool isNanoId([int expectedLength = 21]) =>
      id_p.isNanoId(this, expectedLength);

  /// Returns `true` if this string is a valid phone number.
  bool isPhoneNumber({bool requirePlusPrefix = false}) =>
      id_p.isPhoneNumber(this, requirePlusPrefix: requirePlusPrefix);

  /// Returns `true` if this string is a valid FQDN.
  bool isFQDN({bool requireTld = true, bool allowUnderscores = false}) => id_p
      .isFQDN(this, requireTld: requireTld, allowUnderscores: allowUnderscores);

  // Network predicates

  /// Returns `true` if this string is a valid IPv4 address.
  bool get isIpv4 => net_p.isIpv4(this);

  /// Returns `true` if this string is a valid IPv6 address.
  bool get isIpv6 => net_p.isIpv6(this);

  /// Returns `true` if this string is a valid MAC address.
  bool get isMacAddress => net_p.isMacAddress(this);

  /// Returns `true` if this string is a valid network port number.
  bool get isPort => net_p.isPort(this);

  /// Returns `true` if this string is a valid Data URI.
  bool get isDataURI => net_p.isDataURI(this);

  /// Returns `true` if this string is a valid Magnet URI.
  bool get isMagnetURI => net_p.isMagnetURI(this);

  /// Returns `true` if this string is a valid IP address.
  bool isIP([int? version]) => net_p.isIP(this, version);

  /// Returns `true` if this string is a valid CIDR notation.
  bool isCidr([int? version]) => net_p.isCidr(this, version);

  /// Returns `true` if this string is a valid URL.
  bool isUrl({Set<String>? allowedSchemes, bool requireHost = true}) => net_p
      .isUrl(this, allowedSchemes: allowedSchemes, requireHost: requireHost);

  // Numeric predicates

  /// Returns `true` if this string represents an even integer.
  bool get isEven => num_p.isEven(this);

  /// Returns `true` if this string represents an odd integer.
  bool get isOdd => num_p.isOdd(this);

  /// Returns `true` if this string numeric value is positive (> 0).
  bool get isPositive => num_p.isPositive(this);

  /// Returns `true` if this string numeric value is negative (< 0).
  bool get isNegative => num_p.isNegative(this);

  /// Returns `true` if this string numeric value is zero.
  bool get isZero => num_p.isZero(this);

  /// Returns `true` if this string represents a prime integer.
  bool get isPrimeString => num_p.isPrimeString(this);

  /// Returns `true` if this numeric string is divisible by [n].
  bool isDivisibleBy(String n) => num_p.isDivisibleBy(this, n);

  /// Returns `true` if this numeric string value is within [`min`, `max`].
  bool isInRange(num min, num max) => num_p.isInRange(this, min, max);

  // Date predicates

  /// Returns `true` if this string is a parseable date.
  bool get isDate => date_p.isDate(this);

  /// Returns `true` if this string represents today's date.
  bool get isToday => date_p.isToday(this);

  /// Returns `true` if this string represents a date in the past.
  bool get isPast => date_p.isPast(this);

  /// Returns `true` if this string represents a date in the future.
  bool get isFuture => date_p.isFuture(this);

  /// Returns `true` if this date string falls on a weekend.
  bool get isWeekend => date_p.isWeekend(this);

  /// Returns `true` if this date string falls on a weekday.
  bool get isWeekday => date_p.isWeekday(this);

  /// Returns `true` if this date string falls in a leap year.
  bool get isLeapYear => date_p.isLeapYear(this);

  /// Returns `true` if this string matches 24-hour time format.
  bool get isTime => date_p.isTime(this);

  /// Returns `true` if this date string is after [reference].
  bool isAfter([String? reference]) => date_p.isAfter(this, reference);

  /// Returns `true` if this date string is before [reference].
  bool isBefore([String? reference]) => date_p.isBefore(this, reference);

  /// Returns `true` if this date string is between [from] and [to].
  bool isBetween(String from, String to) => date_p.isBetween(this, from, to);

  /// Returns `true` if this date string shares the same day as [comparisonDate].
  bool isSameDay(String comparisonDate) =>
      date_p.isSameDay(this, comparisonDate);

  /// Returns `true` if this date string shares the same month as [comparisonDate].
  bool isSameMonth(String comparisonDate) =>
      date_p.isSameMonth(this, comparisonDate);

  /// Returns `true` if this date string shares the same year as [comparisonDate].
  bool isSameYear(String comparisonDate) =>
      date_p.isSameYear(this, comparisonDate);

  // Case & character sets

  /// Returns `true` if this string is in SCREAMING_SNAKE_CASE.
  bool get isScreamingSnakeCase => str_p.isScreamingSnakeCase(this);

  /// Returns `true` if this string is in Title Case.
  bool get isTitleCase => str_p.isTitleCase(this);

  /// Returns `true` if this string contains only binary digits.
  bool get isBinary => str_p.isBinary(this);

  /// Returns `true` if this string contains only octal digits.
  bool get isOctal => str_p.isOctal(this);

  /// Returns `true` if this string is Base32 encoded.
  bool get isBase32 => str_p.isBase32(this);

  /// Returns `true` if this string contains only printable ASCII.
  bool get isPrintable => str_p.isPrintable(this);

  /// Returns `true` if this string contains at least one whitespace character.
  bool get hasWhitespace => str_p.hasWhitespace(this);

  /// Returns `true` if this string contains full-width Unicode characters.
  bool get isFullWidth => str_p.isFullWidth(this);

  /// Returns `true` if this string contains half-width Unicode characters.
  bool get isHalfWidth => str_p.isHalfWidth(this);

  /// Returns `true` if this string contains non-ASCII characters.
  bool get isMultiByte => str_p.isMultiByte(this);

  /// Returns `true` if this string contains surrogate pairs.
  bool get isSurrogatePair => str_p.isSurrogatePair(this);

  /// Returns `true` if this string mixes full-width and half-width characters.
  bool get isVariableWidth => str_p.isVariableWidth(this);

  // Colors & geography

  /// Returns `true` if this string is a CSS `rgb()`/`rgba()` color.
  bool get isRgbColor => str_p.isRgbColor(this);

  /// Returns `true` if this string is a CSS `hsl()`/`hsla()` color.
  bool get isHslColor => str_p.isHslColor(this);

  /// Returns `true` if this string is a latitude in -90..90.
  bool get isLatitude => str_p.isLatitude(this);

  /// Returns `true` if this string is a longitude in -180..180.
  bool get isLongitude => str_p.isLongitude(this);

  /// Returns `true` if this string is a `latitude,longitude` pair.
  bool get isLatLong => str_p.isLatLong(this);

  /// Returns `true` if this string is an anagram of [other].
  bool isAnagram(
    String other, {
    bool ignoreCase = true,
    bool ignoreNonAlphanumeric = true,
  }) => str_p.isAnagram(
    this,
    other,
    ignoreCase: ignoreCase,
    ignoreNonAlphanumeric: ignoreNonAlphanumeric,
  );

  /// Returns `true` if this string is a decimal number, optionally with
  /// exactly [places] digits after the point.
  bool isDecimal({int? places}) => str_p.isDecimal(this, places: places);

  /// Returns `true` if this string meets every enabled strength requirement.
  bool isStrongPassword({
    int minLength = 8,
    int? maxLength,
    bool requireUppercase = true,
    bool requireLowercase = true,
    bool requireDigit = true,
    bool requireSpecial = true,
    bool allowWhitespace = false,
  }) => str_p.isStrongPassword(
    this,
    minLength: minLength,
    maxLength: maxLength,
    requireUppercase: requireUppercase,
    requireLowercase: requireLowercase,
    requireDigit: requireDigit,
    requireSpecial: requireSpecial,
    allowWhitespace: allowWhitespace,
  );

  // Identifiers

  /// Returns `true` if this string is a valid IBAN (mod-97 checksum).
  bool get isIban => id_p.isIban(this);

  /// Returns `true` if this string is a valid BIC/SWIFT code.
  bool get isBic => id_p.isBic(this);

  // Network

  /// Returns `true` if this string is a private IPv4 address (RFC 1918).
  bool get isPrivateIpv4 => net_p.isPrivateIpv4(this);

  /// Returns `true` if this string is an IPv4 loopback address.
  bool get isLoopbackIpv4 => net_p.isLoopbackIpv4(this);

  /// Returns `true` if this string is a publicly routable IPv4 address.
  bool get isPublicIpv4 => net_p.isPublicIpv4(this);

  /// Returns `true` if this string is a valid hostname.
  bool get isHostname => net_p.isHostname(this);

  // Dates

  /// Returns `true` if this date string represents yesterday (UTC).
  bool get isYesterday => date_p.isYesterday(this);

  /// Returns `true` if this date string represents tomorrow (UTC).
  bool get isTomorrow => date_p.isTomorrow(this);

  /// Returns `true` if this string is a full ISO 8601 date or date-time.
  bool get isIso8601 => date_p.isIso8601(this);

  /// Returns `true` if this date string is the first day of its month.
  bool get isStartOfMonth => date_p.isStartOfMonth(this);

  /// Returns `true` if this date string is the last day of its month.
  bool get isEndOfMonth => date_p.isEndOfMonth(this);

  /// Returns `true` if this date string shares a Monday-start week with
  /// [comparisonDate].
  bool isSameWeek(String comparisonDate) =>
      date_p.isSameWeek(this, comparisonDate);

  /// Returns `true` if this date is in the past and no older than [duration].
  bool isWithinLast(Duration duration) => date_p.isWithinLast(this, duration);

  /// Returns `true` if this date is in the future and within [duration].
  bool isWithinNext(Duration duration) => date_p.isWithinNext(this, duration);

  /// Returns `true` if this birth date means an age of at least [years].
  bool isAgeAtLeast(int years) => date_p.isAgeAtLeast(this, years);
}

/// Convenient extension methods on [DateTime] values.
extension GmanaDateTimePredicatesExt on DateTime {
  /// Returns `true` if this DateTime falls on a Saturday or Sunday.
  bool get isWeekend =>
      weekday == DateTime.saturday || weekday == DateTime.sunday;

  /// Returns `true` if this DateTime falls on a Monday–Friday.
  bool get isWeekday =>
      weekday >= DateTime.monday && weekday <= DateTime.friday;

  /// Returns `true` if this DateTime falls in a leap year.
  bool get isLeapYear =>
      (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);

  /// Returns `true` if this DateTime matches today's UTC date.
  bool get isToday {
    final now = DateTime.now().toUtc();
    final utcDate = toUtc();
    return utcDate.year == now.year &&
        utcDate.month == now.month &&
        utcDate.day == now.day;
  }
}
