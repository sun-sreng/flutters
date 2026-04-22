import 'dart:convert';
import 'dart:math';

import 'package:gmana/utils/id_generator_utils.dart';

/// Domain layer service for generating various types of IDs and encodings.
class IdGeneratorService {
  final Random _random;

  /// Constructor with optional Random instance for testing.
  IdGeneratorService({Random? random}) : _random = random ?? Random();

  /// Encodes a list of objects to a Base64 string after JSON serialization.
  ///
  /// [objects]: The list of objects to encode.
  /// Returns a Base64-encoded string.
  /// Note: This is not a cryptographic hash; it’s a reversible encoding.
  String encodeToBase64(List<Object?> objects) {
    final payload = json.encode(objects);
    final payloadBytes = utf8.encode(payload);
    return base64.encode(payloadBytes);
  }

  /// Generates a nanoid-style random ID with a custom alphabet.
  ///
  /// [size]: The length of the ID (default: 21). Must be positive.
  /// Returns a random string using the nanoid alphabet.
  String generateNanoid({int size = 21}) {
    if (size <= 0) throw ArgumentError.value(size, 'size', 'Must be positive');
    const alphabet =
        'ModuleSymbhasOwnPr-0123456789ABCDEFGHNRVfgctiUvz_KqYTJkLxpZXIjQW';
    return IdGeneratorUtils.generateRandomString(
      length: size,
      characters: alphabet,
      random: _random,
    );
  }

  /// Generates a random string with configurable character sets.
  ///
  /// [length]: The length of the string (default: 8). Must be positive.
  /// [useLetters]: Include alphabetic characters (default: true).
  /// [useNumbers]: Include numeric characters (default: true).
  /// [useSymbols]: Include special symbols (default: true).
  /// Returns a random string based on the selected character sets.
  String generateRandomString({
    int length = 8,
    bool useLetters = true,
    bool useNumbers = true,
    bool useSymbols = true,
  }) {
    if (length <= 0) {
      throw ArgumentError.value(length, 'length', 'Must be positive');
    }
    if (!useLetters && !useNumbers && !useSymbols) {
      throw ArgumentError('At least one character set must be enabled');
    }

    String characters = '';
    if (useLetters) characters += IdGeneratorUtils.alpha;
    if (useNumbers) characters += IdGeneratorUtils.numbers;
    if (useSymbols) characters += IdGeneratorUtils.symbols;

    return IdGeneratorUtils.generateRandomString(
      length: length,
      characters: characters,
      random: _random,
    );
  }

  /// Generates a timestamp-based ID with prefix 'G'.
  ///
  /// Returns a string in the format 'G{timestamp}-{yxxx}-{xxxx}'.
  String generateTimestampId() {
    final special = 8 + _random.nextInt(4);
    return 'G${DateTime.now().millisecondsSinceEpoch}-${IdGeneratorUtils.printDigits(special, 1)}${IdGeneratorUtils.generateBits(_random, 12, 3)}-${IdGeneratorUtils.generateBits(_random, 12, 4)}';
  }

  /// Generates a UUID v1-like ID with a random structure.
  ///
  /// Returns a string in the format 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.
  String generateUuidV1() {
    final special = 8 + _random.nextInt(4);
    return '${IdGeneratorUtils.generateBits(_random, 16, 4)}${IdGeneratorUtils.generateBits(_random, 16, 4)}-${IdGeneratorUtils.generateBits(_random, 16, 4)}-4${IdGeneratorUtils.generateBits(_random, 12, 3)}-${IdGeneratorUtils.printDigits(special, 1)}${IdGeneratorUtils.generateBits(_random, 12, 3)}-${IdGeneratorUtils.generateBits(_random, 16, 4)}${IdGeneratorUtils.generateBits(_random, 16, 4)}${IdGeneratorUtils.generateBits(_random, 16, 4)}';
  }
}
