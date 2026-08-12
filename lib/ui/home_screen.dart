import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_state.dart';
import '../core/strings.dart';
import '../core/theme.dart';
import '../sarf/analyzer.dart';
import 'widgets/common.dart';
import 'word_info_screen.dart';

/// Where the word gets typed. Deliberately not a plain TextField: the input is
/// the whole point of the app, so it is a raised, focused slate with the
/// analyse action fused onto it.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  String? _error;

  static const _examples = [
    'ضَرَبَ',
    'نَصَرَ',
    'قَالَ',
    'دَحْرَجَ',
    'اِكْتَسَبَ',
    'وَعَدَ',
    'رَمَى',
    'مَدَّ',
    'أَكْرَمَ',
    'اسْتَخْرَجَ',
    'خَافَ',
    'مَضْرُوب',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _run([String? word]) {
    final raw = (word ?? _controller.text).trim();
    final s = S.of(AppScope.of(context).lang);
    if (raw.isEmpty) {
      setState(() => _error = s.enterWord);
      return;
    }
    final analysis = analyze(raw);
    if (analysis.isEmpty) {
      setState(() => _error = s.notRecognised);
      return;
    }
    setState(() => _error = null);
    AppScope.of(context).pushRecent(raw);
    FocusScope.of(context).unfocus();
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 380),
        reverseTransitionDuration: const Duration(milliseconds: 260),
        pageBuilder: (_, a, __) => FadeTransition(
          opacity: a,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, 0.04), end: Offset.zero)
                .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
            child: WordInfoScreen(analysis: analysis),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final s = S.of(app.lang);
    final th = Theme.of(context);
    final wide = !Breaks.isCompact(context);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20, 24, 20, 0),
          sliver: SliverList.list(
            children: [
              Appear(index: 0, child: _Masthead(s: s)),
              const SizedBox(height: 28),
              Appear(
                index: 1,
                child: _WordSlate(
                  controller: _controller,
                  focus: _focus,
                  error: _error,
                  hint: s.enterWordHint,
                  label: s.enterWord,
                  actionLabel: s.process,
                  onSubmit: _run,
                ),
              ),
              const SizedBox(height: 8),
              Appear(
                index: 2,
                child: SectionHeader(s.examples),
              ),
              Appear(
                index: 3,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final e in _examples)
                      ActionChip(
                        label: Ar(e, style: th.textTheme.titleSmall),
                        onPressed: () {
                          _controller.text = e;
                          _run(e);
                        },
                      ),
                  ],
                ),
              ),
              if (app.recent.isNotEmpty) ...[
                Appear(
                  index: 4,
                  child: SectionHeader(
                    s.recent,
                    trailing: TextButton(
                      onPressed: app.clearRecent,
                      child: Text(s.clearRecent),
                    ),
                  ),
                ),
                Appear(
                  index: 5,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final r in app.recent)
                        ActionChip(
                          avatar: const Icon(Icons.history_rounded, size: 18),
                          label: Ar(r, style: th.textTheme.titleSmall),
                          onPressed: () {
                            _controller.text = r;
                            _run(r);
                          },
                        ),
                    ],
                  ),
                ),
              ],
              Appear(index: 6, child: SectionHeader(s.howItWorks)),
              Appear(
                index: 7,
                child: _InfoCard(
                  icon: Icons.auto_awesome_rounded,
                  title: s.howItWorks,
                  body: s.howItWorksBody,
                ),
              ),
              const SizedBox(height: 12),
              Appear(
                index: 8,
                child: _InfoCard(
                  icon: Icons.menu_book_rounded,
                  title: s.sourcesTitle,
                  body: s.sourcesBody,
                  tonal: true,
                ),
              ),
              SizedBox(height: wide ? 40 : 140),
            ],
          ),
        ),
      ],
    );
  }
}

class _Masthead extends StatelessWidget {
  const _Masthead({required this.s});
  final S s;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: th.colorScheme.primaryContainer,
              ),
              alignment: Alignment.center,
              child: Text(
                'ص',
                style: TextStyle(
                  fontFamily: arabicFont,
                  fontSize: 26,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  color: th.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(s.appName, style: th.textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Ar(
                    s.tagline,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: th.textTheme.labelSmall?.copyWith(
                      color: th.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// The input surface. A tall, tactile slate with the word centred in display
/// type — what you type looks the way it will look in the tables.
class _WordSlate extends StatefulWidget {
  const _WordSlate({
    required this.controller,
    required this.focus,
    required this.error,
    required this.hint,
    required this.label,
    required this.actionLabel,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final FocusNode focus;
  final String? error;
  final String hint;
  final String label;
  final String actionLabel;
  final void Function([String?]) onSubmit;

  @override
  State<_WordSlate> createState() => _WordSlateState();
}

class _WordSlateState extends State<_WordSlate> {
  @override
  void initState() {
    super.initState();
    widget.focus.addListener(_onFocus);
    widget.controller.addListener(_onText);
  }

  @override
  void dispose() {
    widget.focus.removeListener(_onFocus);
    widget.controller.removeListener(_onText);
    super.dispose();
  }

  void _onFocus() => setState(() {});
  void _onText() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final scheme = th.colorScheme;
    final focused = widget.focus.hasFocus;
    final hasError = widget.error != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        color: focused
            ? Color.alphaBlend(
                scheme.primary.withValues(alpha: 0.06),
                scheme.surfaceContainerLow,
              )
            : scheme.surfaceContainerLow,
        border: Border.all(
          color: hasError
              ? scheme.error
              : focused
                  ? scheme.primary
                  : scheme.outlineVariant.withValues(alpha: 0.5),
          width: focused || hasError ? 2 : 1,
        ),
        boxShadow: focused
            ? [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.14),
                  blurRadius: 28,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.label,
            style: th.textTheme.labelLarge?.copyWith(color: scheme.primary),
          ),
          const SizedBox(height: 6),
          Directionality(
            textDirection: TextDirection.rtl,
            child: TextField(
              controller: widget.controller,
              focusNode: widget.focus,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              autocorrect: false,
              enableSuggestions: false,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => widget.onSubmit(),
              inputFormatters: [LengthLimitingTextInputFormatter(24)],
              style: th.textTheme.displaySmall?.copyWith(
                fontFamily: arabicFont,
                fontWeight: FontWeight.w700,
              ),
              decoration: InputDecoration(
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                hintText: widget.hint,
                hintStyle: th.textTheme.titleMedium?.copyWith(
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
                suffixIcon: widget.controller.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => widget.controller.clear(),
                      ),
              ),
            ),
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 4),
              child: Text(
                widget.error!,
                textAlign: TextAlign.center,
                style: th.textTheme.bodySmall?.copyWith(color: scheme.error),
              ),
            ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => widget.onSubmit(),
            icon: const Icon(Icons.auto_fix_high_rounded),
            label: Text(widget.actionLabel),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
    this.tonal = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final bool tonal;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final scheme = th.colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: tonal
            ? scheme.secondaryContainer.withValues(alpha: 0.55)
            : scheme.surfaceContainerLow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scheme.surface.withValues(alpha: 0.6),
            ),
            child: Icon(icon, size: 20, color: scheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: th.textTheme.titleSmall),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: th.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.7,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
