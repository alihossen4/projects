import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_app/presentation/screens/home_screen.dart';

void main() {
  testWidgets('home screen shows a searchable Maps-style top bar', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.text('Search Google Maps'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'coffee');
    await tester.pump();
    expect(find.text('coffee'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();
    expect(find.text('coffee'), findsNothing);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Restaurants'));
    await tester.pump();
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Restaurants'))
          .selected,
      isTrue,
    );
  });
}
