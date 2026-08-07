import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter_extensions/gmana_flutter_extensions.dart';

const _children = <Widget>[Text('a'), Text('b'), Text('c')];

Widget host(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('WidgetListX.separatedBy', () {
    test('interleaves the separator', () {
      final result = _children.separatedBy(const Divider());

      expect(result, hasLength(5));
      expect(result[0], isA<Text>());
      expect(result[1], isA<Divider>());
      expect(result[2], isA<Text>());
      expect(result[3], isA<Divider>());
      expect(result[4], isA<Text>());
    });

    test('leaves short lists alone', () {
      expect(const <Widget>[].separatedBy(const Divider()), isEmpty);
      expect(
        const <Widget>[Text('only')].separatedBy(const Divider()),
        hasLength(1),
      );
    });

    test('returns a new list rather than mutating the source', () {
      final source = <Widget>[const Text('a'), const Text('b')];
      final result = source.separatedBy(const Divider());

      expect(source, hasLength(2));
      expect(result, hasLength(3));
    });

    test('separatedByHeight and separatedByWidth insert sized gaps', () {
      final vertical = _children.separatedByHeight(8);
      expect((vertical[1] as SizedBox).height, 8);

      final horizontal = _children.separatedByWidth(12);
      expect((horizontal[1] as SizedBox).width, 12);
    });
  });

  group('WidgetListX layout wrappers', () {
    testWidgets('toColumn builds a Column with the children', (tester) async {
      await tester.pumpWidget(host(_children.toColumn()));

      expect(find.byType(Column), findsOneWidget);
      expect(find.text('a'), findsOneWidget);
      expect(find.text('c'), findsOneWidget);
    });

    testWidgets('toColumn forwards alignment and spacing', (tester) async {
      await tester.pumpWidget(
        host(
          _children.toColumn(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
          ),
        ),
      );

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.mainAxisAlignment, MainAxisAlignment.end);
      expect(column.crossAxisAlignment, CrossAxisAlignment.start);
      expect(column.mainAxisSize, MainAxisSize.min);
      expect(column.spacing, 4);
    });

    testWidgets('toRow builds a Row', (tester) async {
      await tester.pumpWidget(host(_children.toRow(spacing: 6)));

      final row = tester.widget<Row>(find.byType(Row));
      expect(row.spacing, 6);
      expect(find.text('b'), findsOneWidget);
    });

    testWidgets('toStack builds a Stack', (tester) async {
      await tester.pumpWidget(
        host(_children.toStack(alignment: Alignment.bottomRight)),
      );

      // Scaffold builds its own Stack, so scope to the one wrapping our children.
      final stack = tester.widget<Stack>(
        find.ancestor(of: find.text('a'), matching: find.byType(Stack)).first,
      );
      expect(stack.alignment, Alignment.bottomRight);
    });

    testWidgets('toWrap builds a Wrap', (tester) async {
      await tester.pumpWidget(
        host(_children.toWrap(spacing: 3, runSpacing: 5)),
      );

      final wrap = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrap.spacing, 3);
      expect(wrap.runSpacing, 5);
    });

    testWidgets('toListView builds a scrollable list', (tester) async {
      await tester.pumpWidget(
        host(_children.toListView(padding: const EdgeInsets.all(8))),
      );

      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('a'), findsOneWidget);
    });

    testWidgets('separatedBy composes with toColumn', (tester) async {
      await tester.pumpWidget(
        host(_children.separatedBy(const Divider()).toColumn()),
      );

      expect(find.byType(Divider), findsNWidgets(2));
    });
  });
}
