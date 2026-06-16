# Email

```dart
// Untrusted input → Either<EmailError, Email>.
final result = Email.tryParse(
  'user@example.com',
  config: EmailValidationConfig.strict(),
);

// Trusted literal → throws ValueObjectException if invalid.
final email = Email('user@example.com');
```

| API                                      | Use it for                                                                                               |
| ---------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| `Email.tryParse(input, config: ...)`     | Validate untrusted input, returning `Either<EmailError, Email>`.                                         |
| `Email(input, config: ...)`              | Create a typed email from a trusted literal; throws `ValueObjectException` if invalid.                   |
| `EmailValidationConfig()`                | Configure required flag, max length, local/domain limits, disposable-domain checks, and blocked domains. |
| `EmailValidationConfig.strict()`         | Use stricter defaults, including disposable-domain rejection.                                            |
| `EmailValidator(config).validate(input)` | Validate an email without constructing `Email` directly.                                                 |
| `EmailEmpty`                             | Input is empty when required.                                                                            |
| `EmailInvalidFormat`                     | Input does not match email format.                                                                       |
| `EmailTooLong`                           | Full email exceeds allowed length.                                                                       |
| `EmailLocalPartTooLong`                  | Local part before `@` is too long.                                                                       |
| `EmailDomainTooLong`                     | Domain part is too long.                                                                                 |
| `EmailDisposableDomain`                  | Domain is disposable under strict config.                                                                |
| `EmailBlockedDomain`                     | Domain appears in the blocked-domain set.                                                                |
