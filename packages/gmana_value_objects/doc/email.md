# Email

```dart
final email = Email(
  'user@example.com',
  config: EmailValidationConfig.strict(),
);

final result = EmailValidator(
  EmailValidationConfig(blockedDomains: {'example.org'}),
).validate('user@example.com');
```

| API                                      | Use it for                                                                                               |
| ---------------------------------------- | -------------------------------------------------------------------------------------------------------- |
| `Email(input, config: ...)`              | Create a typed email value object.                                                                       |
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
