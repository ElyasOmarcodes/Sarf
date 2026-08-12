/// Material 3 Expressive theming.
///
/// One seed drives both schemes so light and dark stay siblings rather than
/// two separate designs. Shapes are deliberately large and soft — Expressive
/// leans on generous corner radii and stadium shapes, which also suits Arabic
/// display type sitting in cards.
library;

import 'package:flutter/material.dart';

import '../sarf/lang.dart';

const Color seed = Color(0xFF6C4BD6);

/// Amiri renders fully-vocalised Arabic properly on every platform; the
/// system font would drop or mis-place harakat on Windows.
const String arabicFont = 'Amiri';

/// Amiri sets its glyphs small within the em square, the way naskh faces do,
/// and a fully-vocalised line needs headroom for the marks above and below.
/// Every piece of Arabic in the app goes through here so it is sized and
/// leaded once, in one place, rather than nudged per screen.
TextStyle arabicStyle(TextStyle? base) {
  final s = base ?? const TextStyle();
  return s.copyWith(
    fontFamily: arabicFont,
    fontSize: (s.fontSize ?? 16) * 1.18,
    height: 1.75,
  );
}

ThemeData buildTheme(Brightness brightness, Lang lang) {
  final scheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: brightness,
  );
  final base = ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    brightness: brightness,
  );

  // The UI keeps the platform's own face. Amiri is a naskh face for *Arabic* —
  // it has no Pashto letters (ټ ډ ړ ږ ښ ګ ڼ ې ۍ) at all, so making it the UI
  // font left every Pashto paragraph half in one font and half in another.
  // It stays as a fallback, which is what covers Arabic quotations inside
  // otherwise-Pashto strings, and [Ar] opts into it explicitly.
  TextStyle ui(TextStyle? s, {FontWeight? w}) =>
      (s ?? const TextStyle()).copyWith(
        fontFamilyFallback: const [arabicFont],
        fontWeight: w,
        height: 1.5,
      );

  final t = base.textTheme;
  final textTheme = t.copyWith(
    displayLarge: ui(t.displayLarge, w: FontWeight.w700),
    displayMedium: ui(t.displayMedium, w: FontWeight.w700),
    displaySmall: ui(t.displaySmall, w: FontWeight.w700),
    headlineLarge: ui(t.headlineLarge, w: FontWeight.w700),
    headlineMedium: ui(t.headlineMedium, w: FontWeight.w700),
    headlineSmall: ui(t.headlineSmall, w: FontWeight.w700),
    titleLarge: ui(t.titleLarge, w: FontWeight.w700),
    titleMedium: ui(t.titleMedium, w: FontWeight.w600),
    titleSmall: ui(t.titleSmall, w: FontWeight.w600),
    bodyLarge: ui(t.bodyLarge),
    bodyMedium: ui(t.bodyMedium),
    bodySmall: ui(t.bodySmall),
    labelLarge: ui(t.labelLarge, w: FontWeight.w600),
    labelMedium: ui(t.labelMedium, w: FontWeight.w600),
    labelSmall: ui(t.labelSmall, w: FontWeight.w600),
  );

  return base.copyWith(
    textTheme: textTheme,
    scaffoldBackgroundColor: scheme.surface,
    splashFactory: InkSparkle.splashFactory,
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 56),
        shape: const StadiumBorder(),
        textStyle: textTheme.titleMedium,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 52),
        shape: const StadiumBorder(),
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(shape: const StadiumBorder()),
    ),
    chipTheme: ChipThemeData(
      shape: const StadiumBorder(),
      side: BorderSide.none,
      backgroundColor: scheme.surfaceContainerHigh,
      labelStyle: textTheme.labelLarge,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(color: scheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
  );
}

/// Layout breakpoints. Everything above [compact] gets the two-pane
/// treatment so a desktop window is not a stretched phone.
class Breaks {
  static const double compact = 640;
  static const double medium = 1000;

  static bool isCompact(BuildContext c) =>
      MediaQuery.sizeOf(c).width < compact;
  static bool isExpanded(BuildContext c) =>
      MediaQuery.sizeOf(c).width >= medium;
}
