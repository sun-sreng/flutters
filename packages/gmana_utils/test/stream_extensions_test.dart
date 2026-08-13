import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:gmana_utils/gmana_utils.dart';
import 'package:test/test.dart';

void main() {
  group('Stream.debounce', () {
    test('emits only the last event of a burst', () {
      fakeAsync((async) {
        final controller = StreamController<int>();
        final seen = <int>[];

        controller.stream
            .debounce(const Duration(milliseconds: 100))
            .listen(seen.add);

        controller
          ..add(1)
          ..add(2)
          ..add(3);
        async.elapse(const Duration(milliseconds: 150));

        expect(seen, [3]);

        unawaited(controller.close());
        async.flushTimers();
      });
    });

    test('emits separately for bursts split by a quiet period', () {
      fakeAsync((async) {
        final controller = StreamController<int>();
        final seen = <int>[];

        controller.stream
            .debounce(const Duration(milliseconds: 100))
            .listen(seen.add);

        controller.add(1);
        async.elapse(const Duration(milliseconds: 150));
        controller.add(2);
        async.elapse(const Duration(milliseconds: 150));

        expect(seen, [1, 2]);

        unawaited(controller.close());
        async.flushTimers();
      });
    });

    test('emits the pending event when the source closes early', () {
      fakeAsync((async) {
        final controller = StreamController<int>();
        final seen = <int>[];
        var done = false;

        controller.stream
            .debounce(const Duration(milliseconds: 100))
            .listen(seen.add, onDone: () => done = true);

        controller.add(7);
        async.elapse(const Duration(milliseconds: 10));
        unawaited(controller.close());
        async.flushTimers();

        expect(seen, [7]);
        expect(done, isTrue);
      });
    });

    test('forwards errors without waiting for the quiet period', () {
      fakeAsync((async) {
        final controller = StreamController<int>();
        final errors = <Object>[];

        controller.stream
            .debounce(const Duration(milliseconds: 100))
            .listen((_) {}, onError: errors.add);

        controller.addError(StateError('boom'));
        async.elapse(const Duration(milliseconds: 10));

        expect(errors, hasLength(1));

        unawaited(controller.close());
        async.flushTimers();
      });
    });
  });

  group('Stream.throttle', () {
    test('emits the first event and drops the rest of the window', () {
      fakeAsync((async) {
        final controller = StreamController<int>();
        final seen = <int>[];

        controller.stream
            .throttle(const Duration(milliseconds: 100))
            .listen(seen.add);

        controller
          ..add(1)
          ..add(2)
          ..add(3);
        async.elapse(const Duration(milliseconds: 50));

        // 2 and 3 arrived inside the window and are dropped outright.
        expect(seen, [1]);

        // Once the window closes the next event leads a fresh window.
        async.elapse(const Duration(milliseconds: 100));
        controller.add(4);
        async.elapse(const Duration(milliseconds: 10));
        expect(seen, [1, 4]);

        unawaited(controller.close());
        async.flushTimers();
      });
    });

    test('emits the last dropped event when trailing is enabled', () {
      fakeAsync((async) {
        final controller = StreamController<int>();
        final seen = <int>[];

        controller.stream
            .throttle(const Duration(milliseconds: 100), trailing: true)
            .listen(seen.add);

        controller
          ..add(1)
          ..add(2)
          ..add(3);
        async.elapse(const Duration(milliseconds: 150));

        expect(seen, [1, 3]);

        unawaited(controller.close());
        async.flushTimers();
      });
    });

    test('does not emit a trailing event when none was dropped', () {
      fakeAsync((async) {
        final controller = StreamController<int>();
        final seen = <int>[];

        controller.stream
            .throttle(const Duration(milliseconds: 100), trailing: true)
            .listen(seen.add);

        controller.add(1);
        async.elapse(const Duration(milliseconds: 150));

        expect(seen, [1]);

        unawaited(controller.close());
        async.flushTimers();
      });
    });
  });

  group('Stream timing validation', () {
    test('rejects a non-positive duration', () {
      const stream = Stream<int>.empty();
      expect(() => stream.debounce(Duration.zero), throwsArgumentError);
      expect(() => stream.throttle(Duration.zero), throwsArgumentError);
    });
  });
}
