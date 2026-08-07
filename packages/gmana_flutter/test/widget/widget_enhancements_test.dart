import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gmana_flutter/gmana_flutter.dart';

Widget host(Widget child) =>
    MaterialApp(theme: GColors.lightTheme, home: Scaffold(body: child));

Color? buttonBackground(WidgetTester tester) => tester
    .widget<ElevatedButton>(find.byType(ElevatedButton))
    .style
    ?.backgroundColor
    ?.resolve(<WidgetState>{});

void main() {
  group('GButton size presets', () {
    testWidgets('scale the label font', (tester) async {
      double fontOf(WidgetTester t) =>
          t.widget<Text>(find.text('Go')).style!.fontSize!;

      await tester.pumpWidget(
        host(GButton(label: 'Go', size: GButtonSize.small, onPressed: () {})),
      );
      final small = fontOf(tester);

      await tester.pumpWidget(
        host(GButton(label: 'Go', size: GButtonSize.large, onPressed: () {})),
      );
      final large = fontOf(tester);

      expect(small, lessThan(large));
    });

    testWidgets('scale the loading indicator', (tester) async {
      await tester.pumpWidget(
        host(
          const GButton(label: 'Go', size: GButtonSize.small, isLoading: true),
        ),
      );

      final box = tester.widget<SizedBox>(
        find
            .ancestor(
              of: find.byType(CircularProgressIndicator),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(box.width, 14);
    });

    testWidgets('a small button is shorter than a large one', (tester) async {
      await tester.pumpWidget(
        host(GButton(label: 'Go', size: GButtonSize.small, onPressed: () {})),
      );
      final small = tester.getSize(find.byType(GButton)).height;

      await tester.pumpWidget(
        host(GButton(label: 'Go', size: GButtonSize.large, onPressed: () {})),
      );
      final large = tester.getSize(find.byType(GButton)).height;

      expect(small, lessThan(large));
    });
  });

  group('GButton danger variant', () {
    testWidgets('uses the error color', (tester) async {
      await tester.pumpWidget(
        host(
          GButton(
            label: 'Delete',
            variant: GButtonVariant.danger,
            onPressed: () {},
          ),
        ),
      );

      expect(buttonBackground(tester), GColors.error);
    });

    testWidgets('still honours a background override', (tester) async {
      await tester.pumpWidget(
        host(
          GButton(
            label: 'Delete',
            variant: GButtonVariant.danger,
            backgroundColor: const Color(0xFF123456),
            onPressed: () {},
          ),
        ),
      );

      expect(buttonBackground(tester), const Color(0xFF123456));
    });

    testWidgets('tints its loading spinner with onError', (tester) async {
      await tester.pumpWidget(
        host(
          const GButton(
            label: 'Delete',
            variant: GButtonVariant.danger,
            isLoading: true,
          ),
        ),
      );

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.valueColor?.value, GColors.onError);
    });
  });

  group('GButton trailing icon and tooltip', () {
    testWidgets('renders a trailing icon', (tester) async {
      await tester.pumpWidget(
        host(
          GButton(
            label: 'Next',
            trailingIcon: const Icon(Icons.arrow_forward),
            onPressed: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    testWidgets('hides the trailing icon while loading', (tester) async {
      await tester.pumpWidget(
        host(
          const GButton(
            label: 'Next',
            trailingIcon: Icon(Icons.arrow_forward),
            isLoading: true,
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_forward), findsNothing);
    });

    testWidgets('wraps in a Tooltip only when a message is given', (
      tester,
    ) async {
      await tester.pumpWidget(host(GButton(label: 'Save', onPressed: () {})));
      expect(
        find.descendant(
          of: find.byType(GButton),
          matching: find.byType(Tooltip),
        ),
        findsNothing,
      );

      await tester.pumpWidget(
        host(
          GButton(label: 'Save', tooltip: 'Save the draft', onPressed: () {}),
        ),
      );
      expect(
        find.descendant(
          of: find.byType(GButton),
          matching: find.byType(Tooltip),
        ),
        findsOneWidget,
      );
    });
  });

  group('GCard additions', () {
    RoundedRectangleBorder cardShape(WidgetTester tester) =>
        tester
                .widget<Material>(
                  find
                      .descendant(
                        of: find.byType(GCard),
                        matching: find.byType(Material),
                      )
                      .first,
                )
                .shape!
            as RoundedRectangleBorder;

    testWidgets('has no border by default', (tester) async {
      await tester.pumpWidget(host(const GCard(child: Text('Body'))));
      expect(cardShape(tester).side, BorderSide.none);
    });

    testWidgets('showBorder draws the theme outline', (tester) async {
      await tester.pumpWidget(
        host(const GCard(showBorder: true, child: Text('Body'))),
      );

      expect(cardShape(tester).side, isNot(BorderSide.none));
      expect(
        cardShape(tester).side.color,
        GColors.lightTheme.colorScheme.outlineVariant,
      );
    });

    testWidgets('an explicit borderColor still wins', (tester) async {
      await tester.pumpWidget(
        host(const GCard(borderColor: Color(0xFF00FF00), child: Text('Body'))),
      );

      expect(cardShape(tester).side.color, const Color(0xFF00FF00));
    });

    testWidgets('onLongPress makes the card interactive', (tester) async {
      var longPressed = false;
      await tester.pumpWidget(
        host(
          GCard(
            onLongPress: () => longPressed = true,
            child: const Text('Body'),
          ),
        ),
      );

      await tester.longPress(find.text('Body'));
      expect(longPressed, isTrue);
    });

    testWidgets('semanticsLabel is exposed', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(const GCard(semanticsLabel: 'Invoice card', child: Text('Body'))),
      );

      expect(find.bySemanticsLabel('Invoice card'), findsOneWidget);
      handle.dispose();
    });
  });

  group('GAppBar additions', () {
    testWidgets('showBackButton: false removes the synthesized arrow', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(appBar: GAppBar(title: 'Root', showBackButton: false)),
        ),
      );

      expect(find.byIcon(Icons.arrow_back), findsNothing);
      expect(find.text('Root'), findsOneWidget);
    });

    testWidgets('titleWidget takes precedence over title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: GAppBar(
              title: 'Ignored',
              titleWidget: Text('Custom title'),
            ),
          ),
        ),
      );

      expect(find.text('Custom title'), findsOneWidget);
      expect(find.text('Ignored'), findsNothing);
    });

    testWidgets('bottom widget height is added to preferredSize', (
      tester,
    ) async {
      const plain = GAppBar(title: 'T');
      const withBottom = GAppBar(
        title: 'T',
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: SizedBox(height: 48),
        ),
      );

      expect(withBottom.preferredSize.height, plain.preferredSize.height + 48);
    });

    testWidgets('toolbarHeight override is reflected', (tester) async {
      const bar = GAppBar(title: 'T', toolbarHeight: 72);
      expect(bar.preferredSize.height, 72);
    });
  });

  group('GListTile additions', () {
    testWidgets('renders a subtitle', (tester) async {
      await tester.pumpWidget(
        host(
          const GListTile(
            icon: Icons.person,
            title: 'Profile',
            subtitle: 'Name, photo, bio',
          ),
        ),
      );

      expect(find.text('Name, photo, bio'), findsOneWidget);
    });

    testWidgets('showChevron: false hides the chevron', (tester) async {
      await tester.pumpWidget(
        host(
          const GListTile(
            icon: Icons.person,
            title: 'Profile',
            showChevron: false,
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_forward_ios), findsNothing);
    });

    testWidgets('a custom trailing replaces the default', (tester) async {
      await tester.pumpWidget(
        host(
          const GListTile(
            icon: Icons.person,
            title: 'Profile',
            label: 'ignored',
            trailing: Icon(Icons.more_horiz),
          ),
        ),
      );

      expect(find.byIcon(Icons.more_horiz), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_ios), findsNothing);
      expect(find.text('ignored'), findsNothing);
    });

    testWidgets('enabled: false blocks taps', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        host(
          GListTile(
            icon: Icons.person,
            title: 'Profile',
            enabled: false,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(GListTile));
      expect(tapped, isFalse);
    });
  });

  group('GStarRatingBar interaction', () {
    Finder starAt(int index) => find
        .descendant(
          of: find.byType(GStarRatingBar),
          matching: find.byType(GestureDetector),
        )
        .at(index);

    testWidgets('is read-only without onRatingChanged', (tester) async {
      await tester.pumpWidget(host(const GStarRatingBar(ratingValue: 3)));

      expect(
        find.descendant(
          of: find.byType(GStarRatingBar),
          matching: find.byType(GestureDetector),
        ),
        findsNothing,
      );
    });

    testWidgets('tapping the centre of a star reports the whole value', (
      tester,
    ) async {
      double? reported;
      await tester.pumpWidget(
        host(
          GStarRatingBar(
            ratingValue: 0,
            starSize: 40,
            onRatingChanged: (value) => reported = value,
          ),
        ),
      );

      await tester.tap(starAt(2));
      expect(reported, 3.0);
    });

    testWidgets('tapping the leading half reports a half star', (tester) async {
      double? reported;
      await tester.pumpWidget(
        host(
          GStarRatingBar(
            ratingValue: 0,
            starSize: 40,
            onRatingChanged: (value) => reported = value,
          ),
        ),
      );

      final topLeft = tester.getTopLeft(starAt(2));
      await tester.tapAt(topLeft + const Offset(4, 20));
      expect(reported, 2.5);
    });

    testWidgets('half stars are disabled when enableHalfStar is false', (
      tester,
    ) async {
      double? reported;
      await tester.pumpWidget(
        host(
          GStarRatingBar(
            ratingValue: 0,
            starSize: 40,
            enableHalfStar: false,
            onRatingChanged: (value) => reported = value,
          ),
        ),
      );

      final topLeft = tester.getTopLeft(starAt(0));
      await tester.tapAt(topLeft + const Offset(4, 20));
      expect(reported, 1.0);
    });

    testWidgets('never reports above maxStars', (tester) async {
      double? reported;
      await tester.pumpWidget(
        host(
          GStarRatingBar(
            ratingValue: 0,
            maxStars: 3,
            starSize: 40,
            onRatingChanged: (value) => reported = value,
          ),
        ),
      );

      await tester.tap(starAt(2));
      expect(reported, 3.0);
    });
  });

  group('GTextField additions', () {
    testWidgets('renders helper text', (tester) async {
      await tester.pumpWidget(
        host(const GTextField(label: 'Name', helperText: 'As on your ID')),
      );

      expect(find.text('As on your ID'), findsOneWidget);
    });

    testWidgets('maxLength shows the counter', (tester) async {
      await tester.pumpWidget(host(const GTextField(maxLength: 10)));

      expect(find.text('0/10'), findsOneWidget);
    });

    testWidgets('readOnly blocks edits but keeps the value visible', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'locked');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        host(GTextField(controller: controller, readOnly: true)),
      );

      await tester.enterText(find.byType(TextField), 'changed');
      expect(controller.text, 'locked');
    });

    testWidgets('onTap fires for picker-style fields', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        host(GTextField(readOnly: true, onTap: () => tapped = true)),
      );

      await tester.tap(find.byType(TextField));
      expect(tapped, isTrue);
    });

    testWidgets('inputFormatters are applied', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        host(
          GTextField(
            controller: controller,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'a1b2c3');
      expect(controller.text, '123');
    });

    testWidgets('an external focusNode drives focus', (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);

      await tester.pumpWidget(host(GTextField(focusNode: node)));
      node.requestFocus();
      await tester.pump();

      expect(node.hasFocus, isTrue);
    });

    testWidgets('minLines is ignored for obscured fields', (tester) async {
      await tester.pumpWidget(
        host(const GTextField(obscureText: true, minLines: 3, maxLines: 5)),
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.maxLines, 1);
      expect(field.minLines, isNull);
    });
  });
}
