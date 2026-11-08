import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:live_test/main.dart';

void main() {
  testWidgets('converts Fahrenheit to Celsius', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Temperature converter'), findsOneWidget);
    expect(find.text('22.2222 °C'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('temperature-input')), '100');
    await tester.tap(find.text('Convert'));
    await tester.pump();

    expect(find.text('37.7778 °C'), findsOneWidget);
  });

  testWidgets('converts Celsius to Fahrenheit', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byKey(const Key('temperature-type')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Celsius').last);
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('temperature-input')), '100');
    await tester.tap(find.text('Convert'));
    await tester.pump();

    expect(find.text('212 °F'), findsOneWidget);
  });

  testWidgets('shows an error for invalid input', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byKey(const Key('temperature-input')), 'abc');
    await tester.tap(find.text('Convert'));
    await tester.pump();

    expect(find.text('Enter a valid temperature'), findsOneWidget);
  });
}
