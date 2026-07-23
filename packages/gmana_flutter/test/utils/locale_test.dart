import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter/gmana_flutter.dart';

void main() {
  group('fromLocale', () {
    test('returns only language code when country and script are absent', () {
      expect(fromLocale(const Locale('ja')), 'ja');
    });

    test('returns language and country code', () {
      expect(fromLocale(const Locale('en', 'US')), 'en_US');
    });

    test('returns language and script code', () {
      const locale = Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans');

      expect(fromLocale(locale), 'zh_Hans');
    });

    test('returns language, script, and country code', () {
      const locale = Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hans',
        countryCode: 'CN',
      );

      expect(fromLocale(locale), 'zh_Hans_CN');
    });
  });

  group('toLocale', () {
    test('returns default locale when value is null', () {
      expect(toLocale(null), const Locale('en', 'US'));
    });

    test('returns default locale when value is empty', () {
      expect(toLocale(''), const Locale('en', 'US'));
    });

    test('parses language code only', () {
      expect(toLocale('ja'), const Locale('ja'));
    });

    test('parses language and country code', () {
      expect(toLocale('en_US'), const Locale('en', 'US'));
    });

    test('parses language, script, and country code', () {
      const expected = Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hans',
        countryCode: 'CN',
      );

      expect(toLocale('zh_Hans_CN'), expected);
    });
  });

  test('round trips a locale with script and country code', () {
    const locale = Locale.fromSubtags(
      languageCode: 'zh',
      scriptCode: 'Hans',
      countryCode: 'CN',
    );

    expect(toLocale(fromLocale(locale)), locale);
  });
}
