import '../core/validation_error.dart';

sealed class EmailError extends ValidationError {
  const EmailError();
}

final class EmailEmpty extends EmailError {
  const EmailEmpty();
}

final class EmailInvalidFormat extends EmailError {
  const EmailInvalidFormat();
}

final class EmailTooLong extends EmailError {
  final int currentLength;
  final int maxLength;
  
  const EmailTooLong({
    required this.currentLength,
    required this.maxLength,
  });
}

final class EmailLocalPartTooLong extends EmailError {
  final int currentLength;
  final int maxLength;
  
  const EmailLocalPartTooLong({
    required this.currentLength,
    required this.maxLength,
  });
}

final class EmailDomainTooLong extends EmailError {
  final int currentLength;
  final int maxLength;
  
  const EmailDomainTooLong({
    required this.currentLength,
    required this.maxLength,
  });
}

final class EmailDisposableDomain extends EmailError {
  final String domain;
  
  const EmailDisposableDomain(this.domain);
}

final class EmailBlockedDomain extends EmailError {
  final String domain;
  
  const EmailBlockedDomain(this.domain);
}
