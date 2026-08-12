/// Low-level Arabic orthography helpers.
///
/// Everything the engine builds is *fully vocalised*: a word is modelled as an
/// ordered list of [Ltr] (letter + its own haraka), never as a bare string.
/// That is what lets the i'lal rules ask questions like "is the ع sākin?" or
/// "is the letter before it maftūḥ?" — questions you cannot answer once the
/// form has been flattened to text.
///
/// Reference: docs/sarf/01-bunyaad.md § ۱.۳, docs/sarf/README.md § ۳.
library;

// ── Harakāt ────────────────────────────────────────────────────────────────
const String fatha = 'َ'; // َ
const String damma = 'ُ'; // ُ
const String kasra = 'ِ'; // ِ
const String sukun = 'ْ'; // ْ
const String shadda = 'ّ'; // ّ
const String fathatan = 'ً'; // ً
const String dammatan = 'ٌ'; // ٌ
const String kasratan = 'ٍ'; // ٍ

const Set<String> tashkeel = {
  fatha,
  damma,
  kasra,
  sukun,
  shadda,
  fathatan,
  dammatan,
  kasratan,
  'ٰ', // dagger alif
  'ٓ', // madda above
  'ٔ', // hamza above
  'ٕ', // hamza below
};

// ── Letters ────────────────────────────────────────────────────────────────
const String alif = 'ا';
const String waw = 'و';
const String ya = 'ي';
const String hamza = 'ء';
const String alifMaqsura = 'ى';
const String taMarbuta = 'ة';
const String nun = 'ن';
const String ta = 'ت';
const String mim = 'م';
const String sin = 'س';
const String lam = 'ل';
const String ba = 'ب';

/// The three ḥurūf al-ʿilla. (شذا العرف: الألف والواو والياء)
const Set<String> illaLetters = {alif, waw, ya, alifMaqsura};

/// حروف الحلق — a bāb-4 (فَتَحَ يَفْتَحُ) verb is normally ḥalqī in ع or ل.
/// docs/sarf/02-abwab.md § باب فتح
const Set<String> halqi = {'ء', 'ه', 'ح', 'خ', 'ع', 'غ', 'أ', 'إ', 'آ', 'ؤ', 'ئ'};

/// أحرف الإطباق — decide the shape of tāʾ al-iftiʿāl (ص/ض/ط/ظ → ط).
/// docs/sarf/04-ilal-ibdal.md § ۴.۸
const Set<String> itbaq = {'ص', 'ض', 'ط', 'ظ'};

/// حروف الزيادة — «سَأَلْتُمُونِيهَا». docs/sarf/01-bunyaad.md § قاعده ۳
const Set<String> ziyadaLetters = {
  'س', 'أ', 'ل', 'ت', 'م', 'و', 'ن', 'ي', 'ه', 'ا', 'ء', 'إ', 'آ',
};

/// Every shape the hamza takes in writing, folded to the bare ء for matching.
const Map<String, String> _hamzaForms = {
  'أ': hamza,
  'إ': hamza,
  'آ': hamza,
  'ؤ': hamza,
  'ئ': hamza,
};

bool isHamza(String c) => c == hamza || _hamzaForms.containsKey(c);
bool isIlla(String c) => illaLetters.contains(c);
bool isHalqi(String c) => halqi.contains(c);

/// Strip every diacritic, leaving the bare rasm. Used for matching a typed
/// word against the awzān, where the user may or may not have vocalised it.
String stripTashkeel(String s) =>
    s.split('').where((c) => !tashkeel.contains(c)).join();

/// Fold the orthographic variants that carry no morphological information:
/// أ/إ/آ → ا for skeleton comparison, ى → ي, ة → ه is *not* done (the tāʾ
/// marbūṭa is morphologically real — it marks the feminine).
String normalizeSkeleton(String s) {
  final b = StringBuffer();
  for (final c in stripTashkeel(s).split('')) {
    switch (c) {
      case 'أ':
      case 'إ':
      case 'آ':
        b.write(alif);
      case 'ؤ':
        b.write(waw);
      case 'ئ':
        b.write(ya);
      case alifMaqsura:
        b.write(ya);
      case 'ـ': // tatweel
        break;
      default:
        b.write(c);
    }
  }
  return b.toString();
}

/// Fold a letter to the form used when comparing *root* letters, where the
/// hamza's seat is irrelevant: أخذ and ءخذ are the same root.
String normalizeRootLetter(String c) => _hamzaForms[c] ?? c;

/// Arabic-Indic digits, used everywhere numbers are shown to the reader.
const List<String> _arabicDigits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

String toArabicDigits(int n) =>
    n.toString().split('').map((d) {
      final i = int.tryParse(d);
      return i == null ? d : _arabicDigits[i];
    }).join();

// ── The vowel a slot carries ───────────────────────────────────────────────
enum Hrk {
  fatha,
  damma,
  kasra,
  sukun,

  /// No mark at all — used for the silent alif of ضَرَبُوا and for letters
  /// that are pure lengthening (the و of يَقُولُ once it has been analysed).
  none,
}

extension HrkChar on Hrk {
  String get mark => switch (this) {
        Hrk.fatha => fatha,
        Hrk.damma => damma,
        Hrk.kasra => kasra,
        Hrk.sukun => sukun,
        Hrk.none => '',
      };

  /// The ḥarf al-ʿilla that is *homogeneous* (مجانس) with this vowel — the
  /// notion the إعلال بالنقل rule turns on. docs/sarf/04-ilal-ibdal.md § ۴.۶
  String? get homogeneous => switch (this) {
        Hrk.fatha => alif,
        Hrk.damma => waw,
        Hrk.kasra => ya,
        _ => null,
      };

  bool get isVowel => this != Hrk.sukun && this != Hrk.none;
}

/// One consonant slot: the letter, its haraka, and whether it is doubled.
class Ltr {
  const Ltr(this.c, [this.h = Hrk.none, this.shadda = false]);

  final String c;
  final Hrk h;
  final bool shadda;

  Ltr copyWith({String? c, Hrk? h, bool? shadda}) =>
      Ltr(c ?? this.c, h ?? this.h, shadda ?? this.shadda);

  bool get isIllaLetter => isIlla(c);
  bool get isSakin => h == Hrk.sukun || h == Hrk.none;
  bool get isMutaharrik => h.isVowel;

  /// A مدّة: a sākin ḥarf ʿilla preceded by its homogeneous vowel. The engine
  /// asks this when deciding what may be dropped at التقاء الساكنين.
  bool get isBareAlif => c == alif && h == Hrk.none;

  @override
  String toString() => '$c${shadda ? 'ّ' : ''}${h.mark}';

  @override
  bool operator ==(Object other) =>
      other is Ltr && other.c == c && other.h == h && other.shadda == shadda;

  @override
  int get hashCode => Object.hash(c, h, shadda);
}

// ── Rendering ──────────────────────────────────────────────────────────────

/// Put the combining marks of every letter into the order Arabic is written
/// in: **shadda first, then the vowel** (شَدَّة before فَتْحَة), and the
/// tanwīn last.
///
/// This matters because Unicode's own canonical ordering disagrees — fatḥa
/// has a lower combining class than shadda, so `normalize()` would sort them
/// the other way — and because a literal typed into a source file lands in
/// whatever order the keyboard produced. Shapers place the marks correctly
/// only for the conventional order, so every string is put through here on
/// its way to the screen.
String canonicalizeMarks(String s) {
  const tanwinSet = {fathatan, dammatan, kasratan};
  final out = StringBuffer();
  final marks = <String>[];

  void flush() {
    if (marks.isEmpty) return;
    marks.sort((a, b) {
      int rank(String c) => c == shadda
          ? 0
          : tanwinSet.contains(c)
              ? 2
              : 1;
      return rank(a).compareTo(rank(b));
    });
    out.writeAll(marks);
    marks.clear();
  }

  for (final c in s.split('')) {
    if (tashkeel.contains(c)) {
      marks.add(c);
    } else {
      flush();
      out.write(c);
    }
  }
  flush();
  return out.toString();
}

/// Rank a vowel for the purpose of choosing a hamza's seat: kasra beats
/// ḍamma beats fatḥa beats sukūn — the traditional «الأقوى» ordering.
int _vowelRank(Hrk h) => switch (h) {
      Hrk.kasra => 3,
      Hrk.damma => 2,
      Hrk.fatha => 1,
      _ => 0,
    };

/// Which chair the hamza sits on, given its own vowel, the vowel before it,
/// and where in the word it falls. The engine always *stores* a bare ء and
/// only picks a seat at render time, so rules never have to care about
/// orthography.
String _hamzaSeat(Hrk own, Hrk prev, {required bool initial, required bool last, required bool afterAlif}) {
  if (initial) return own == Hrk.kasra ? 'إ' : 'أ';
  if (afterAlif) {
    // After a long alif the hamza normally stands alone — قِرَاءَةٌ, يَشَاءُ —
    // but a kasra or ḍamma of its own still claims a seat: قَائِلٌ, بَائِعٌ.
    if (last) return hamza;
    if (own == Hrk.kasra) return 'ئ';
    if (own == Hrk.damma) return 'ؤ';
    return hamza;
  }
  final h = last ? prev : (_vowelRank(own) >= _vowelRank(prev) ? own : prev);
  return switch (h) {
    Hrk.kasra => 'ئ',
    Hrk.damma => 'ؤ',
    Hrk.fatha => 'أ',
    _ => hamza,
  };
}

/// Flatten a vocalised form to text the way Arabic is actually written.
///
/// Two things have to happen here and nowhere else:
///  * the hamza gets a seat (أ إ ؤ ئ ء) from its surroundings;
///  * a **مدّة** — a sākin ḥarf ʿilla preceded by its own homogeneous vowel —
///    is written bare. يَقُولُ, not يَقُوْلُ: the wāw there is lengthening,
///    not a closed syllable, and Arabic does not mark it.
String renderLetters(List<Ltr> ls) {
  final b = StringBuffer();
  for (var i = 0; i < ls.length; i++) {
    final l = ls[i];
    final prev = i > 0 ? ls[i - 1] : null;
    final prevH = prev?.h ?? Hrk.none;

    var ch = l.c;
    // أَ + ا  is written as one letter: آ (alif madda). This is what turns
    // أَاخُذُ into آخُذُ once اجتماع الهمزتين has fired.
    if (isHamza(l.c) && l.h == Hrk.fatha && i == 0 && i + 1 < ls.length) {
      final nx = ls[i + 1];
      if (nx.c == alif && nx.h == Hrk.none) {
        b.write('آ');
        i++;
        continue;
      }
    }
    if (isHamza(ch)) {
      ch = _hamzaSeat(
        l.h,
        prevH,
        initial: i == 0,
        last: i == ls.length - 1,
        afterAlif: prev != null && prev.c == alif,
      );
      // إ/أ already carry the hamza; a following kasra/fatḥa is still written.
    }
    b.write(ch);
    if (l.shadda) b.write(shadda);

    final isMadda = l.isSakin &&
        isIlla(l.c) &&
        (l.c == alif ||
            (l.c == waw && prevH == Hrk.damma) ||
            (l.c == ya && prevH == Hrk.kasra));
    if (!isMadda) b.write(l.h.mark);
  }
  return b.toString();
}

/// A vocalised word as the engine manipulates it.
class Word {
  Word(this.letters);

  final List<Ltr> letters;

  Word clone() => Word(List<Ltr>.from(letters));

  int get length => letters.length;
  Ltr operator [](int i) => letters[i];
  void operator []=(int i, Ltr v) => letters[i] = v;

  /// Rendered, fully-vocalised text. This is the only place letters become
  /// a String — nothing upstream should be parsing it back.
  String get text => renderLetters(letters);

  /// The bare rasm, for matching and for search.
  String get skeleton => normalizeSkeleton(text);

  @override
  String toString() => text;
}
