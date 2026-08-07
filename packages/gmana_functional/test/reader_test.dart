import 'package:gmana_functional/gmana_functional.dart';
import 'package:test/test.dart';

class Config {
  final String apiHost;
  Config(this.apiHost);
}

void main() {
  group('Reader monad', () {
    test('ask, map, flatMap, local', () {
      final getUrl = Reader.ask<Config>().map((cfg) => '${cfg.apiHost}/users');

      final config = Config('https://api.example.com');
      expect(getUrl.run(config), equals('https://api.example.com/users'));

      final modified = getUrl.local<String>(Config.new);

      expect(modified.run('https://staging.example.com'), equals('https://staging.example.com/users'));
    });
  });
}
