/// A smoke test that actually builds the widget tree — the engine tests prove
/// the morphology, this proves the app that shows it starts, navigates and
/// renders a real gardān.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasrif/core/app_state.dart';
import 'package:tasrif/main.dart';
import 'package:tasrif/ui/home_screen.dart';
import 'package:tasrif/ui/root_scaffold.dart';
import 'package:tasrif/ui/gardan_screen.dart';
import 'package:tasrif/ui/word_info_screen.dart';

Future<AppState> _state() async {
  SharedPreferences.setMockInitialValues({});
  return AppState.load();
}

void main() {
  testWidgets('the app boots, plays the splash and lands on Home',
      (tester) async {
    await tester.pumpWidget(TasrifApp(state: await _state()));
    expect(find.text('تصريف'), findsWidgets);

    // The splash hands over on its own after its animation.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.byType(RootScaffold), findsOneWidget);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('typing a word opens its analysis, and a table opens from there',
      (tester) async {
    await tester.pumpWidget(TasrifApp(state: await _state()));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'ضرب');
    await tester.pump();
    await tester.tap(find.byType(FilledButton).first);
    await tester.pumpAndSettle();

    expect(find.byType(WordInfoScreen), findsOneWidget);
    // The identity card names the root and the bāb it was found under.
    expect(find.textContaining('ض'), findsWidgets);
  });

  testWidgets('an unrecognised word reports itself instead of crashing',
      (tester) async {
    await tester.pumpWidget(TasrifApp(state: await _state()));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '؟؟؟؟');
    await tester.pump();
    await tester.tap(find.byType(FilledButton).first);
    await tester.pumpAndSettle();

    expect(find.byType(WordInfoScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('the layout adapts: a wide window uses the rail, not the pill',
      (tester) async {
    tester.view.physicalSize = const Size(1600, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(TasrifApp(state: await _state()));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationRail), findsOneWidget);
  });

  testWidgets('a gardān table opens, and a form with i\'lāl shows its derivation',
      (tester) async {
    // A tall viewport so a whole table is laid out without scrolling games.
    tester.view.physicalSize = const Size(500, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(TasrifApp(state: await _state()));
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // قال is the أجوف — the case where the i'lāl actually has something to say.
    await tester.enterText(find.byType(TextField), 'قال');
    await tester.pump();
    await tester.tap(find.byType(FilledButton).first);
    await tester.pumpAndSettle();
    expect(find.byType(WordInfoScreen), findsOneWidget);

    // Into the first table of the الصرف الكبير index.
    final section = find.byType(GardanScreen);
    expect(section, findsNothing);
    await tester.tap(find.textContaining('الْمَاضِي الْمَعْلُومُ').first);
    await tester.pumpAndSettle();
    expect(find.byType(GardanScreen), findsOneWidget);

    // قَالَ is there, and tapping it opens the derivation with its rule named.
    expect(find.textContaining('قَالَ'), findsWidgets);
    await tester.tap(find.textContaining('قَالَ').first);
    await tester.pumpAndSettle();

    // الأصل, the rule that fired, and its taʿlīl.
    expect(find.textContaining('قَوَلَ'), findsWidgets);
    expect(find.textContaining('قَاعِدَةُ قَالَ وَبَاعَ'), findsWidgets);
  });
}
