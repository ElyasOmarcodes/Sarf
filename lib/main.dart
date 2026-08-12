import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/app_state.dart';
import 'core/theme.dart';
import 'sarf/lang.dart';
import 'ui/root_scaffold.dart';
import 'ui/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = await AppState.load();
  runApp(TasrifApp(state: state));
}

class TasrifApp extends StatelessWidget {
  const TasrifApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: state,
      child: AnimatedBuilder(
        animation: state,
        builder: (context, _) {
          final lang = state.lang;
          return MaterialApp(
            title: 'تصريف',
            debugShowCheckedModeBanner: false,
            theme: buildTheme(Brightness.light, lang),
            darkTheme: buildTheme(Brightness.dark, lang),
            themeMode: state.themeMode,
            builder: (context, child) {
              // The whole app is RTL except in English, and the reader's text
              // scale is applied on top of the platform's own.
              final mq = MediaQuery.of(context);
              return MediaQuery(
                data: mq.copyWith(
                  textScaler: TextScaler.linear(
                    mq.textScaler.scale(1) * state.textScale,
                  ),
                ),
                child: Directionality(
                  textDirection:
                      lang.isRtl ? TextDirection.rtl : TextDirection.ltr,
                  child: child ?? const SizedBox.shrink(),
                ),
              );
            },
            home: const _Boot(),
          );
        },
      ),
    );
  }
}

/// Splash first, then the app — with the system bars styled to match whichever
/// scheme ended up in play.
class _Boot extends StatefulWidget {
  const _Boot();

  @override
  State<_Boot> createState() => _BootState();
}

class _BootState extends State<_Boot> {
  bool _ready = false;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness:
            dark ? Brightness.light : Brightness.dark,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 520),
        switchInCurve: Curves.easeOutCubic,
        child: _ready
            ? const RootScaffold()
            : SplashScreen(onDone: () => setState(() => _ready = true)),
      ),
    );
  }
}
