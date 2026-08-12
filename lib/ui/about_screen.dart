import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_state.dart';
import '../core/strings.dart';
import '../core/theme.dart';
import 'widgets/common.dart';

const String kAppVersion = '1.0.0';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final s = S.of(app.lang);
    final th = Theme.of(context);
    final scheme = th.colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 140),
      children: [
        Appear(
          index: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [scheme.primaryContainer, scheme.surfaceContainerLow],
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.surface.withValues(alpha: 0.7),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'ص',
                    style: TextStyle(
                      fontFamily: arabicFont,
                      fontSize: 42,
                      height: 1.1,
                      fontWeight: FontWeight.w700,
                      color: scheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(s.appName, style: th.textTheme.headlineSmall),
                const SizedBox(height: 4),
                Ar(
                  s.tagline,
                  align: TextAlign.center,
                  style: th.textTheme.bodyMedium?.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: scheme.surface.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Text(
                    '${s.version} $kAppVersion',
                    style: th.textTheme.labelSmall,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  s.author,
                  style: th.textTheme.titleSmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
        Appear(index: 1, child: SectionHeader(s.about)),
        Appear(
          index: 2,
          child: _Panel(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                s.aboutBody,
                style: th.textTheme.bodyMedium?.copyWith(height: 1.8),
              ),
            ),
          ),
        ),
        Appear(index: 3, child: SectionHeader(s.sources)),
        Appear(
          index: 4,
          child: _Panel(
            child: Column(
              children: [
                _SourceTile(
                  title: 'شَذَا الْعَرْفِ فِي فَنِّ الصَّرْفِ',
                  author: 'أحمد بن محمد الحملاوي',
                ),
                const Divider(height: 1, indent: 20, endIndent: 20),
                _SourceTile(
                  title: 'إِرْشَادُ الصَّرْفِ',
                  author: 'مولانا عبد الكريم القلاتوالي — الأصل الفارسي',
                ),
                const Divider(height: 1, indent: 20, endIndent: 20),
                _SourceTile(
                  title: 'إِرْشَادُ الصَّرْفِ بِاللُّغَةِ الْعَرَبِيَّةِ',
                  author: 'تعريب منظور أحمد شاه الديروي',
                ),
              ],
            ),
          ),
        ),
        Appear(index: 5, child: SectionHeader('')),
        Appear(
          index: 6,
          child: _Panel(
            child: Column(
              children: [
                _ActionTile(
                  icon: Icons.star_rounded,
                  title: s.rateApp,
                  subtitle: s.rateAppSub,
                  onTap: () => _soon(context, s),
                ),
                const Divider(height: 1, indent: 20, endIndent: 20),
                _ActionTile(
                  icon: Icons.bug_report_rounded,
                  title: s.reportBug,
                  subtitle: s.reportBugSub,
                  onTap: () => _soon(context, s),
                ),
                const Divider(height: 1, indent: 20, endIndent: 20),
                _ActionTile(
                  icon: Icons.ios_share_rounded,
                  title: s.share,
                  onTap: () {
                    Clipboard.setData(
                      const ClipboardData(text: 'تصريف — د علم صرف اپلیکېشن'),
                    );
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(s.copied)));
                  },
                ),
                const Divider(height: 1, indent: 20, endIndent: 20),
                _ActionTile(
                  icon: Icons.privacy_tip_rounded,
                  title: s.privacy,
                  onTap: () => showModalBottomSheet<void>(
                    context: context,
                    builder: (c) => Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.privacy, style: th.textTheme.titleLarge),
                          const SizedBox(height: 12),
                          Text(
                            s.privacyBody,
                            style:
                                th.textTheme.bodyMedium?.copyWith(height: 1.8),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 20, endIndent: 20),
                _ActionTile(
                  icon: Icons.description_rounded,
                  title: s.licences,
                  subtitle: 'Amiri — SIL Open Font License 1.1',
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: s.appName,
                    applicationVersion: kAppVersion,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _soon(BuildContext context, S s) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s.rateAppSub)),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: Theme.of(context).colorScheme.surfaceContainerLow,
        ),
        clipBehavior: Clip.antiAlias,
        child: child,
      );
}

class _SourceTile extends StatelessWidget {
  const _SourceTile({required this.title, required this.author});
  final String title;
  final String author;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: th.colorScheme.secondaryContainer,
        child: Icon(Icons.menu_book_rounded,
            size: 18, color: th.colorScheme.onSecondaryContainer),
      ),
      title: Ar(title, style: th.textTheme.titleSmall),
      subtitle: Ar(
        author,
        style: th.textTheme.bodySmall?.copyWith(
          color: th.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: th.colorScheme.primary),
      title: Text(title, style: th.textTheme.titleSmall),
      subtitle: subtitle == null
          ? null
          : Text(
              subtitle!,
              style: th.textTheme.bodySmall?.copyWith(
                color: th.colorScheme.onSurfaceVariant,
              ),
            ),
      trailing: Icon(Icons.chevron_right_rounded,
          color: th.colorScheme.onSurfaceVariant),
    );
  }
}
