/// Word → analysis: which wazn, which root, and therefore which of the six,
/// seven and twelve classifications the typed word falls under.
///
/// Matching happens on the **rasm**, because a student types ضرب, not ضَرَبَ.
/// That means real ambiguity — علم is both عَلِمَ and عَلَّمَ — so the analyser
/// returns a ranked list of readings rather than pretending there is one.
library;

import 'arabic.dart';
import 'awzan.dart';
import 'conjugator.dart';
import 'lexicon.dart';
import 'models.dart';

/// One way of reading the typed word.
class Reading {
  const Reading({
    required this.root,
    required this.wazn,
    required this.type,
    required this.bina,
    required this.bab,
    required this.babProvenance,
    required this.masdar,
    required this.masdarProvenance,
    this.derived,
    this.score = 0,
  });

  final List<String> root;
  final Wazn wazn;
  final SahihMutal type;
  final Bina bina;

  /// Only for the ثلاثي مجرد.
  final Bab? bab;
  final Provenance babProvenance;

  final String masdar;
  final Provenance masdarProvenance;

  /// Set when the typed word was a derived noun rather than a verb.
  final DerivedKind? derived;

  /// Higher is a better reading. Used only for ordering.
  final int score;

  VerbSpec get spec => VerbSpec(
        root: root,
        wazn: wazn,
        type: type,
        bab: bab,
        babProvenance: babProvenance,
        masdar: masdar,
      );

  String get rootText => root.join(' ');

  ZiyadaKind? get ziyada => wazn.ziyada;

  /// The bāb's display label: «الْبَابُ الْأَوَّلُ» for the mujarrad, the
  /// maṣdar-name (الْإِفْعَال …) for a mazīd.
  String get babLabel => bab != null
      ? '${bab!.exemplarMadi} ${bab!.exemplarMudari}'
      : wazn.arabicName;
}

const List<String> _babOrdinals = [
  '',
  'الْبَابُ الْأَوَّلُ',
  'الْبَابُ الثَّانِي',
  'الْبَابُ الثَّالِثُ',
  'الْبَابُ الرَّابِعُ',
  'الْبَابُ الْخَامِسُ',
  'الْبَابُ السَّادِسُ',
];

String babOrdinal(int n) =>
    n >= 1 && n < _babOrdinals.length ? _babOrdinals[n] : '';

// ═══════════════════════════════════════════════════════════════════════════
// الأقسام السبعة, from the root letters alone
// ═══════════════════════════════════════════════════════════════════════════

SahihMutal classify(List<String> root) {
  final r = root.map(normalizeRootLetter).toList();
  if (r.length < 3) return SahihMutal.salim;
  final f = r[0], a = r[1], l = r[2];

  final fIlla = f == waw || f == ya;
  final aIlla = a == waw || a == ya;
  final lIlla = l == waw || l == ya || l == alif || l == alifMaqsura;

  // اللفيف first — it is the case where *two* root letters are weak.
  if (fIlla && lIlla) return SahihMutal.lafifMafruq;
  if (aIlla && lIlla) return SahihMutal.lafifMaqrun;
  if (fIlla) return SahihMutal.mithal;
  if (aIlla) return SahihMutal.ajwaf;
  if (lIlla) return SahihMutal.naqis;

  // المضاعف: «ما كانت عينه ولامه من جنس واحد»
  if (r.length == 3 && a == l) return SahihMutal.mudaaf;
  if (r.length == 4 && f == l && a == r[3]) return SahihMutal.mudaaf;

  if (isHamza(f)) return SahihMutal.mahmuzFa;
  if (isHamza(a)) return SahihMutal.mahmuzAyn;
  if (isHamza(l)) return SahihMutal.mahmuzLam;

  return SahihMutal.salim;
}

// ═══════════════════════════════════════════════════════════════════════════
// Skeleton matching
// ═══════════════════════════════════════════════════════════════════════════

/// Try to read [letters] as [skeleton]; returns the root letters if it fits.
List<String>? _match(List<String> letters, List<Slot> skeleton, int rootLen) {
  if (letters.length != skeleton.length) return null;
  final root = List<String?>.filled(5, null);
  for (var i = 0; i < skeleton.length; i++) {
    final s = skeleton[i];
    if (s is LitSlot) {
      if (normalizeSkeleton(s.c) != normalizeSkeleton(letters[i])) return null;
    } else if (s is RootSlot) {
      final existing = root[s.i];
      if (existing != null && existing != letters[i]) return null;
      root[s.i] = letters[i];
    }
  }
  final out = <String>[];
  for (var i = 0; i < rootLen; i++) {
    final c = root[i];
    if (c == null) return null;
    out.add(normalizeRootLetter(c));
  }
  return out;
}

/// Is this an Arabic letter that can stand as a root consonant? The range
/// ء…ي covers every letter including ة and ى, and excludes the ḥarakāt,
/// punctuation, digits and anything Latin.
bool _isArabicLetter(String c) {
  if (c.isEmpty) return false;
  final r = c.runes.first;
  return r >= 0x0621 && r <= 0x064A;
}

/// A root has at least three letters, they are all really letters, and none
/// of them is a bare alif — an alif is never an aṣl, only ever the trace of
/// a wāw or a yāʾ.
bool _plausibleRoot(List<String> r) {
  if (r.length < 3) return false;
  if (r.any((c) => c == alif)) return false;
  return r.every(_isArabicLetter);
}

// ═══════════════════════════════════════════════════════════════════════════
// The analyser
// ═══════════════════════════════════════════════════════════════════════════

class Analysis {
  const Analysis({required this.input, required this.readings});

  final String input;
  final List<Reading> readings;

  bool get isEmpty => readings.isEmpty;
  Reading get best => readings.first;
}

/// The letter sequences worth trying for a typed word.
///
/// A student types the *surface* form, and the surface hides exactly what the
/// matcher needs. قَالَ shows an alif where the root has a wāw; مَدَّ writes
/// one dāl for two. So before matching we generate the readings the rasm is
/// compatible with — and let the ranking sort them out.
List<List<String>> _candidates(String raw) {
  // ① Expand every shadda: مدّ ← م د د, احمرّ ← ا ح م ر ر.
  final expanded = <String>[];
  final chars = raw.split('');
  for (var i = 0; i < chars.length; i++) {
    final c = chars[i];
    if (tashkeel.contains(c)) {
      if (c == shadda && expanded.isNotEmpty) expanded.add(expanded.last);
      continue;
    }
    expanded.add(c);
  }
  final plain = normalizeSkeleton(raw).split('')
      .where((c) => c.trim().isNotEmpty)
      .toList();
  final withShadda = expanded
      .map((c) => normalizeSkeleton(c))
      .where((c) => c.trim().isNotEmpty)
      .toList();

  final seeds = <List<String>>[];
  void seed(List<String> l) {
    if (l.isEmpty) return;
    final copy = List<String>.from(l);
    // The definite article is not part of the word being analysed.
    if (copy.length > 3 && copy[0] == alif && copy[1] == lam) {
      copy.removeRange(0, 2);
    }
    if (!seeds.any((x) => x.join() == copy.join())) seeds.add(copy);
  }

  seed(plain);
  seed(withShadda);

  // ② An alif that is not word-initial stands for a wāw or a yāʾ that the
  //    i'lāl has already swallowed — قَالَ ← قَوَلَ, دَعَا ← دَعَوَ.
  final out = <List<String>>[];
  for (final s in seeds) {
    out.add(s);
    for (var i = 1; i < s.length; i++) {
      if (s[i] != alif) continue;
      for (final sub in [waw, ya]) {
        final v = List<String>.from(s)..[i] = sub;
        if (!out.any((x) => x.join() == v.join())) out.add(v);
      }
    }
  }
  return out;
}

Analysis analyze(String raw) {
  final input = raw.trim();
  if (input.isEmpty) return Analysis(input: input, readings: const []);

  final vocalised = stripTashkeel(input) != input;
  final out = <Reading>[];

  void add(
    List<String> root,
    Wazn wazn, {
    DerivedKind? derived,
    int bonus = 0,
  }) {
    if (!_plausibleRoot(root)) return;
    final type = classify(root);
    final entry = lookup(root);
    Bab? bab;
    var prov = Provenance.qiyasi;
    if (wazn.bina == Bina.thulathiMujarrad) {
      final g = guessBab(root, type);
      bab = g.bab;
      prov = g.provenance;
    }
    final masdar = wazn.bina == Bina.thulathiMujarrad
        ? (entry?.masdar ?? qiyasiMasdar(root, bab ?? babDarb))
        : _mazidMasdar(root, wazn);

    var score = bonus;
    // A root the books actually list beats one we invented.
    if (entry != null) score += 40;
    // The bare مجرد is the commonest reading of a three-letter rasm.
    if (wazn.bina == Bina.thulathiMujarrad) score += 12;
    // A verb is a likelier thing to type than a participle.
    if (derived == null) score += 8;
    // Vowelled input that contradicts the wazn is filtered out below; input
    // that agrees with it deserves a push.
    if (vocalised && _vowelsAgree(input, root, wazn, derived)) score += 30;

    out.add(Reading(
      root: root,
      wazn: wazn,
      type: type,
      bina: wazn.bina,
      bab: bab,
      babProvenance: prov,
      masdar: masdar,
      masdarProvenance: entry != null && wazn.bina == Bina.thulathiMujarrad
          ? Provenance.samai
          : Provenance.qiyasi,
      derived: derived,
      score: score,
    ));
  }

  final cands = _candidates(input);
  for (var ci = 0; ci < cands.length; ci++) {
    final letters = cands[ci];
    // A form we had to guess at (an alif read back as wāw) is a weaker
    // reading than one that matched the rasm as typed.
    final penalty = ci == 0 ? 0 : -6;
    for (final w in allVerbAwzan) {
      final r = _match(letters, w.skeleton, w.rootLength);
      if (r != null) add(r, w, bonus: penalty);
    }
    for (final np in nounPatterns) {
      final w = waznById(np.waznId);
      if (w == null) continue;
      final r = _match(letters, np.skeleton, w.rootLength);
      if (r != null) add(r, w, derived: np.kind, bonus: 4 + penalty);
    }
    // فَعَّلَ shares its rasm with the bare فَعَلَ, so it is offered by hand.
    if (letters.length == 3) {
      add(letters.map(normalizeRootLetter).toList(), waznById('tafil')!,
          bonus: 2 + penalty);
    }
  }
  if (out.isEmpty) return Analysis(input: input, readings: const []);

  out.sort((a, b) => b.score.compareTo(a.score));

  // Collapse readings that agree on root *and* wazn.
  final seen = <String>{};
  final unique = <Reading>[];
  for (final r in out) {
    final k = '${r.root.join()}|${r.wazn.id}|${r.derived?.name ?? ''}';
    if (seen.add(k)) unique.add(r);
  }
  return Analysis(input: input, readings: unique);
}

/// Does the vowelling the user typed actually fit this reading? Compared on
/// the māḍī (or the participle) — enough to tell عَلِمَ from عَلَّمَ.
bool _vowelsAgree(
  String input,
  List<String> root,
  Wazn wazn,
  DerivedKind? derived,
) {
  if (derived != null) return false;
  final typed = input.replaceAll(RegExp('[ًٌٍ]'), '');
  final type = classify(root);
  final bab = wazn.bina == Bina.thulathiMujarrad ? guessBab(root, type).bab : null;
  for (final b in (bab != null ? abwabThulathiMujarrad : [babDarb])) {
    final spec = VerbSpec(root: root, wazn: wazn, type: type, bab: b);
    final f = buildMadi(spec, Sigha.wahidMudhakkarGhaib, Voice.maalum).text;
    if (f.startsWith(typed) || typed.startsWith(f)) return true;
  }
  return false;
}

/// The قياسي maṣdar of a mazīd bāb, built by substituting into its pattern.
/// شذا العرف page1_0058: for anything above the ثلاثي it is قياسي throughout.
String _mazidMasdar(List<String> r, Wazn w) {
  final f = r[0];
  final a = r.length > 1 ? r[1] : f;
  final l = r.length > 2 ? r[2] : a;
  final l2 = r.length > 3 ? r[3] : l;
  return switch (w.id) {
    'ifal' => 'إِ$f${sukun}$a${fatha}${alif}$l${dammatan}',
    'tafil' => 'تَ$f${sukun}$a${kasra}${ya}$l${dammatan}',
    'mufaala' => 'مُ$f${fatha}${alif}$a${fatha}$l${fatha}${taMarbuta}${dammatan}',
    'tafaul' => 'تَ$f${fatha}$a${shadda}${damma}$l${dammatan}',
    'tafaaul' => 'تَ$f${fatha}${alif}$a${damma}$l${dammatan}',
    'iftial' => 'اِ$f${sukun}تِ$a${fatha}${alif}$l${dammatan}',
    'infial' => 'اِنْ$f${kasra}$a${fatha}${alif}$l${dammatan}',
    'istifal' => 'اِسْتِ$f${sukun}$a${fatha}${alif}$l${dammatan}',
    'ifilal' => 'اِ$f${sukun}$a${kasra}$l${fatha}${alif}$l${dammatan}',
    'ifilal2' => 'اِ$f${sukun}$a${kasra}${ya}$l${fatha}${alif}$l${dammatan}',
    'ifiwwal' => 'اِ$f${sukun}$a${kasra}وَّا$l${dammatan}',
    'ifiyal' => 'اِ$f${sukun}$a${kasra}ي$a${fatha}${alif}$l${dammatan}',
    'falala' => '$f${fatha}$a${sukun}$l${fatha}$l2${fatha}${taMarbuta}${dammatan}',
    'tafalul' => 'تَ$f${fatha}$a${sukun}$l${damma}$l2${dammatan}',
    'ifanlal' => 'اِ$f${sukun}$a${kasra}نْ$l${fatha}${alif}$l2${dammatan}',
    'ifillal' => 'اِ$f${sukun}$a${kasra}$l${shadda}${fatha}${alif}$l2${dammatan}',
    _ => '$f${fatha}$a${sukun}$l${dammatan}',
  };
}
