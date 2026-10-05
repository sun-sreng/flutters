import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter/gmana_flutter.dart';

void main() {
  group('formatLocale', () {
    test('returns only language code when country and script are absent', () {
      expect(formatLocale(const Locale('ja')), 'ja');
    });

    test('returns language and country code', () {
      expect(formatLocale(const Locale('en', 'US')), 'en_US');
    });

    test('returns language and script code', () {
      const locale = Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans');

      expect(formatLocale(locale), 'zh_Hans');
    });

    test('returns language, script, and country code', () {
      const locale = Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hans',
        countryCode: 'CN',
      );

      expect(formatLocale(locale), 'zh_Hans_CN');
    });
  });

  group('parseLocale', () {
    test('returns default locale when value is null', () {
      expect(parseLocale(null), const Locale('en', 'US'));
    });

    test('returns default locale when value is empty', () {
      expect(parseLocale(''), const Locale('en', 'US'));
    });

    test('parses language code only', () {
      expect(parseLocale('ja'), const Locale('ja'));
    });

    test('parses language and country code', () {
      expect(parseLocale('en_US'), const Locale('en', 'US'));
    });

    test('parses language, script, and country code', () {
      const expected = Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hans',
        countryCode: 'CN',
      );

      expect(parseLocale('zh_Hans_CN'), expected);
    });
  });

  test('round trips a locale with script and country code', () {
    const locale = Locale.fromSubtags(
      languageCode: 'zh',
      scriptCode: 'Hans',
      countryCode: 'CN',
    );

    expect(parseLocale(formatLocale(locale)), locale);
  });
}
