import '../core/validation_error.dart';

sealed class TextError extends ValidationError {
  const TextError();
}

final class TextEmpty extends TextError {
  const TextEmpty();
}

final class TextTooShort extends TextError {
  final int currentLength;
  final int minLength;
  
  const TextTooShort({
    required this.currentLength,
    required this.minLength,
  });
}

final class TextTooLong extends TextError {
  final int currentLength;
  final int maxLength;
  
  const TextTooLong({
    required this.currentLength,
    required this.maxLength,
  });
}

final class TextInvalidPattern extends TextError {
  final String pattern;
  
  const TextInvalidPattern(this.pattern);
}

final class TextContainsBlacklisted extends TextError {
  final List<String> foundWords;
  
  const TextContainsBlacklisted(this.foundWords);
}

final class TextOnlyWhitespace extends TextError {
  const TextOnlyWhitespace();
}

final class TextInvalidCharacters extends TextError {
  final String invalidChars;
  
  const TextInvalidCharacters(this.invalidChars);
}
