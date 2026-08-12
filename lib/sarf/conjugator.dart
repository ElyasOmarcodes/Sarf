/// The gardān engine: builds the أصل of every ṣīgha, then runs the i'lāl
/// rules over it and keeps the receipt.
///
/// The design follows the books' own method. Nothing is looked up as a
/// finished form; each cell is *derived* — قَوَلَ is built first and only then
/// becomes قَالَ, because that intermediate is exactly what the reader wants
/// to see (docs/sarf/README.md § ۲).
library;

import 'arabic.dart';
import 'awzan.dart';
import 'lang.dart';
import 'lexicon.dart';
import 'models.dart';
import 'rules.dart';

enum Tense { madi, mudari, amr }

enum Voice { maalum, majhul }

/// The muḍāriʿ's three states. جزم is what لم and the amr impose, and it is
/// the trigger for most of the ḥadhf rules.
enum Mood { marfu, mansub, majzum }

enum Tawkid { bidun, thaqila, khafifa }

// ═══════════════════════════════════════════════════════════════════════════
// What we are conjugating
// ═══════════════════════════════════════════════════════════════════════════

class VerbSpec {
  const VerbSpec({
    required this.root,
    required this.wazn,
    required this.type,
    this.bab,
    this.babProvenance = Provenance.muwallad,
    this.masdar,
  });

  /// Root letters, hamza folded to ء. 3, 4 or 5 of them.
  final List<String> root;
  final Wazn wazn;
  final SahihMutal type;

  /// Only meaningful for the ثلاثي مجرد — the mazīd awzān each carry their
  /// own fixed vowelling.
  final Bab? bab;
  final Provenance babProvenance;

  /// The maṣdar, which for the mujarrad is سماعي and comes from the lexicon.
  final String? masdar;

  String get f => root[0];
  String get a => root.length > 1 ? root[1] : root[0];
  String get l => root.length > 2 ? root[2] : root[root.length - 1];
  String get l2 => root.length > 3 ? root[3] : l;
  String get l3 => root.length > 4 ? root[4] : l2;

  bool get isMujarrad3 => wazn.id == 'mujarrad3';

  /// ع and ل identical — the مضاعف. docs/sarf/01-bunyaad.md § التقسیم ۲
  bool get isMudaaf => root.length >= 3 && a == l;

  Hrk get madiAynVowel => bab?.madiVowel ?? Hrk.fatha;
  Hrk get mudariAynVowel => bab?.mudariVowel ?? Hrk.kasra;

  /// The maṣdar to actually show. A spec may be built without one — from a
  /// test, or from a root the analyser reached by a route that did not carry
  /// it — and the ṣarf ṣaghīr is meaningless without its opening word, so it
  /// falls back to the lexicon and then to the قياسي pattern.
  String get resolvedMasdar {
    final m = masdar;
    if (m != null && m.isNotEmpty) return m;
    final entry = lookup(root);
    if (entry != null && isMujarrad3) return entry.masdar;
    if (isMujarrad3) return qiyasiMasdar(root, bab ?? babDarb);
    return wazn.masdarPattern;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// A form under construction
// ═══════════════════════════════════════════════════════════════════════════

/// Letters plus a live map from root position (0=ف 1=ع 2=ل …) to index, so a
/// rule can ask for "the ʿayn" after earlier rules have inserted or dropped
/// letters around it.
class Frame {
  Frame(this.ls, this.idx);

  final List<Ltr> ls;
  final Map<int, int> idx;

  int? posOf(int rootPos) => idx[rootPos];

  Ltr? at(int rootPos) {
    final i = idx[rootPos];
    return i == null || i >= ls.length ? null : ls[i];
  }

  void set(int rootPos, Ltr v) {
    final i = idx[rootPos];
    if (i != null && i < ls.length) ls[i] = v;
  }

  void removeAt(int i) {
    ls.removeAt(i);
    idx.updateAll((_, v) => v > i ? v - 1 : v);
    idx.removeWhere((_, v) => v == i && false);
    // A root letter that *was* at i is now gone; point it at nothing.
    final gone = idx.entries.where((e) => e.value == i).map((e) => e.key).toList();
    for (final k in gone) {
      idx.remove(k);
    }
  }

  void insertAt(int i, Ltr v) {
    ls.insert(i, v);
    idx.updateAll((_, x) => x >= i ? x + 1 : x);
  }

  String get text => renderLetters(ls);

  Frame clone() => Frame(List<Ltr>.from(ls), Map<int, int>.from(idx));
}

/// Everything a rule may need to know about the cell it is looking at.
class Ctx {
  const Ctx({
    required this.spec,
    required this.tense,
    required this.voice,
    required this.sigha,
    required this.mood,
    required this.tawkid,
  });

  final VerbSpec spec;
  final Tense tense;
  final Voice voice;
  final Sigha sigha;
  final Mood mood;
  final Tawkid tawkid;
}

/// One finished cell of a table.
class SighaForm {
  const SighaForm({
    required this.sigha,
    required this.text,
    required this.underlying,
    required this.steps,
    this.prefix = '',
  });

  final Sigha sigha;

  /// The final, fully-vocalised form — including any لَا / لَمْ / لَنْ.
  final String text;

  /// The أصل before any i'lāl. Equal to [text] when nothing fired.
  final String underlying;

  final List<IlalStep> steps;

  /// The particle shown ahead of the verb, kept separate so tables can align.
  final String prefix;

  bool get hasIlal => steps.isNotEmpty;
}

// ═══════════════════════════════════════════════════════════════════════════
// Stem construction — the أصل, before any rule has run
// ═══════════════════════════════════════════════════════════════════════════

const _wasl = alif; // همزة الوصل, rendered as a bare alif with its vowel

/// The māḍī stem, up to and including the لام, whose vowel the caller sets.
Frame _madiStem(VerbSpec s, Voice v, Hrk lamH) {
  final ls = <Ltr>[];
  final idx = <int, int>{};
  void root(int p, Hrk h, {bool sh = false}) {
    idx[p] = ls.length;
    ls.add(Ltr(switch (p) { 0 => s.f, 1 => s.a, 2 => s.l, 3 => s.l2, _ => s.l3 }, h, sh));
  }

  void lit(String c, Hrk h, {bool sh = false}) => ls.add(Ltr(c, h, sh));

  final maalum = v == Voice.maalum;
  switch (s.wazn.id) {
    case 'mujarrad3':
      root(0, maalum ? Hrk.fatha : Hrk.damma);
      root(1, maalum ? s.madiAynVowel : Hrk.kasra);
      root(2, lamH);
    case 'ifal':
      lit(hamza, maalum ? Hrk.fatha : Hrk.damma);
      root(0, Hrk.sukun);
      root(1, maalum ? Hrk.fatha : Hrk.kasra);
      root(2, lamH);
    case 'tafil':
      root(0, maalum ? Hrk.fatha : Hrk.damma);
      root(1, maalum ? Hrk.fatha : Hrk.kasra, sh: true);
      root(2, lamH);
    case 'mufaala':
      root(0, maalum ? Hrk.fatha : Hrk.damma);
      lit(alif, Hrk.none);
      root(1, maalum ? Hrk.fatha : Hrk.kasra);
      root(2, lamH);
    case 'tafaul':
      lit(ta, maalum ? Hrk.fatha : Hrk.damma);
      root(0, maalum ? Hrk.fatha : Hrk.damma);
      root(1, maalum ? Hrk.fatha : Hrk.kasra, sh: true);
      root(2, lamH);
    case 'tafaaul':
      lit(ta, maalum ? Hrk.fatha : Hrk.damma);
      root(0, maalum ? Hrk.fatha : Hrk.damma);
      lit(alif, Hrk.none);
      root(1, maalum ? Hrk.fatha : Hrk.kasra);
      root(2, lamH);
    case 'iftial':
      lit(_wasl, maalum ? Hrk.kasra : Hrk.damma);
      root(0, Hrk.sukun);
      lit(ta, maalum ? Hrk.fatha : Hrk.damma);
      root(1, maalum ? Hrk.fatha : Hrk.kasra);
      root(2, lamH);
    case 'infial':
      lit(_wasl, maalum ? Hrk.kasra : Hrk.damma);
      lit(nun, Hrk.sukun);
      root(0, maalum ? Hrk.fatha : Hrk.damma);
      root(1, maalum ? Hrk.fatha : Hrk.kasra);
      root(2, lamH);
    case 'istifal':
      lit(_wasl, maalum ? Hrk.kasra : Hrk.damma);
      lit(sin, Hrk.sukun);
      lit(ta, maalum ? Hrk.fatha : Hrk.damma);
      root(0, Hrk.sukun);
      root(1, maalum ? Hrk.fatha : Hrk.kasra);
      root(2, lamH);
    case 'ifilal':
      lit(_wasl, Hrk.kasra);
      root(0, Hrk.sukun);
      root(1, Hrk.fatha);
      root(2, Hrk.sukun);
      lit(s.l, lamH); // the doubled lām; الإدغام merges it below
    case 'ifilal2':
      lit(_wasl, Hrk.kasra);
      root(0, Hrk.sukun);
      root(1, Hrk.fatha);
      lit(alif, Hrk.none);
      root(2, Hrk.sukun);
      lit(s.l, lamH);
    case 'ifiwwal':
      lit(_wasl, Hrk.kasra);
      root(0, Hrk.sukun);
      root(1, Hrk.fatha);
      lit(waw, Hrk.fatha, sh: true);
      root(2, lamH);
    case 'ifiyal':
      lit(_wasl, Hrk.kasra);
      root(0, Hrk.sukun);
      root(1, Hrk.fatha);
      lit(waw, Hrk.sukun);
      lit(s.a, Hrk.fatha);
      root(2, lamH);
    case 'falala':
      root(0, maalum ? Hrk.fatha : Hrk.damma);
      root(1, Hrk.sukun);
      root(2, maalum ? Hrk.fatha : Hrk.kasra);
      root(3, lamH);
    case 'tafalul':
      lit(ta, maalum ? Hrk.fatha : Hrk.damma);
      root(0, maalum ? Hrk.fatha : Hrk.damma);
      root(1, Hrk.sukun);
      root(2, maalum ? Hrk.fatha : Hrk.kasra);
      root(3, lamH);
    case 'ifanlal':
      lit(_wasl, maalum ? Hrk.kasra : Hrk.damma);
      root(0, Hrk.sukun);
      root(1, maalum ? Hrk.fatha : Hrk.damma);
      lit(nun, Hrk.sukun);
      root(2, maalum ? Hrk.fatha : Hrk.kasra);
      root(3, lamH);
    case 'ifillal':
      lit(_wasl, Hrk.kasra);
      root(0, Hrk.sukun);
      root(1, Hrk.fatha);
      root(2, Hrk.sukun);
      root(3, lamH);
    default:
      root(0, maalum ? Hrk.fatha : Hrk.damma);
      root(1, maalum ? Hrk.fatha : Hrk.kasra);
      root(2, lamH);
  }
  return Frame(ls, idx);
}

/// The muḍāriʿ stem *after* its prefix, whose vowel the caller sets on the
/// prefix letter.
({Frame frame, Hrk prefixVowel}) _mudariStem(VerbSpec s, Voice v, Hrk lamH) {
  final ls = <Ltr>[];
  final idx = <int, int>{};
  void root(int p, Hrk h, {bool sh = false}) {
    idx[p] = ls.length;
    ls.add(Ltr(switch (p) { 0 => s.f, 1 => s.a, 2 => s.l, 3 => s.l2, _ => s.l3 }, h, sh));
  }

  void lit(String c, Hrk h, {bool sh = false}) => ls.add(Ltr(c, h, sh));

  final maalum = v == Voice.maalum;
  var pv = maalum ? Hrk.fatha : Hrk.damma;

  switch (s.wazn.id) {
    case 'mujarrad3':
      root(0, Hrk.sukun);
      root(1, maalum ? s.mudariAynVowel : Hrk.fatha);
      root(2, lamH);
    case 'ifal':
      pv = Hrk.damma;
      // The أصل still carries the hamza of أَفْعَلَ — حذف همزة أفعل removes
      // it below, and that deletion is worth showing.
      lit(hamza, Hrk.fatha);
      root(0, Hrk.sukun);
      root(1, maalum ? Hrk.kasra : Hrk.fatha);
      root(2, lamH);
    case 'tafil':
      pv = Hrk.damma;
      root(0, Hrk.fatha);
      root(1, maalum ? Hrk.kasra : Hrk.fatha, sh: true);
      root(2, lamH);
    case 'mufaala':
      pv = Hrk.damma;
      root(0, Hrk.fatha);
      lit(alif, Hrk.none);
      root(1, maalum ? Hrk.kasra : Hrk.fatha);
      root(2, lamH);
    case 'tafaul':
      lit(ta, Hrk.fatha);
      root(0, Hrk.fatha);
      root(1, Hrk.fatha, sh: true);
      root(2, lamH);
    case 'tafaaul':
      lit(ta, Hrk.fatha);
      root(0, Hrk.fatha);
      lit(alif, Hrk.none);
      root(1, Hrk.fatha);
      root(2, lamH);
    case 'iftial':
      root(0, Hrk.sukun);
      lit(ta, Hrk.fatha);
      root(1, maalum ? Hrk.kasra : Hrk.fatha);
      root(2, lamH);
    case 'infial':
      lit(nun, Hrk.sukun);
      root(0, Hrk.fatha);
      root(1, maalum ? Hrk.kasra : Hrk.fatha);
      root(2, lamH);
    case 'istifal':
      lit(sin, Hrk.sukun);
      lit(ta, Hrk.fatha);
      root(0, Hrk.sukun);
      root(1, maalum ? Hrk.kasra : Hrk.fatha);
      root(2, lamH);
    case 'ifilal':
      root(0, Hrk.sukun);
      root(1, Hrk.fatha);
      root(2, Hrk.sukun);
      lit(s.l, lamH);
    case 'ifilal2':
      root(0, Hrk.sukun);
      root(1, Hrk.fatha);
      lit(alif, Hrk.none);
      root(2, Hrk.sukun);
      lit(s.l, lamH);
    case 'ifiwwal':
      root(0, Hrk.sukun);
      root(1, Hrk.fatha);
      lit(waw, Hrk.kasra, sh: true);
      root(2, lamH);
    case 'ifiyal':
      root(0, Hrk.sukun);
      root(1, Hrk.fatha);
      lit(waw, Hrk.sukun);
      lit(s.a, Hrk.kasra);
      root(2, lamH);
    case 'falala':
      pv = Hrk.damma;
      root(0, Hrk.fatha);
      root(1, Hrk.sukun);
      root(2, maalum ? Hrk.kasra : Hrk.fatha);
      root(3, lamH);
    case 'tafalul':
      lit(ta, Hrk.fatha);
      root(0, Hrk.fatha);
      root(1, Hrk.sukun);
      root(2, Hrk.fatha);
      root(3, lamH);
    case 'ifanlal':
      root(0, Hrk.sukun);
      root(1, Hrk.fatha);
      lit(nun, Hrk.sukun);
      root(2, maalum ? Hrk.kasra : Hrk.fatha);
      root(3, lamH);
    case 'ifillal':
      root(0, Hrk.sukun);
      root(1, Hrk.fatha);
      root(2, Hrk.kasra);
      root(3, lamH);
    default:
      root(0, Hrk.sukun);
      root(1, Hrk.fatha);
      root(2, lamH);
  }
  return (frame: Frame(ls, idx), prefixVowel: pv);
}

// ═══════════════════════════════════════════════════════════════════════════
// Suffixes — the ضمائر, and what they do to the لام
// ═══════════════════════════════════════════════════════════════════════════

/// (vowel the لام takes, the letters that follow it).
({Hrk lam, List<Ltr> tail}) _madiSuffix(Sigha s) => switch (s) {
      Sigha.wahidMudhakkarGhaib => (lam: Hrk.fatha, tail: []),
      Sigha.tathniyaMudhakkarGhaib => (lam: Hrk.fatha, tail: [Ltr(alif)]),
      Sigha.jamMudhakkarGhaib =>
        (lam: Hrk.damma, tail: [Ltr(waw, Hrk.sukun), Ltr(alif)]),
      Sigha.wahidaMuannathGhaiba => (lam: Hrk.fatha, tail: [Ltr(ta, Hrk.sukun)]),
      Sigha.tathniyaMuannathGhaiba =>
        (lam: Hrk.fatha, tail: [Ltr(ta, Hrk.fatha), Ltr(alif)]),
      Sigha.jamMuannathGhaiba => (lam: Hrk.sukun, tail: [Ltr(nun, Hrk.fatha)]),
      Sigha.wahidMudhakkarMukhatab =>
        (lam: Hrk.sukun, tail: [Ltr(ta, Hrk.fatha)]),
      Sigha.tathniyaMudhakkarMukhatab || Sigha.tathniyaMuannathMukhataba => (
          lam: Hrk.sukun,
          tail: [Ltr(ta, Hrk.damma), Ltr(mim, Hrk.fatha), Ltr(alif)]
        ),
      Sigha.jamMudhakkarMukhatab =>
        (lam: Hrk.sukun, tail: [Ltr(ta, Hrk.damma), Ltr(mim, Hrk.sukun)]),
      Sigha.wahidaMuannathMukhataba =>
        (lam: Hrk.sukun, tail: [Ltr(ta, Hrk.kasra)]),
      Sigha.jamMuannathMukhataba => (
          lam: Hrk.sukun,
          tail: [Ltr(ta, Hrk.damma), Ltr(nun, Hrk.fatha, true)]
        ),
      Sigha.wahidMutakallim => (lam: Hrk.sukun, tail: [Ltr(ta, Hrk.damma)]),
      Sigha.jamMutakallim =>
        (lam: Hrk.sukun, tail: [Ltr(nun, Hrk.fatha), Ltr(alif)]),
    };

String _mudariPrefix(Sigha s) => switch (s.person) {
      Person.mutakallim => s.number == Number.wahid ? hamza : nun,
      Person.mukhatab => ta,
      Person.ghaib => (s.gender == Gender.muannath && s.number != Number.jam)
          ? ta
          : ya,
    };

/// The muḍāriʿ ending, per mood.
({Hrk lam, List<Ltr> tail}) _mudariSuffix(Sigha s, Mood m, {bool mudaaf = false}) {
  // The «أفعال خمسة» — the five that end in a نون الرفع which jazm and naṣb
  // both remove.
  const five = {
    Sigha.tathniyaMudhakkarGhaib,
    Sigha.tathniyaMuannathGhaiba,
    Sigha.jamMudhakkarGhaib,
    Sigha.tathniyaMudhakkarMukhatab,
    Sigha.tathniyaMuannathMukhataba,
    Sigha.jamMudhakkarMukhatab,
    Sigha.wahidaMuannathMukhataba,
  };
  // نون النسوة is part of the word, not an iʿrāb marker: these two cells are
  // mabnī and never change with mood.
  final niswa =
      s == Sigha.jamMuannathGhaiba || s == Sigha.jamMuannathMukhataba;

  if (niswa) return (lam: Hrk.sukun, tail: [Ltr(nun, Hrk.fatha)]);

  if (five.contains(s)) {
    final dropNun = m != Mood.marfu;
    if (s.number == Number.tathniya) {
      return (
        lam: Hrk.fatha,
        tail: [Ltr(alif), if (!dropNun) Ltr(nun, Hrk.kasra)]
      );
    }
    if (s == Sigha.wahidaMuannathMukhataba) {
      return (
        lam: Hrk.kasra,
        tail: [Ltr(ya, Hrk.sukun), if (!dropNun) Ltr(nun, Hrk.fatha)]
      );
    }
    return (
      lam: Hrk.damma,
      tail: [Ltr(waw, Hrk.sukun), if (!dropNun) Ltr(nun, Hrk.fatha) else Ltr(alif)]
    );
  }

  return (
    lam: switch (m) {
      Mood.marfu => Hrk.damma,
      Mood.mansub => Hrk.fatha,
      // A مضاعف keeps its idghām at jazm by taking fatḥa instead of sukūn.
      Mood.majzum => mudaaf ? Hrk.fatha : Hrk.sukun,
    },
    tail: const []
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// The i'lāl pipeline
// ═══════════════════════════════════════════════════════════════════════════

class _Recorder {
  _Recorder(this.frame);
  final Frame frame;
  final List<IlalStep> steps = [];
  String _last = '';

  void begin() => _last = frame.text;

  void note(RuleId r, {L4? extra}) {
    final now = frame.text;
    if (now == _last) return;
    steps.add(IlalStep(before: _last, after: now, rule: r, note: extra));
    _last = now;
  }
}

/// Runs every rule that applies, in the order the books apply them, and
/// returns the recorded chain.
List<IlalStep> _applyIlal(Frame f, Ctx c) {
  final rec = _Recorder(f)..begin();
  final s = c.spec;

  _ruleHamzatAfal(f, c, rec);
  _ruleIftialFa(f, c, rec);
  _ruleMithalFa(f, c, rec);
  _ruleAjwaf(f, c, rec);
  _ruleNaqis(f, c, rec);
  if (s.isMudaaf || s.wazn.id == 'ifilal' || s.wazn.id == 'ifillal') {
    _ruleIdgham(f, c, rec);
  }
  _ruleWawAfterKasra(f, c, rec);
  _ruleAlifAfterVowel(f, c, rec);
  _ruleHamzatayn(f, c, rec);
  _ruleTrailingSakinayn(f, c, rec);

  return rec.steps;
}

/// حذف همزة أفْعَلَ من المضارع ووصفيه. شذا العرف page1_0153
void _ruleHamzatAfal(Frame f, Ctx c, _Recorder rec) {
  if (c.spec.wazn.id != 'ifal') return;
  if (c.tense == Tense.madi) return;
  // In the muḍāriʿ the first letter is the ḥarf al-muḍāraʿa — which for the
  // mutakallim is itself a hamza (أُأَكْرِمُ). The one that has to go is the
  // *second*; deleting the prefix instead is exactly the collision the rule
  // exists to resolve.
  final from = c.tense == Tense.mudari ? 1 : 0;
  final i = f.ls.indexWhere((l) => isHamza(l.c), from);
  if (i < 0 || i > from) return;
  f.removeAt(i);
  rec.note(RuleId.hadhfHamzatAfal);
}

/// فاء الافتعال وتاؤه. شذا العرف page1_0147 · docs/sarf/04-ilal-ibdal.md § ۴.۸
void _ruleIftialFa(Frame f, Ctx c, _Recorder rec) {
  if (c.spec.wazn.id != 'iftial') return;
  final fi = f.posOf(0);
  if (fi == null) return;
  final fa = f.ls[fi];
  final ti = fi + 1;
  if (ti >= f.ls.length || f.ls[ti].c != ta) return;

  if (fa.c == waw || fa.c == ya) {
    // اتَّعَدَ — the wāw/yāʾ becomes tāʾ and merges into the bāb's tāʾ.
    f.removeAt(fi);
    final j = f.ls.indexWhere((l) => l.c == ta);
    if (j >= 0) f.ls[j] = f.ls[j].copyWith(shadda: true);
    rec.note(RuleId.faAlIftial);
  } else if (itbaq.contains(fa.c)) {
    // اصْطَبَرَ، اضْطَرَبَ — the tāʾ becomes ṭāʾ.
    f.ls[ti] = f.ls[ti].copyWith(c: 'ط');
    rec.note(RuleId.faAlIftial);
  } else if (fa.c == 'د' || fa.c == 'ذ' || fa.c == 'ز') {
    // ازْدَجَرَ — the tāʾ becomes dāl.
    f.ls[ti] = f.ls[ti].copyWith(c: 'د');
    rec.note(RuleId.faAlIftial);
  }
}

/// حذف فاء المثال الواوي من المضارع والأمر. شذا العرف page1_0050
void _ruleMithalFa(Frame f, Ctx c, _Recorder rec) {
  if (c.spec.type != SahihMutal.mithal) return;
  if (!c.spec.isMujarrad3) return;
  if (c.spec.f != waw) return;
  if (c.tense == Tense.madi) return;
  if (c.voice == Voice.majhul) return; // يُوعَدُ keeps its wāw
  if (c.spec.mudariAynVowel != Hrk.kasra) return; // only يَفْعِلُ
  final i = f.posOf(0);
  if (i == null) return;
  f.removeAt(i);
  rec.note(RuleId.hadhfFaAlMithal);
}

/// The أجوف — the longest chain in the book. docs/sarf/04-ilal-ibdal.md § ۴.۵–۴.۶
void _ruleAjwaf(Frame f, Ctx c, _Recorder rec) {
  if (c.spec.type != SahihMutal.ajwaf) return;
  final ai = f.posOf(1);
  if (ai == null) return;
  final ayn = f.ls[ai];
  if (!isIlla(ayn.c)) return;
  final before = ai > 0 ? f.ls[ai - 1] : null;
  final after = ai + 1 < f.ls.length ? f.ls[ai + 1] : null;
  if (before == null || after == null) return;

  if (c.tense == Tense.madi) {
    if (c.voice == Voice.majhul) {
      // قُوِلَ ← قِيلَ: the first letter takes kasra and the ʿayn becomes yāʾ.
      f.ls[ai - 1] = before.copyWith(h: Hrk.kasra);
      f.ls[ai] = Ltr(ya, Hrk.sukun);
      rec.note(RuleId.qalbAlifLilharaka);
    } else if (ayn.isMutaharrik && before.h == Hrk.fatha) {
      // قَوَلَ ← قَالَ  (قاعدة قال وباع)
      final originalVowel = ayn.h;
      final originalLetter = ayn.c;
      f.ls[ai] = Ltr(alif, Hrk.none);
      rec.note(RuleId.qalbWawYaAlifan);
      if (after.isSakin) {
        // قَالْنَ ← قَلْنَ, then the fāʾ's vowel records what was lost.
        f.removeAt(ai);
        rec.note(RuleId.hadhfLiltiqaSakinayn);
        final wantDamma =
            originalLetter == waw && originalVowel != Hrk.kasra;
        f.ls[ai - 1] = f.ls[ai - 1]
            .copyWith(h: wantDamma ? Hrk.damma : Hrk.kasra);
        rec.note(wantDamma ? RuleId.qaidaQulnaTulna : RuleId.qaidaKhifnaBina);
      }
    }
    // Whatever happened, a stranded alif before a sākin still has to go.
    return;
  }

  // ── المضارع والأمر: الإعلال بالنقل ──
  if (ayn.isMutaharrik && before.isSakin) {
    final moved = ayn.h;
    f.ls[ai - 1] = before.copyWith(h: moved);
    final homo = moved.homogeneous;
    f.ls[ai] = Ltr(homo == ayn.c ? ayn.c : (homo ?? ayn.c), Hrk.sukun);
    if (f.ls[ai].c == alif) f.ls[ai] = Ltr(alif, Hrk.none);
    rec.note(RuleId.ilalBinNaql);
  }
  // After naql the ʿayn is sākin; if the لام is sākin too, it drops.
  final a2 = f.posOf(1);
  if (a2 != null && a2 + 1 < f.ls.length) {
    if (f.ls[a2].isSakin && f.ls[a2 + 1].isSakin) {
      f.removeAt(a2);
      rec.note(RuleId.hadhfLiltiqaSakinayn);
    }
  }
}

/// الناقص. شذا العرف page1_0051–0052 · docs/sarf/03-sighy-gardan.md § ۳.۴.۶
void _ruleNaqis(Frame f, Ctx c, _Recorder rec) {
  if (c.spec.type != SahihMutal.naqis &&
      c.spec.type != SahihMutal.lafifMafruq &&
      c.spec.type != SahihMutal.lafifMaqrun) {
    return;
  }
  final li = f.posOf(2);
  if (li == null) return;
  final lam = f.ls[li];
  if (!isIlla(lam.c)) return;
  final prev = li > 0 ? f.ls[li - 1] : null;
  if (prev == null) return;
  final next = li + 1 < f.ls.length ? f.ls[li + 1] : null;

  // ① Before wāw al-jamāʿa and yāʾ al-mukhāṭaba the lām drops outright.
  if (next != null && (next.c == waw || next.c == ya) && next.isSakin ||
      (next != null && next.c == waw && next.h == Hrk.none)) {
    final wasAlifLike = prev.h == Hrk.fatha;
    f.removeAt(li);
    if (!wasAlifLike) {
      final j = li - 1;
      f.ls[j] = f.ls[j]
          .copyWith(h: next.c == ya ? Hrk.kasra : Hrk.damma);
    }
    rec.note(RuleId.hadhfLamNaqisWawJamaa);
    return;
  }

  // ② At jazm / in the amr the final weak letter goes. (قاعدة لم يَدْعُ)
  if (c.tense != Tense.madi && lam.isSakin && next == null) {
    f.removeAt(li);
    rec.note(RuleId.qaidaLamYadu);
    return;
  }

  // ③ Otherwise: قلب الواو والياء ألفًا, where the ten conditions allow.
  final followedByAlif = next != null && next.c == alif;
  final followedByTaTanith = next != null && next.c == ta;
  if (lam.isMutaharrik && prev.h == Hrk.fatha && !followedByAlif) {
    // A three-letter wāwī root writes the alif long (غَزَا); a yāʾī one, and
    // anything longer than three letters, writes it maqṣūra (رَمَى، أَعْطَى).
    final longAlif = c.tense == Tense.madi &&
        c.spec.root.length == 3 &&
        c.spec.isMujarrad3 &&
        lam.c == waw;
    f.ls[li] = Ltr(longAlif ? alif : alifMaqsura, Hrk.none);
    rec.note(RuleId.qalbWawYaAlifan);
    // تاء التأنيث after a final alif drops it «مطلقًا».
    if (followedByTaTanith) {
      f.removeAt(li);
      rec.note(RuleId.hadhfLiltiqaSakinayn);
    }
    return;
  }

  // ④ In the marfūʿ muḍāriʿ the ḍamma on a final wāw/yāʾ is too heavy to say.
  if (c.tense == Tense.mudari &&
      c.mood == Mood.marfu &&
      next == null &&
      lam.h == Hrk.damma) {
    if (prev.h == Hrk.fatha) {
      f.ls[li] = Ltr(alifMaqsura, Hrk.none);
      rec.note(RuleId.qalbWawYaAlifan);
    } else {
      f.ls[li] = lam.copyWith(h: Hrk.sukun);
      rec.note(RuleId.hadhfLiltiqaSakinayn);
    }
    return;
  }

  // ⑤ Before نون النسوة and ألف التثنية an alif reverts to yāʾ.
  if (lam.c == alif || lam.c == alifMaqsura) {
    f.ls[li] = Ltr(ya, lam.h == Hrk.none ? Hrk.sukun : lam.h);
    rec.note(RuleId.raddLamNaqisIlaAslih);
  }
}

/// الإدغام — and its فك when a vowelled subject pronoun attaches.
/// شذا العرف page1_0049 (المضعف) · page1_0156 (الإدغام)
void _ruleIdgham(Frame f, Ctx c, _Recorder rec) {
  // Find the last adjacent identical pair.
  var pair = -1;
  for (var i = f.ls.length - 2; i >= 0; i--) {
    if (f.ls[i].c == f.ls[i + 1].c && !f.ls[i].shadda && !f.ls[i + 1].shadda) {
      pair = i;
      break;
    }
  }
  if (pair < 0) return;
  final first = f.ls[pair];
  final second = f.ls[pair + 1];

  // فك واجب: the second one is silent because a pronoun follows.
  if (second.isSakin) {
    rec.note(RuleId.fakkIdgham);
    return;
  }

  // The first of the pair has to fall silent before they can merge. In the
  // muḍāriʿ its vowel moves back onto the sākin fāʾ (يَمْدُدُ ← يَمُدْدُ);
  // in the māḍī the fāʾ is already vowelled, so the vowel simply goes.
  if (first.isMutaharrik) {
    if (pair > 0 && f.ls[pair - 1].isSakin) {
      f.ls[pair - 1] = f.ls[pair - 1].copyWith(h: first.h);
      f.ls[pair] = first.copyWith(h: Hrk.sukun);
      rec.note(RuleId.ilalBinNaql);
    } else {
      f.ls[pair] = first.copyWith(h: Hrk.sukun);
    }
  }
  if (!f.ls[pair].isSakin) return;
  f.removeAt(pair);
  final j = pair < f.ls.length ? pair : f.ls.length - 1;
  f.ls[j] = f.ls[j].copyWith(shadda: true);
  rec.note(RuleId.idghamMudaaf);
}

/// قلب الواو ياءً إذا وقعت بعد كسرة في الطرف — غُزِيَ. شذا العرف page1_0139
void _ruleWawAfterKasra(Frame f, Ctx c, _Recorder rec) {
  final li = f.posOf(2);
  if (li == null || li == 0) return;
  if (f.ls[li].c != waw) return;
  if (f.ls[li - 1].h != Hrk.kasra) return;
  // Only when the wāw really is the last root letter of a نَاقِص.
  if (c.spec.type != SahihMutal.naqis && c.spec.type != SahihMutal.lafifMaqrun) {
    return;
  }
  f.ls[li] = f.ls[li].copyWith(c: ya);
  rec.note(RuleId.qalbAlifLilharaka);
}

/// قلب الألف واوًا/ياءً حسب ما قبلها — ضُورِبَ، بُويِعَ. شذا العرف page1_0143
void _ruleAlifAfterVowel(Frame f, Ctx c, _Recorder rec) {
  for (var i = 1; i < f.ls.length; i++) {
    final l = f.ls[i];
    if (l.c != alif || l.h != Hrk.none) continue;
    final p = f.ls[i - 1];
    if (p.h == Hrk.damma) {
      f.ls[i] = Ltr(waw, Hrk.sukun);
      rec.note(RuleId.qalbAlifLilharaka);
    } else if (p.h == Hrk.kasra) {
      f.ls[i] = Ltr(ya, Hrk.sukun);
      rec.note(RuleId.qalbAlifLilharaka);
    }
  }
}

/// اجتماع الهمزتين في أول الكلمة — أَأْمَنَ ← آمَنَ. شذا العرف page1_0049
void _ruleHamzatayn(Frame f, Ctx c, _Recorder rec) {
  if (f.ls.length < 2) return;
  if (!isHamza(f.ls[0].c) || !isHamza(f.ls[1].c)) return;
  if (!f.ls[1].isSakin) return;
  final h = f.ls[0].h;
  f.ls[1] = Ltr(h.homogeneous ?? alif, Hrk.none);
  rec.note(RuleId.ijtimaHamzatayn);
}

/// A last sweep: a مدّة stranded before a sākin still has to go — this is
/// what turns لَمْ يَقُولْ into لَمْ يَقُلْ when the ʿayn rule did not catch it.
void _ruleTrailingSakinayn(Frame f, Ctx c, _Recorder rec) {
  for (var i = 0; i + 1 < f.ls.length; i++) {
    final a = f.ls[i];
    final b = f.ls[i + 1];
    if (!a.isSakin || !b.isSakin) continue;
    if (!isIlla(a.c) || a.h != Hrk.none && a.h != Hrk.sukun) continue;
    // A silent alif that is only an orthographic seat (ضَرَبُوا) stays.
    if (a.c == alif && i == f.ls.length - 1) continue;
    if (b.c == alif && b.h == Hrk.none) continue;
    f.removeAt(i);
    rec.note(RuleId.hadhfLiltiqaSakinayn);
    i--;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Public builders
// ═══════════════════════════════════════════════════════════════════════════

SighaForm buildMadi(VerbSpec s, Sigha sig, Voice v, {String prefix = ''}) {
  final suf = _madiSuffix(sig);
  final f = _madiStem(s, v, suf.lam);
  f.ls.addAll(suf.tail);
  final underlying = f.text;
  final ctx = Ctx(
    spec: s,
    tense: Tense.madi,
    voice: v,
    sigha: sig,
    mood: Mood.marfu,
    tawkid: Tawkid.bidun,
  );
  final steps = _applyIlal(f, ctx);
  return SighaForm(
    sigha: sig,
    text: prefix.isEmpty ? f.text : '$prefix ${f.text}',
    underlying: underlying,
    steps: steps,
    prefix: prefix,
  );
}

SighaForm buildMudari(
  VerbSpec s,
  Sigha sig,
  Voice v, {
  Mood mood = Mood.marfu,
  Tawkid tawkid = Tawkid.bidun,
  String prefix = '',
  bool lamAmr = false,
}) {
  final suf = _mudariSuffix(sig, tawkid == Tawkid.bidun ? mood : Mood.majzum,
      mudaaf: s.isMudaaf);
  final st = _mudariStem(s, v, suf.lam);
  final f = st.frame;
  // Make room for the prefix letter at index 0.
  f.insertAt(0, Ltr(_mudariPrefix(sig), st.prefixVowel));
  f.ls.addAll(suf.tail);
  final underlying = f.text;
  final ctx = Ctx(
    spec: s,
    tense: Tense.mudari,
    voice: v,
    sigha: sig,
    mood: tawkid == Tawkid.bidun ? mood : Mood.majzum,
    tawkid: tawkid,
  );
  final steps = _applyIlal(f, ctx);
  var body = f.text;
  if (tawkid != Tawkid.bidun) body = _attachNunTawkid(f, sig, tawkid);
  final head = lamAmr ? 'لِ' : '';
  return SighaForm(
    sigha: sig,
    text: prefix.isEmpty ? '$head$body' : '$prefix $head$body',
    underlying: underlying,
    steps: steps,
    prefix: prefix,
  );
}

/// نون التوكيد. شذا العرف page1_0046–0047 · docs/sarf/03-sighy-gardan.md § ۳.۶
String _attachNunTawkid(Frame f, Sigha sig, Tawkid t) {
  final nunTxt = t == Tawkid.thaqila ? 'نَّ' : 'نْ';
  final ls = List<Ltr>.from(f.ls);

  // Trim the ألف الفارقة that only ever propped up a wāw al-jamāʿa.
  if (ls.isNotEmpty && ls.last.c == alif && ls.last.h == Hrk.none) {
    if (ls.length > 1 && ls[ls.length - 2].c == waw) ls.removeLast();
  }

  if (sig.number == Number.tathniya) {
    // The نون الرفع is already gone; the tawkīd nūn takes kasra after the alif.
    return '${renderLetters(ls)}${t == Tawkid.thaqila ? 'نِّ' : ''}';
  }

  if (ls.isNotEmpty && ls.last.c == waw && ls.last.isSakin) {
    // لَتَنْصُرُنَّ — the wāw drops and its ḍamma stays behind as the trace.
    ls.removeLast();
    if (ls.isNotEmpty) ls[ls.length - 1] = ls.last.copyWith(h: Hrk.damma);
    return '${renderLetters(ls)}$nunTxt';
  }
  if (ls.isNotEmpty && ls.last.c == ya && ls.last.isSakin) {
    ls.removeLast();
    if (ls.isNotEmpty) ls[ls.length - 1] = ls.last.copyWith(h: Hrk.kasra);
    return '${renderLetters(ls)}$nunTxt';
  }
  if (sig.number == Number.jam && sig.gender == Gender.muannath) {
    // An alif separates نون النسوة from the tawkīd nūn, which then takes kasra.
    return '${renderLetters(ls)}اِنِّ';
  }
  // Everything else simply opens up: لَيَنْصُرَنَّ.
  if (ls.isNotEmpty) ls[ls.length - 1] = ls.last.copyWith(h: Hrk.fatha);
  return '${renderLetters(ls)}$nunTxt';
}

/// الأمر الحاضر — built from the majzūm muḍāriʿ by dropping its prefix.
/// شذا العرف page1_0035–0036
SighaForm buildAmr(VerbSpec s, Sigha sig, {Tawkid tawkid = Tawkid.bidun}) {
  final suf = _mudariSuffix(sig, Mood.majzum, mudaaf: s.isMudaaf);
  final st = _mudariStem(s, Voice.maalum, suf.lam);
  final f = st.frame;
  f.ls.addAll(suf.tail);
  final underlying = '${_mudariPrefix(sig)}${st.prefixVowel.mark}${f.text}';

  final ctx = Ctx(
    spec: s,
    tense: Tense.amr,
    voice: Voice.maalum,
    sigha: sig,
    mood: Mood.majzum,
    tawkid: tawkid,
  );
  final steps = _applyIlal(f, ctx);

  // أخذ / أكل shed their hamza in the imperative, without qualification.
  if (s.isMujarrad3 &&
      f.ls.isNotEmpty &&
      isHamza(f.ls[0].c) &&
      s.type == SahihMutal.mahmuzFa) {
    final rec = _Recorder(f)..begin();
    f.removeAt(0);
    rec.note(RuleId.hadhfHamzatAmr);
    steps.addAll(rec.steps);
  }

  var body = f.text;
  if (f.ls.isNotEmpty && f.ls.first.isSakin) {
    // A word cannot open on a sākin, so همزة الوصل is prefixed; its vowel is
    // ḍamma only when the ʿayn is originally maḍmūm. شذا العرف page1_0127
    if (s.wazn.id == 'ifal') {
      body = 'أَ$body'; // همزة قطع مفتوحة
    } else {
      final aynV = s.isMujarrad3 ? s.mudariAynVowel : Hrk.kasra;
      body = '${_wasl}${aynV == Hrk.damma ? damma : kasra}$body';
    }
  }
  if (tawkid != Tawkid.bidun) {
    final withNun = _attachNunTawkid(f, sig, tawkid);
    body = f.ls.isNotEmpty && f.ls.first.isSakin
        ? '${body.substring(0, body.length - f.text.length)}$withNun'
        : withNun;
  }
  return SighaForm(
    sigha: sig,
    text: body,
    underlying: underlying,
    steps: steps,
  );
}
