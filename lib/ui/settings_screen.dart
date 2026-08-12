import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/strings.dart';
import '../core/theme.dart';
import '../sarf/lang.dart';
import 'widgets/common.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final s = S.of(app.lang);
    final th = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 140),
      children: [
        Appear(
          index: 0,
          child: Text(s.settings, style: th.textTheme.headlineMedium),
        ),
        Appear(index: 1, child: SectionHeader(s.language, subtitle: s.languageSub)),
        Appear(
          index: 2,
          child: _Card(
            child: RadioGroup<Lang>(
              groupValue: app.lang,
              onChanged: (v) {
                if (v != null) app.lang = v;
              },
              child: Column(
                children: [
                  for (final l in Lang.values)
                    RadioListTile<Lang>(
                      value: l,
                      title:
                          Text(l.nativeName, style: th.textTheme.titleSmall),
                      subtitle: Text(
                        l.code.toUpperCase(),
                        style: th.textTheme.labelSmall?.copyWith(
                          color: th.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        Appear(index: 3, child: SectionHeader(s.appearance)),
        Appear(
          index: 4,
          child: Row(
            children: [
              for (final m in ThemeMode.values)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _ThemeCard(
                      mode: m,
                      selected: app.themeMode == m,
                      label: switch (m) {
                        ThemeMode.light => s.light,
                        ThemeMode.dark => s.dark,
                        ThemeMode.system => s.system,
                      },
                      onTap: () => app.themeMode = m,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Appear(index: 5, child: SectionHeader(s.typography)),
        Appear(
          index: 6,
          child: _Card(
            child: Column(
              children: [
                SwitchListTile(
                  value: app.showTashkeel,
                  onChanged: (v) => app.showTashkeel = v,
                  title: Text(s.showTashkeel, style: th.textTheme.titleSmall),
                  subtitle: Text(
                    s.showTashkeelSub,
                    style: th.textTheme.bodySmall?.copyWith(
                      color: th.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  secondary: const Icon(Icons.format_size_rounded),
                ),
                const Divider(height: 1, indent: 20, endIndent: 20),
                SwitchListTile(
                  value: app.arabicDigits,
                  onChanged: (v) => app.arabicDigits = v,
                  title: Text(s.arabicNumerals, style: th.textTheme.titleSmall),
                  subtitle: Text(
                    s.arabicNumeralsSub,
                    style: th.textTheme.bodySmall?.copyWith(
                      color: th.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  secondary: const Icon(Icons.pin_rounded),
                ),
                const Divider(height: 1, indent: 20, endIndent: 20),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                  child: Row(
                    children: [
                      const Icon(Icons.text_fields_rounded, size: 20),
                      const SizedBox(width: 16),
                      Text(s.textSize, style: th.textTheme.titleSmall),
                      const Spacer(),
                      Text(
                        '${(app.textScale * 100).round()}%',
                        style: th.textTheme.labelMedium?.copyWith(
                          color: th.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Slider(
                  value: app.textScale,
                  min: 0.85,
                  max: 1.4,
                  divisions: 11,
                  onChanged: (v) => app.textScale = v,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Ar(
                    'ضَرَبَ يَضْرِبُ ضَرْبًا',
                    align: TextAlign.center,
                    style: th.textTheme.titleLarge,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Theme.of(context).colorScheme.surfaceContainerLow,
        ),
        child: child,
      );
}

/// A live preview rather than a swatch: each card paints its own scheme, so
/// picking a theme shows what you are picking.
class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.mode,
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final ThemeMode mode;
  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final platformDark =
        MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final b = switch (mode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => platformDark ? Brightness.dark : Brightness.light,
    };
    final preview = ColorScheme.fromSeed(seedColor: seed, brightness: b);
    final th = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected
                  ? th.colorScheme.primary
                  : th.colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              // A miniature of the app: surface, a title bar, two rows, a pill.
              AspectRatio(
                aspectRatio: 0.78,
                child: Container(
                  decoration: BoxDecoration(
                    color: preview.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.all(7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: preview.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 5),
                      for (var i = 0; i < 2; i++) ...[
                        Container(
                          height: 7,
                          decoration: BoxDecoration(
                            color: preview.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      const Spacer(),
                      Center(
                        child: Container(
                          height: 11,
                          width: 34,
                          decoration: BoxDecoration(
                            color: preview.primary,
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: th.textTheme.labelMedium?.copyWith(
                  color: selected ? th.colorScheme.primary : null,
                  fontWeight: selected ? FontWeight.w700 : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
