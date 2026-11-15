# Email

```dart
// Untrusted input → Either<EmailValidationIssue, Email>.
final result = Email.tryParse(
  'user@example.com',
  config: EmailValidationConfig.strict(),
);

// Trusted literal → throws ValueObjectException if invalid.
final email = Email('user@example.com');
```

| API                                      | Use it for                                                                                               |
| ---------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| `Email.tryParse(input, config: ...)`     | Validate untrusted input, returning `Either<EmailValidationIssue, Email>`.                                         |
| `Email(input, config: ...)`              | Create a typed email from a trusted literal; throws `ValueObjectException` if invalid.                   |
| `EmailValidationConfig()`                | Configure required flag, max length, local/domain limits, disposable-domain checks, and blocked domains. |
| `EmailValidationConfig.strict()`         | Use stricter defaults, including disposable-domain rejection.                                            |
| `EmailValidator(config).validate(input)` | Validate an email without constructing `Email` directly.                                                 |
| `EmailEmptyIssue`                             | Input is empty when required.                                                                            |
| `EmailInvalidFormatIssue`                     | Input does not match email format.                                                                       |
| `EmailTooLongIssue`                           | Full email exceeds allowed length.                                                                       |
| `EmailLocalPartTooLongIssue`                  | Local part before `@` is too long.                                                                       |
| `EmailDomainTooLongIssue`                     | Domain part is too long.                                                                                 |
| `EmailDisposableDomainIssue`                  | Domain is disposable under strict config.                                                                |
| `EmailBlockedDomainIssue`                     | Domain appears in the blocked-domain set.                                                                |
