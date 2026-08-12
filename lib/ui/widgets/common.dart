/// Small shared widgets: the glass press highlight, the edge fade the nav bar
/// sits on, the Arabic display text, and the section header.
library;

import 'package:flutter/material.dart';

import '../../core/app_state.dart';
import '../../core/theme.dart';
import '../../sarf/arabic.dart';

/// A soft radial sheen drawn over a pressed surface. Used instead of a scale
/// transform so the highlight and the shape it sits in stay the same size.
class GlassHighlight extends StatelessWidget {
  const GlassHighlight({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    if (progress <= 0) return const SizedBox.shrink();
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.4,
            colors: [
              onSurface.withValues(alpha: 0.10 * progress),
              onSurface.withValues(alpha: 0.02 * progress),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fades scrolling content out at the top and bottom so it dissolves behind
/// the floating chrome rather than being clipped by it.
class EdgeFade extends StatelessWidget {
  const EdgeFade({
    super.key,
    required this.child,
    this.top = false,
    this.bottomHeight = 0,
    this.topHeight = 24,
  });

  final Widget child;
  final bool top;
  final double bottomHeight;
  final double topHeight;

  @override
  Widget build(BuildContext context) {
    if (!top && bottomHeight <= 0) return child;
    final h = MediaQuery.sizeOf(context).height;
    if (h <= 0) return child;
    final topStop = top ? (topHeight / h).clamp(0.0, 0.4) : 0.0;
    final botStop = (1 - bottomHeight / h).clamp(0.5, 1.0);
    return ShaderMask(
      shaderCallback: (rect) => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [
          Colors.transparent,
          Colors.black,
          Colors.black,
          Colors.transparent,
        ],
        stops: [0.0, topStop, botStop, 1.0],
      ).createShader(rect),
      blendMode: BlendMode.dstIn,
      child: child,
    );
  }
}

/// Fully-vocalised Arabic, honouring the reader's «hide the ḥarakāt» setting.
///
/// The text is *stored* vocalised always (CLAUDE.md § ۳); hiding is a display
/// choice only, offered so a student can quiz themselves.
class Ar extends StatelessWidget {
  const Ar(
    this.text, {
    super.key,
    this.style,
    this.align,
    this.maxLines,
    this.overflow,
    this.color,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? align;
  final int? maxLines;
  final TextOverflow? overflow;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    // Marks are put in written order here rather than at every call site,
    // so a literal typed into a source file renders the same as a form the
    // engine built.
    final canon = canonicalizeMarks(text);
    final shown = app.showTashkeel ? canon : stripTashkeel(canon);
    return Text(
      shown,
      textDirection: TextDirection.rtl,
      textAlign: align,
      maxLines: maxLines,
      overflow: overflow,
      style: arabicStyle(style ?? Theme.of(context).textTheme.bodyLarge)
          .copyWith(color: color),
    );
  }
}

/// Numbers in the reader's preferred digits.
String num_(BuildContext c, int n) =>
    AppScope.of(c).arabicDigits ? toArabicDigits(n) : '$n';

/// A section heading with an optional trailing action.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing, this.subtitle});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: th.textTheme.titleLarge),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle!,
                      style: th.textTheme.bodySmall?.copyWith(
                        color: th.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// A short label + value pill, used all over the identity card.
class InfoChip extends StatelessWidget {
  const InfoChip({
    super.key,
    required this.label,
    required this.value,
    this.tone,
    this.onTap,
  });

  final String label;
  final String value;
  final Color? tone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final bg = tone ?? th.colorScheme.surfaceContainerHigh;
    return Material(
      color: bg,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          // A chip lives in a Wrap, which hands it the full row width. Long
          // values — «الْبَابُ الْأَوَّلُ · ضَرَبَ يَضْرِبُ» — would otherwise
          // run off the edge, so the value is allowed to shrink and ellipsise
          // rather than overflow.
          constraints: const BoxConstraints(maxWidth: 320),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: th.textTheme.labelSmall?.copyWith(
                    color: th.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Ar(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: th.textTheme.titleSmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A staggered fade+rise, applied to list children so the screens feel built
/// rather than dumped.
class Appear extends StatelessWidget {
  const Appear({super.key, required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey('appear-$index-${child.hashCode}'),
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 320 + (index.clamp(0, 8) * 45)),
      curve: Curves.easeOutCubic,
      builder: (_, t, ch) => Opacity(
        opacity: t.clamp(0.0, 1.0),
        child: Transform.translate(offset: Offset(0, 18 * (1 - t)), child: ch),
      ),
      child: child,
    );
  }
}

Future<bool> showConfirmDialog(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      icon: Icon(icon),
      title: Text(title, textAlign: TextAlign.center),
      content: Text(message, textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(c, false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(c, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return ok ?? false;
}
