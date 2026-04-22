import 'package:gmana/services/id_generator_service.dart';

/// Public API for generating various types of IDs and encodings.
class IdGenerator {
  static final IdGeneratorService _service = IdGeneratorService();

  /// Encodes a list of objects to a Base64 string.
  ///
  /// Example: `Gid.encodeToBase64([1, "test"])` -> Base64 string
  static String encodeToBase64(List<Object?> objects) {
    return _service.encodeToBase64(objects);
  }

  /// Generates a nanoid-style random ID.
  ///
  /// Example: `Gid.nanoid(size: 10)` -> "KqYTJkLxpZ"
  static String nanoid({int size = 21}) {
    return _service.generateNanoid(size: size);
  }

  /// Generates a random string with configurable character sets.
  ///
  /// Example: `Gid.randomString(length: 6, useNumbers: false)` -> "AbCdEf"
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

  /// Generates a timestamp-based ID with prefix 'G'.
  ///
  /// Example: `Gid.timestampId()` -> "G1697051234567-9abc-1234"
  static String timestampId() {
    return _service.generateTimestampId();
  }

  /// Generates a UUID v1-like random ID.
  ///
  /// Example: `Gid.uuidV1()` -> "123e4567-e89b-4d3a-9c4e-5f6a7b8c9d0e"
  static String uuidV1() {
    return _service.generateUuidV1();
  }
}
