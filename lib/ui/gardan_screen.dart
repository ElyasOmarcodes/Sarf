import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_state.dart';
import '../core/strings.dart';
import '../core/theme.dart';
import '../sarf/conjugator.dart';
import '../sarf/models.dart';
import '../sarf/tasrif.dart';
import 'widgets/common.dart';

/// One table of the الصرف الكبير: number · form · ṣīgha, exactly the three
/// columns the book prints. Rows that underwent i'lāl carry a badge and open
/// their derivation.
class GardanScreen extends StatefulWidget {
  const GardanScreen({super.key, required this.section, required this.spec});

  final SarfSection section;
  final VerbSpec spec;

  @override
  State<GardanScreen> createState() => _GardanScreenState();
}

class _GardanScreenState extends State<GardanScreen> {
  bool _grid = false;

  @override
  Widget build(BuildContext context) {
    final s = S.of(AppScope.of(context).lang);
    final forms = widget.section.build(widget.spec);
    final wide = !Breaks.isCompact(context);
    final columns = wide ? (Breaks.isExpanded(context) ? 3 : 2) : 1;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              section: widget.section,
              spec: widget.spec,
              s: s,
              grid: _grid,
              onToggle: () => setState(() => _grid = !_grid),
            ),
            Expanded(
              child: _grid || columns > 1
                  ? GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _grid ? (wide ? 4 : 2) : columns,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: _grid ? 1.35 : 2.6,
                      ),
                      itemCount: forms.length,
                      itemBuilder: (c, i) => Appear(
                        index: i,
                        child: _FormCard(
                          form: forms[i],
                          index: i + 1,
                          s: s,
                          compact: _grid,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                      itemCount: forms.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (c, i) => Appear(
                        index: i,
                        child: _FormRow(
                          form: forms[i],
                          index: i + 1,
                          s: s,
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: forms.any((f) => f.hasIlal)
          ? FloatingActionButton.extended(
              onPressed: () => _showAllIlal(context, forms, s),
              icon: const Icon(Icons.auto_fix_high_rounded),
              label: Text(s.derivation),
              shape: const StadiumBorder(),
            )
          : null,
    );
  }

  void _showAllIlal(
      BuildContext context, List<SighaForm> forms, S s) {
    final withIlal = forms.where((f) => f.hasIlal).toList();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (c) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (c, ctrl) => ListView.separated(
          controller: ctrl,
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          itemCount: withIlal.length,
          separatorBuilder: (_, __) => const Divider(height: 32),
          itemBuilder: (c, i) => _IlalBody(form: withIlal[i], s: s),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.section,
    required this.spec,
    required this.s,
    required this.grid,
    required this.onToggle,
  });

  final SarfSection section;
  final VerbSpec spec;
  final S s;
  final bool grid;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final lang = AppScope.of(context).lang;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton.filledTonal(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(shape: const StadiumBorder()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Ar(section.arabicTitle, style: th.textTheme.titleLarge),
                const SizedBox(height: 2),
                Text(
                  '${section.title(lang)} · ${num_(context, section.sighas)} ${s.sighaCount}',
                  style: th.textTheme.bodySmall?.copyWith(
                    color: th.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onToggle,
            tooltip: grid ? s.listView : s.gridView,
            icon: Icon(grid
                ? Icons.view_list_rounded
                : Icons.grid_view_rounded),
          ),
        ],
      ),
    );
  }
}

/// The list presentation: a real three-column row, since that is how the book
/// lays a gardān out and how a student reads one.
class _FormRow extends StatelessWidget {
  const _FormRow({required this.form, required this.index, required this.s});

  final SighaForm form;
  final int index;
  final S s;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final scheme = th.colorScheme;
    return Material(
      color: form.hasIlal
          ? scheme.tertiaryContainer.withValues(alpha: 0.45)
          : scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showIlalSheet(context, form, s),
        onLongPress: () {
          Clipboard.setData(ClipboardData(text: form.text));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(s.copied)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Row(
            children: [
              // ── الرقم ──
              SizedBox(
                width: 30,
                child: Text(
                  num_(context, index),
                  textAlign: TextAlign.center,
                  style: th.textTheme.labelLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // ── الكلمة ──
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    Flexible(
                      child: Ar(
                        form.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: th.textTheme.headlineSmall,
                      ),
                    ),
                    if (form.hasIlal)
                      Padding(
                        padding: const EdgeInsets.only(right: 6, left: 6),
                        child: Icon(Icons.auto_fix_high_rounded,
                            size: 15, color: scheme.tertiary),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // ── الصيغة ──
              Expanded(
                flex: 5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Ar(
                      form.sigha.arabicName,
                      align: TextAlign.end,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: th.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                    Ar(
                      form.sigha.pronoun,
                      style: th.textTheme.labelSmall?.copyWith(
                        color: scheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The grid presentation: the form large, its ṣīgha beneath it in short form.
class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.form,
    required this.index,
    required this.s,
    required this.compact,
  });

  final SighaForm form;
  final int index;
  final S s;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final scheme = th.colorScheme;
    return Material(
      color: form.hasIlal
          ? scheme.tertiaryContainer.withValues(alpha: 0.45)
          : scheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => showIlalSheet(context, form, s),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    num_(context, index),
                    style: th.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  if (form.hasIlal)
                    Icon(Icons.auto_fix_high_rounded,
                        size: 13, color: scheme.tertiary),
                ],
              ),
              const Spacer(),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Ar(form.text, style: th.textTheme.headlineSmall),
              ),
              const Spacer(),
              Ar(
                form.sigha.pronoun,
                style: th.textTheme.labelSmall?.copyWith(color: scheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// The derivation sheet — the app's actual answer to «ولې؟»
// ═══════════════════════════════════════════════════════════════════════════

void showIlalSheet(BuildContext context, SighaForm form, S s) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (c) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: form.hasIlal ? 0.62 : 0.4,
      maxChildSize: 0.92,
      builder: (c, ctrl) => SingleChildScrollView(
        controller: ctrl,
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 36),
        child: _IlalBody(form: form, s: s),
      ),
    ),
  );
}

class _IlalBody extends StatelessWidget {
  const _IlalBody({required this.form, required this.s});

  final SighaForm form;
  final S s;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final scheme = th.colorScheme;
    final lang = AppScope.of(context).lang;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Ar(form.text, style: th.textTheme.displaySmall),
        ),
        const SizedBox(height: 4),
        Center(
          child: Ar(
            form.sigha.arabicName,
            align: TextAlign.center,
            style: th.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (!form.hasIlal)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline_rounded,
                    color: scheme.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(s.noIlalBody, style: th.textTheme.bodyMedium),
                ),
              ],
            ),
          )
        else ...[
          // الأصل → النتيجة, at a glance.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _Labelled(
                    label: s.original,
                    value: form.underlying,
                    tone: scheme.onSurfaceVariant,
                  ),
                ),
                Icon(Icons.arrow_back_rounded, color: scheme.primary),
                Expanded(
                  child: _Labelled(
                    label: s.result,
                    value: form.text,
                    tone: scheme.primary,
                    end: true,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            '${s.steps} · ${num_(context, form.steps.length)}',
            style: th.textTheme.titleSmall,
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < form.steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _StepCard(
                step: form.steps[i],
                index: i + 1,
                lang: lang,
                s: s,
              ),
            ),
        ],
      ],
    );
  }
}

class _Labelled extends StatelessWidget {
  const _Labelled({
    required this.label,
    required this.value,
    required this.tone,
    this.end = false,
  });

  final String label;
  final String value;
  final Color tone;
  final bool end;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    return Column(
      crossAxisAlignment:
          end ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: th.textTheme.labelSmall?.copyWith(color: tone)),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Ar(value, style: th.textTheme.headlineSmall?.copyWith(color: tone)),
        ),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.step,
    required this.index,
    required this.lang,
    required this.s,
  });

  final dynamic step;
  final int index;
  final dynamic lang;
  final S s;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final scheme = th.colorScheme;
    final info = step.info;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.primaryContainer,
                ),
                alignment: Alignment.center,
                child: Text(
                  num_(context, index),
                  style: th.textTheme.labelSmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Ar(info.arabicName, style: th.textTheme.titleSmall),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Ar(step.before as String, style: th.textTheme.titleLarge),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.arrow_back_rounded,
                    size: 18, color: scheme.primary),
              ),
              Ar(
                step.after as String,
                style: th.textTheme.titleLarge?.copyWith(color: scheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            info.taleel(lang) as String,
            style: th.textTheme.bodyMedium?.copyWith(height: 1.75),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.menu_book_rounded,
                  size: 14, color: scheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Expanded(
                child: Ar(
                  info.source as String,
                  style: th.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
