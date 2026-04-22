import 'dart:math';

/// Utility class for ID generation helper methods.
class IdGeneratorUtils {
  /// Character set for alphabetic characters.
  static const alpha = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';

  /// Character set for numeric characters.
  static const numbers = '0123456789';

  /// Character set for special symbols.
  static const symbols = '!@#\$%^&*_-+=';

  /// Generates random bits and formats them as a hexadecimal string.
  ///
  /// [random]: The Random instance.
  /// [bitCount]: The number of bits to generate.
  /// [digitCount]: The number of hexadecimal digits to output.
  /// Returns a hexadecimal string padded to [digitCount].
  static String generateBits(Random random, int bitCount, int digitCount) {
    final value = random.nextInt(1 << bitCount);
    return printDigits(value, digitCount);
  }

  /// Generates a random string from the provided [characters].
  ///
  /// [length]: The length of the string.
  /// [characters]: The character set to use.
  /// [random]: The Random instance for generating indices.
  /// Returns a random string of specified length.
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

  /// Formats a value as a hexadecimal string.
  ///
  /// [value]: The integer value to format.
  /// [count]: The number of digits to pad to.
  /// Returns a hexadecimal string padded with leading zeros.
  static String printDigits(int value, int count) {
    return value.toRadixString(16).padLeft(count, '0');
  }
}
