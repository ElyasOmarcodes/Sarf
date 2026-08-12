import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/strings.dart';
import '../core/theme.dart';

/// The opening screen: the name, the maxim, and the author — arriving in that
/// order so the eye lands where the app wants it to.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onDone});

  final VoidCallback onDone;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..forward();

  @override
  void initState() {
    super.initState();
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed && mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// A sub-interval of the controller, eased.
  Animation<double> _at(double begin, double end) => CurvedAnimation(
        parent: _c,
        curve: Interval(begin, end, curve: Curves.easeOutCubic),
      );

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final s = S.of(AppScope.of(context).lang);
    final scheme = th.colorScheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              scheme.surface,
              Color.alphaBlend(
                scheme.primary.withValues(alpha: 0.10),
                scheme.surface,
              ),
              scheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // The seal: ص in a soft, breathing container.
                    FadeTransition(
                      opacity: _at(0.0, 0.35),
                      child: ScaleTransition(
                        scale: Tween(begin: 0.72, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _c,
                            curve: const Interval(0, 0.45,
                                curve: Curves.easeOutBack),
                          ),
                        ),
                        child: _Seal(controller: _c),
                      ),
                    ),
                    const SizedBox(height: 36),
                    FadeTransition(
                      opacity: _at(0.22, 0.55),
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(0, 0.35),
                          end: Offset.zero,
                        ).animate(_at(0.22, 0.55)),
                        child: Text(
                          'تصريف',
                          textDirection: TextDirection.rtl,
                          style: arabicStyle(th.textTheme.displayMedium)
                              .copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurface,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    FadeTransition(
                      opacity: _at(0.42, 0.78),
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(0, 0.5),
                          end: Offset.zero,
                        ).animate(_at(0.42, 0.78)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            s.tagline,
                            textAlign: TextAlign.center,
                            textDirection: TextDirection.rtl,
                            style: arabicStyle(th.textTheme.titleMedium)
                                .copyWith(color: scheme.primary),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 40,
                child: FadeTransition(
                  opacity: _at(0.68, 1.0),
                  child: Column(
                    children: [
                      Container(
                        width: 34,
                        height: 3,
                        decoration: BoxDecoration(
                          color: scheme.outlineVariant,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        s.author,
                        textDirection: TextDirection.rtl,
                        style: th.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The ص emblem, with a halo that keeps drifting after it has arrived.
class _Seal extends StatelessWidget {
  const _Seal({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = controller.value;
        final pulse = 1 + 0.03 * (1 - (t * 2 - 1).abs());
        return Transform.scale(
          scale: pulse,
          child: Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  scheme.primaryContainer,
                  Color.alphaBlend(
                    scheme.primary.withValues(alpha: 0.22),
                    scheme.surfaceContainerHigh,
                  ),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.28 * t),
                  blurRadius: 44,
                  spreadRadius: 4,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              'ص',
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: arabicFont,
                fontSize: 74,
                height: 1.0,
                fontWeight: FontWeight.w700,
                color: scheme.onPrimaryContainer,
              ),
            ),
          ),
        );
      },
    );
  }
}
