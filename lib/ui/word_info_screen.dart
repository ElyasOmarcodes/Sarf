import 'package:flutter/material.dart';

import '../core/app_state.dart';
import '../core/strings.dart';
import '../core/theme.dart';
import '../sarf/analyzer.dart';
import '../sarf/awzan.dart';
import '../sarf/models.dart';
import '../sarf/tasrif.dart';
import 'gardan_screen.dart';
import 'widgets/common.dart';

/// What the word turned out to be, and the two doors out of it: الصرف الصغير
/// and الصرف الكبير.
class WordInfoScreen extends StatefulWidget {
  const WordInfoScreen({super.key, required this.analysis});

  final Analysis analysis;

  @override
  State<WordInfoScreen> createState() => _WordInfoScreenState();
}

class _WordInfoScreenState extends State<WordInfoScreen> {
  int _reading = 0;

  Reading get r => widget.analysis.readings[_reading];

  @override
  Widget build(BuildContext context) {
    final s = S.of(AppScope.of(context).lang);
    final th = Theme.of(context);
    final wide = !Breaks.isCompact(context);
    final sections = sectionsFor(r.spec);

    final left = <Widget>[
      Appear(index: 0, child: _IdentityCard(r: r, s: s)),
      if (widget.analysis.readings.length > 1) ...[
        Appear(index: 1, child: SectionHeader(s.otherReadings)),
        Appear(
          index: 2,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < widget.analysis.readings.length; i++)
                ChoiceChip(
                  selected: i == _reading,
                  onSelected: (_) => setState(() => _reading = i),
                  label: Ar(
                    // A participle reading and a verb reading can share a
                    // wazn, so the chip names the derived form too.
                    widget.analysis.readings[i].derived == null
                        ? widget.analysis.readings[i].wazn.madiPattern
                        : '${widget.analysis.readings[i].wazn.madiPattern}'
                            ' · ${widget.analysis.readings[i].derived!.arabic}',
                    style: th.textTheme.titleSmall,
                  ),
                ),
            ],
          ),
        ),
      ],
      Appear(index: 3, child: SectionHeader(s.sarfSaghir, subtitle: s.sarfSaghirSub)),
      Appear(index: 4, child: _SaghirCard(spec: r.spec, s: s)),
      Appear(index: 5, child: SectionHeader(s.mushtaqqat)),
      Appear(index: 6, child: _MushtaqqatCard(spec: r.spec)),
    ];

    final right = <Widget>[
      Appear(index: 7, child: SectionHeader(s.sarfKabir, subtitle: s.sarfKabirSub)),
      for (var i = 0; i < sections.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Appear(
            index: 8 + i,
            child: _SectionTile(
              section: sections[i],
              spec: r.spec,
              s: s,
            ),
          ),
        ),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _TopBar(word: widget.analysis.input)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              sliver: wide
                  ? SliverToBoxAdapter(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: left,
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: right,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SliverList.list(children: [...left, ...right]),
            ),
          ],
        ),
      ),
    );
  }
}

/// No AppBar anywhere in the app — just a back affordance and the word.
class _TopBar extends StatelessWidget {
  const _TopBar({required this.word});
  final String word;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 4),
      child: Row(
        children: [
          IconButton.filledTonal(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded),
            style: IconButton.styleFrom(shape: const StadiumBorder()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Ar(
              word,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: th.textTheme.headlineSmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.r, required this.s});

  final Reading r;
  final S s;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final scheme = th.colorScheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            scheme.primaryContainer,
            Color.alphaBlend(
              scheme.primary.withValues(alpha: 0.08),
              scheme.surfaceContainerLow,
            ),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.root,
                      style: th.textTheme.labelSmall?.copyWith(
                        color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Ar(
                      r.rootText,
                      style: th.textTheme.displaySmall?.copyWith(
                        color: scheme.onPrimaryContainer,
                        letterSpacing: 6,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    s.wazn,
                    style: th.textTheme.labelSmall?.copyWith(
                      color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Ar(
                    r.wazn.madiPattern,
                    style: th.textTheme.headlineSmall?.copyWith(
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              InfoChip(label: s.sixKinds, value: r.bina.arabic),
              InfoChip(label: s.sevenKinds, value: r.type.arabic),
              if (r.bab != null)
                InfoChip(
                  label: s.bab,
                  value:
                      '${babOrdinal(r.bab!.irshadNumber)} · ${r.bab!.exemplarMadi} ${r.bab!.exemplarMudari}',
                )
              else
                InfoChip(label: s.bab, value: r.wazn.arabicName),
              if (r.ziyada != null)
                InfoChip(label: s.ziyada, value: r.ziyada!.arabic),
              if (r.derived != null)
                InfoChip(label: s.twelveKinds, value: r.derived!.arabic),
              InfoChip(label: s.masdar, value: r.masdar),
            ],
          ),
          if (r.babProvenance == Provenance.muwallad) ...[
            const SizedBox(height: 16),
            _ProvenanceNote(
              tone: scheme.tertiaryContainer,
              onTone: scheme.onTertiaryContainer,
              label: s.muwallad,
              body: s.muwalladNote,
            ),
          ],
          if (r.wazn.meaning != null) ...[
            const SizedBox(height: 16),
            Text(
              s.meaning,
              style: th.textTheme.labelSmall?.copyWith(
                color: scheme.onPrimaryContainer.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              r.wazn.meaning!(AppScope.of(context).lang),
              style: th.textTheme.bodyMedium?.copyWith(
                color: scheme.onPrimaryContainer,
                height: 1.7,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProvenanceNote extends StatelessWidget {
  const _ProvenanceNote({
    required this.tone,
    required this.onTone,
    required this.label,
    required this.body,
  });

  final Color tone;
  final Color onTone;
  final String label;
  final String body;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: tone,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: onTone),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: th.textTheme.labelMedium?.copyWith(color: onTone),
                ),
                Text(
                  body,
                  style: th.textTheme.bodySmall
                      ?.copyWith(color: onTone, height: 1.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// الصرف الصغير as a run of tappable clauses. Each one that carries an i'lāl
/// chain shows a small badge and opens the derivation on tap.
class _SaghirCard extends StatelessWidget {
  const _SaghirCard({required this.spec, required this.s});

  final dynamic spec;
  final S s;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final items = sarfSaghir(spec);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: th.colorScheme.surfaceContainerLow,
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.start,
        children: [
          for (final it in items)
            _SaghirChip(item: it, s: s),
        ],
      ),
    );
  }
}

class _SaghirChip extends StatelessWidget {
  const _SaghirChip({required this.item, required this.s});

  final SaghirItem item;
  final S s;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final lang = AppScope.of(context).lang;
    final hasIlal = item.form?.hasIlal ?? false;
    return Material(
      color: hasIlal
          ? th.colorScheme.tertiaryContainer
          : th.colorScheme.surfaceContainerHigh,
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: item.form == null
            ? null
            : () => showIlalSheet(context, item.form!, s),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item.label(lang),
                style: th.textTheme.labelSmall?.copyWith(
                  color: th.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasIlal) ...[
                    Icon(Icons.auto_fix_high_rounded,
                        size: 14, color: th.colorScheme.onTertiaryContainer),
                    const SizedBox(width: 4),
                  ],
                  Ar(item.text, style: th.textTheme.titleMedium),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MushtaqqatCard extends StatelessWidget {
  const _MushtaqqatCard({required this.spec});

  final dynamic spec;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final items = mushtaqqatFor(spec);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: th.colorScheme.surfaceContainerLow,
      ),
      child: Column(
        children: [
          for (final m in items)
            ListTile(
              dense: true,
              title: Ar(m.arabicName, style: th.textTheme.bodyMedium),
              subtitle: Ar(
                m.pattern,
                style: th.textTheme.bodySmall?.copyWith(
                  color: th.colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: Ar(m.text, style: th.textTheme.titleLarge),
            ),
        ],
      ),
    );
  }
}

/// One row of the الصرف الكبير index.
class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.section,
    required this.spec,
    required this.s,
  });

  final SarfSection section;
  final dynamic spec;
  final S s;

  IconData get _icon => switch (section.group) {
        SectionGroup.madi => Icons.history_rounded,
        SectionGroup.mudari => Icons.schedule_rounded,
        SectionGroup.amr => Icons.campaign_rounded,
        SectionGroup.nahy => Icons.block_rounded,
        SectionGroup.mushtaqqat => Icons.account_tree_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    final lang = AppScope.of(context).lang;
    final forms = section.build(spec);
    final preview = forms.take(3).map((f) => f.text).join(' · ');
    final ilalCount = forms.where((f) => f.hasIlal).length;

    return Material(
      color: th.colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GardanScreen(section: section, spec: spec),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: th.colorScheme.secondaryContainer,
                ),
                alignment: Alignment.center,
                child: Icon(_icon,
                    size: 20, color: th.colorScheme.onSecondaryContainer),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Ar(
                            section.arabicTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: th.textTheme.titleSmall,
                          ),
                        ),
                        _CountBadge(
                          text:
                              '${num_(context, section.sighas)} ${s.sighaCount}',
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Ar(
                      preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: th.textTheme.bodySmall?.copyWith(
                        color: th.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (ilalCount > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            Icon(Icons.auto_fix_high_rounded,
                                size: 13, color: th.colorScheme.tertiary),
                            const SizedBox(width: 4),
                            Text(
                              '${num_(context, ilalCount)} ${s.hasIlal}',
                              style: th.textTheme.labelSmall?.copyWith(
                                color: th.colorScheme.tertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Text(
                      section.title(lang),
                      style: th.textTheme.labelSmall?.copyWith(
                        color: th.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right_rounded,
                  color: th.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final th = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: th.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(text, style: th.textTheme.labelSmall),
    );
  }
}
