import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_state.dart';
import '../core/strings.dart';
import '../core/theme.dart';
import 'about_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'widgets/common.dart';
import 'widgets/floating_nav_bar.dart';

/// Hosts the three destinations. Narrow windows get the floating pill;
/// anything wider gets a rail, so a desktop window is not a stretched phone.
class RootScaffold extends StatefulWidget {
  const RootScaffold({super.key});

  @override
  State<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> {
  int _index = 0;

  static const _pages = [
    HomeScreen(),
    SettingsScreen(),
    AboutScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final s = S.of(AppScope.of(context).lang);
    final compact = Breaks.isCompact(context);

    final dests = [
      NavDest(Icons.home_outlined, Icons.home_rounded, s.navHome),
      NavDest(Icons.tune_outlined, Icons.tune_rounded, s.navSettings),
      NavDest(Icons.info_outline_rounded, Icons.info_rounded, s.navAbout),
    ];

    final body = AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutCubic,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.02), end: Offset.zero)
              .animate(anim),
          child: child,
        ),
      ),
      child: KeyedSubtree(key: ValueKey(_index), child: _pages[_index]),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        // Back on a sub-tab returns Home; on Home, confirm the exit.
        if (_index != 0) {
          setState(() => _index = 0);
          return;
        }
        final ok = await showConfirmDialog(
          context,
          icon: Icons.exit_to_app_rounded,
          title: s.exitTitle,
          message: s.exitMsg,
          confirmLabel: s.exit,
          cancelLabel: s.cancel,
        );
        if (ok) SystemNavigator.pop();
      },
      child: Scaffold(
        extendBody: true,
        body: SafeArea(
          bottom: false,
          child: compact
              ? EdgeFade(top: true, bottomHeight: 118, child: body)
              : Row(
                  children: [
                    NavigationRail(
                      selectedIndex: _index,
                      onDestinationSelected: (i) => setState(() => _index = i),
                      labelType: NavigationRailLabelType.all,
                      groupAlignment: -0.85,
                      leading: Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 20),
                        child: _RailMark(),
                      ),
                      destinations: [
                        for (final d in dests)
                          NavigationRailDestination(
                            icon: Icon(d.icon),
                            selectedIcon: Icon(d.selectedIcon),
                            label: Text(d.label),
                          ),
                      ],
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(
                      child: Center(
                        // A readable measure on a wide monitor.
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 1180),
                          child: EdgeFade(top: true, child: body),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
        bottomNavigationBar: compact
            ? FloatingNavBar(
                selectedIndex: _index,
                onSelect: (i) => setState(() => _index = i),
                destinations: dests,
              )
            : null,
      ),
    );
  }
}

class _RailMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scheme.primaryContainer,
      ),
      alignment: Alignment.center,
      child: Text(
        'ص',
        style: TextStyle(
          fontFamily: arabicFont,
          fontSize: 22,
          height: 1.1,
          fontWeight: FontWeight.w700,
          color: scheme.onPrimaryContainer,
        ),
      ),
    );
  }
}
