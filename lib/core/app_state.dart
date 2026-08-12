/// App-wide settings, persisted, and the InheritedNotifier that publishes them.
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../sarf/lang.dart';

class AppState extends ChangeNotifier {
  AppState._(this._prefs)
      : _lang = _readLang(_prefs),
        _themeMode = _readTheme(_prefs),
        _showTashkeel = _prefs.getBool(_kTashkeel) ?? true,
        _arabicDigits = _prefs.getBool(_kDigits) ?? true,
        _textScale = _prefs.getDouble(_kScale) ?? 1.0,
        _recent = _prefs.getStringList(_kRecent) ?? const [];

  static const _kLang = 'lang';
  static const _kTheme = 'themeMode';
  static const _kTashkeel = 'showTashkeel';
  static const _kDigits = 'arabicDigits';
  static const _kScale = 'textScale';
  static const _kRecent = 'recent';

  final SharedPreferences _prefs;

  static Future<AppState> load() async =>
      AppState._(await SharedPreferences.getInstance());

  static Lang _readLang(SharedPreferences p) {
    final v = p.getString(_kLang);
    return Lang.values.firstWhere((l) => l.name == v, orElse: () => Lang.ps);
  }

  static ThemeMode _readTheme(SharedPreferences p) {
    final v = p.getString(_kTheme);
    return ThemeMode.values
        .firstWhere((t) => t.name == v, orElse: () => ThemeMode.system);
  }

  Lang _lang;
  ThemeMode _themeMode;
  bool _showTashkeel;
  bool _arabicDigits;
  double _textScale;
  List<String> _recent;

  Lang get lang => _lang;
  ThemeMode get themeMode => _themeMode;
  bool get showTashkeel => _showTashkeel;
  bool get arabicDigits => _arabicDigits;
  double get textScale => _textScale;
  List<String> get recent => List.unmodifiable(_recent);

  set lang(Lang v) {
    if (_lang == v) return;
    _lang = v;
    _prefs.setString(_kLang, v.name);
    notifyListeners();
  }

  set themeMode(ThemeMode v) {
    if (_themeMode == v) return;
    _themeMode = v;
    _prefs.setString(_kTheme, v.name);
    notifyListeners();
  }

  set showTashkeel(bool v) {
    if (_showTashkeel == v) return;
    _showTashkeel = v;
    _prefs.setBool(_kTashkeel, v);
    notifyListeners();
  }

  set arabicDigits(bool v) {
    if (_arabicDigits == v) return;
    _arabicDigits = v;
    _prefs.setBool(_kDigits, v);
    notifyListeners();
  }

  set textScale(double v) {
    if (_textScale == v) return;
    _textScale = v;
    _prefs.setDouble(_kScale, v);
    notifyListeners();
  }

  void pushRecent(String word) {
    final w = word.trim();
    if (w.isEmpty) return;
    final next = [w, ..._recent.where((x) => x != w)].take(12).toList();
    _recent = next;
    _prefs.setStringList(_kRecent, next);
    notifyListeners();
  }

  void clearRecent() {
    _recent = const [];
    _prefs.remove(_kRecent);
    notifyListeners();
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
      : super(notifier: state);

  static AppState of(BuildContext context) {
    final s = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(s != null, 'AppScope is missing above this widget');
    return s!.notifier!;
  }
}
