import 'dart:convert';
import 'dart:math';

import 'package:clock/clock.dart';

/// Public API for generating IDs and reversible encodings.
///
/// All methods use Dart's non-cryptographic [Random]. They are safe for
/// database keys, slugs, and display identifiers, but **not** for tokens,
/// session keys, password-reset links, or any value an attacker must not be
/// able to guess. Use [SecureIdGenerator] for those cases.
class IdGenerator {
  static final _IdGeneratorService _service = _IdGeneratorService();

  /// Encodes a list of objects to a Base64 string after JSON serialization.
  ///
  /// This is reversible encoding, not hashing or encryption.
  static String encodeToBase64(List<Object?> objects) {
    return _service.encodeToBase64(objects);
  }

  /// Decodes a Base64 string produced by [encodeToBase64] back to a list.
  ///
  /// Throws [FormatException] if [encoded] is not valid Base64 or the
  /// decoded payload is not a JSON array.
  static List<Object?> decodeFromBase64(String encoded) {
    return _service.decodeFromBase64(encoded);
  }

  /// Generates a nanoid-style random ID.
  ///
  /// Pass a custom [alphabet] to override the default 64-character set.
  /// The [alphabet] must be non-empty.
  static String nanoid({int size = 21, String? alphabet}) {
    return _service.generateNanoid(size: size, alphabet: alphabet);
  }

  /// Generates a random string with configurable character sets.
  static String randomString({
    int length = 8,
    bool useLetters = true,
    bool useNumbers = true,
    bool useSymbols = true,
  }) {
    return _service.generateRandomString(
      length: length,
      useLetters: useLetters,
      useNumbers: useNumbers,
      useSymbols: useSymbols,
    );
  }

  /// Generates a short URL-safe alphanumeric ID (letters + digits, no symbols).
  static String shortId({int length = 8}) {
    return _service.generateShortId(length: length);
  }

  /// Generates a prefixed ID in the style `prefix_xxxx` (e.g. `cus_Xk3mQ9`).
  ///
  /// [prefix] must be non-empty. [length] controls the random suffix length.
  static String prefixed(String prefix, {int length = 16}) {
    return _service.generatePrefixed(prefix, length: length);
  }

  /// Generates a timestamp-based ID with prefix `G`.
  static String timestampId() {
    return _service.generateTimestampId();
  }

  /// Generates a ULID — a 26-character, lexicographically sortable ID.
  ///
  /// The first 10 characters encode the current millisecond timestamp;
  /// the remaining 16 characters are random. Both parts use Crockford
  /// Base32 (`0–9 A–Z` excluding `I L O U`).
  ///
  /// ULIDs generated within the same millisecond sort by their random suffix
  /// only, so order within a millisecond is not guaranteed.
  ///
  /// This uses [Random], so it is not suitable for security-sensitive IDs.
  static String ulid() {
    return _service.generateUlid();
  }

  /// Generates a UUID v4-shaped random ID.
  ///
  /// This uses [Random], so it is not suitable for security-sensitive IDs.
  static String uuidV4Like() {
    return _service.generateUuidV4Like();
  }

  /// Deprecated: delegates to [uuidV4Like].
  ///
  /// The name was misleading — this never generated a standards-compliant
  /// UUID v1 value.
  @Deprecated(
    'Use uuidV4Like() instead. This method will be removed before 1.0.',
  )
  static String uuidV1() {
    return uuidV4Like();
  }
}

// ---------------------------------------------------------------------------

/// Cryptographically-secure variant of [IdGenerator].
///
/// Every method uses [Random.secure()] — backed by the operating-system CSPRNG
/// — making output suitable for tokens, session keys, API keys,
/// password-reset links, and other security-sensitive values.
///
/// For non-security IDs (primary keys, slugs, display codes) prefer
/// [IdGenerator]: it is faster and avoids draining OS entropy unnecessarily.
///
/// **Constant-time comparison**: always compare tokens with [safeEqual] rather
/// than `==` to prevent timing-based side-channel attacks.
class SecureIdGenerator {
  static final _IdGeneratorService _service = _IdGeneratorService(
    random: Random.secure(),
  );

  /// Generates a cryptographically random nanoid-style ID.
  ///
  /// Pass a custom [alphabet] to override the default 64-character set.
  static String nanoid({int size = 21, String? alphabet}) =>
      _service.generateNanoid(size: size, alphabet: alphabet);

  /// Generates a cryptographically random string with configurable character
  /// sets. Suitable for passwords, OTPs, and secret codes.
  static String randomString({
    int length = 8,
    bool useLetters = true,
    bool useNumbers = true,
    bool useSymbols = true,
  }) => _service.generateRandomString(
    length: length,
    useLetters: useLetters,
    useNumbers: useNumbers,
    useSymbols: useSymbols,
  );

  /// Generates a cryptographically random URL-safe alphanumeric ID.
  /// Suitable for invite codes and one-time tokens.
  static String shortId({int length = 8}) =>
      _service.generateShortId(length: length);

  /// Generates a cryptographically random prefixed ID (`prefix_xxxx`).
  /// Suitable for API keys and scoped resource tokens.
  static String prefixed(String prefix, {int length = 16}) =>
      _service.generatePrefixed(prefix, length: length);

  /// Generates a ULID whose random portion uses [Random.secure()].
  ///
  /// The timestamp part is always deterministic (current millisecond); only
  /// the 80-bit random suffix is cryptographically random.
  static String ulid() => _service.generateUlid();

  /// Generates a UUID v4-shaped ID whose bits are from [Random.secure()].
  static String uuidV4Like() => _service.generateUuidV4Like();

  /// Compares two strings in constant time to prevent timing-based attacks.
  ///
  /// The loop always runs `max(a.length, b.length)` iterations regardless of
  /// where the strings first differ, so an attacker cannot learn the correct
  /// value by measuring elapsed time.
  ///
  /// Use this whenever comparing a caller-supplied token against a stored
  /// expected value (API keys, HMAC digests, password-reset tokens, etc.).
  static bool safeEqual(String a, String b) {
    final maxLen = a.length > b.length ? a.length : b.length;
    var diff = a.length ^ b.length;
    for (var i = 0; i < maxLen; i++) {
      final ca = i < a.length ? a.codeUnitAt(i) : 0;
      final cb = i < b.length ? b.codeUnitAt(i) : 0;
      diff |= ca ^ cb;
    }
    return diff == 0;
  }
}

// ---------------------------------------------------------------------------

final class _IdGeneratorService {
  _IdGeneratorService({Random? random}) : _random = random ?? Random();

  final Random _random;

  String encodeToBase64(List<Object?> objects) {
    final payload = json.encode(objects);
    final payloadBytes = utf8.encode(payload);
    return base64.encode(payloadBytes);
  }

  List<Object?> decodeFromBase64(String encoded) {
    final payloadBytes = base64.decode(encoded);
    final payload = utf8.decode(payloadBytes);
    final decoded = json.decode(payload);
    if (decoded is! List) {
      throw FormatException(
        'Expected a JSON array, got ${decoded.runtimeType}',
      );
    }
    return List<Object?>.from(decoded);
  }

  String generateNanoid({int size = 21, String? alphabet}) {
    if (size <= 0) {
      throw ArgumentError.value(size, 'size', 'must be positive');
    }
    if (alphabet != null && alphabet.isEmpty) {
      throw ArgumentError.value(alphabet, 'alphabet', 'must not be empty');
    }
    final chars =
        alphabet ??
        'ModuleSymbhasOwnPr-0123456789ABCDEFGHNRVfgctiUvz_KqYTJkLxpZXIjQW';
    return _IdGeneratorUtils.generateRandomString(
      length: size,
      characters: chars,
      random: _random,
    );
  }

  String generateRandomString({
    int length = 8,
    bool useLetters = true,
    bool useNumbers = true,
    bool useSymbols = true,
  }) {
    if (length <= 0) {
      throw ArgumentError.value(length, 'length', 'must be positive');
    }
    if (!useLetters && !useNumbers && !useSymbols) {
      throw ArgumentError('At least one character set must be enabled');
    }

    var characters = '';
    if (useLetters) characters += _IdGeneratorUtils.alpha;
    if (useNumbers) characters += _IdGeneratorUtils.numbers;
    if (useSymbols) characters += _IdGeneratorUtils.symbols;

    return _IdGeneratorUtils.generateRandomString(
      length: length,
      characters: characters,
      random: _random,
    );
  }

  String generateShortId({int length = 8}) {
    if (length <= 0) {
      throw ArgumentError.value(length, 'length', 'must be positive');
    }
    return _IdGeneratorUtils.generateRandomString(
      length: length,
      characters: _IdGeneratorUtils.alpha + _IdGeneratorUtils.numbers,
      random: _random,
    );
  }

  String generatePrefixed(String prefix, {int length = 16}) {
    if (prefix.isEmpty) {
      throw ArgumentError.value(prefix, 'prefix', 'must not be empty');
    }
    if (length <= 0) {
      throw ArgumentError.value(length, 'length', 'must be positive');
    }
    final suffix = _IdGeneratorUtils.generateRandomString(
      length: length,
      characters: _IdGeneratorUtils.alpha + _IdGeneratorUtils.numbers,
      random: _random,
    );
    return '${prefix}_$suffix';
  }

  String generateTimestampId() {
    final special = 8 + _random.nextInt(4);
    return 'G${clock.now().millisecondsSinceEpoch}-'
        '${_IdGeneratorUtils.printDigits(special, 1)}'
        '${_IdGeneratorUtils.generateBits(_random, 12, 3)}-'
        '${_IdGeneratorUtils.generateBits(_random, 12, 4)}';
  }

  String generateUlid() {
    var ts = clock.now().millisecondsSinceEpoch;

    // 10 Crockford-base32 chars encode 50 bits of timestamp (enough until ~10K AD).
    final tsChars = List<String>.filled(10, '');
    for (var i = 9; i >= 0; i--) {
      tsChars[i] = _IdGeneratorUtils.crockford[ts & 0x1F];
      ts >>= 5;
    }

    // 16 chars of randomness (80 bits).
    final randChars = List<String>.generate(
      16,
      (_) => _IdGeneratorUtils.crockford[_random.nextInt(32)],
    );

    return tsChars.join() + randChars.join();
  }

  String generateUuidV4Like() {
    final special = 8 + _random.nextInt(4);
    return '${_IdGeneratorUtils.generateBits(_random, 16, 4)}'
        '${_IdGeneratorUtils.generateBits(_random, 16, 4)}-'
        '${_IdGeneratorUtils.generateBits(_random, 16, 4)}-'
        '4${_IdGeneratorUtils.generateBits(_random, 12, 3)}-'
        '${_IdGeneratorUtils.printDigits(special, 1)}'
        '${_IdGeneratorUtils.generateBits(_random, 12, 3)}-'
        '${_IdGeneratorUtils.generateBits(_random, 16, 4)}'
        '${_IdGeneratorUtils.generateBits(_random, 16, 4)}'
        '${_IdGeneratorUtils.generateBits(_random, 16, 4)}';
  }
}

// ---------------------------------------------------------------------------

final class _IdGeneratorUtils {
  static const alpha = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const numbers = '0123456789';
  static const symbols = '!@#\$%^&*_-+=';

  /// Crockford Base32 alphabet — 0–9 then A–Z excluding I, L, O, U.
  static const crockford = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';

  static String generateBits(Random random, int bitCount, int digitCount) {
    final value = random.nextInt(1 << bitCount);
    return printDigits(value, digitCount);
  }

  static String generateRandomString({
    required int length,
    required String characters,
    required Random random,
  }) {
    final codeUnits = List.generate(
      length,
      (_) => characters.codeUnitAt(random.nextInt(characters.length)),
    );
    return String.fromCharCodes(codeUnits);
  }

  static String printDigits(int value, int count) {
    return value.toRadixString(16).padLeft(count, '0');
  }
}
