/// The vocabulary of the discipline, as types.
///
/// Names stay in Arabic transliteration on purpose — `Sigha`, not `Form`;
/// `Bab`, not `Chapter` (CLAUDE.md § د کوډ کنوانسیونونه). Where a book
/// disagrees with another, the source is named in the doc comment.
library;

import 'arabic.dart';

// ═══════════════════════════════════════════════════════════════════════════
// Provenance — سماعي vs قياسي vs مولَّد
// ═══════════════════════════════════════════════════════════════════════════

/// Where a piece of data came from. The books are explicit that the bāb of a
/// ثلاثي مجرد, which mazīd awzān a root actually takes, and a verb's
/// transitivity are **سماعي** — heard, not derived:
///
/// > «بل المدار في كل ذلك السَّماع» — شذا العرف page1_0026
///
/// The i'lāl on the other hand is **قياسي** and the code generates it.
/// Anything the app produced without a source to stand on is **مولَّد** and
/// must say so in the UI. docs/sarf/README.md § ۱
enum Provenance { samai, qiyasi, muwallad }

// ═══════════════════════════════════════════════════════════════════════════
// الأقسام الستة — by root length and augmentation
// ═══════════════════════════════════════════════════════════════════════════

/// إرشاد الصرف مخ ۲۴ «بيان الأقسام الستة»
enum Bina {
  thulathiMujarrad,
  thulathiMazid,
  rubaiMujarrad,
  rubaiMazid,
  khumasiMujarrad,
  khumasiMazid,
}

extension BinaInfo on Bina {
  String get arabic => switch (this) {
        Bina.thulathiMujarrad => 'ثُلَاثِيٌّ مُجَرَّدٌ',
        Bina.thulathiMazid => 'ثُلَاثِيٌّ مَزِيدٌ فِيهِ',
        Bina.rubaiMujarrad => 'رُبَاعِيٌّ مُجَرَّدٌ',
        Bina.rubaiMazid => 'رُبَاعِيٌّ مَزِيدٌ فِيهِ',
        Bina.khumasiMujarrad => 'خُمَاسِيٌّ مُجَرَّدٌ',
        Bina.khumasiMazid => 'خُمَاسِيٌّ مَزِيدٌ فِيهِ',
      };

  int get rootLength => switch (this) {
        Bina.thulathiMujarrad || Bina.thulathiMazid => 3,
        Bina.rubaiMujarrad || Bina.rubaiMazid => 4,
        Bina.khumasiMujarrad || Bina.khumasiMazid => 5,
      };

  bool get isMazid => switch (this) {
        Bina.thulathiMazid || Bina.rubaiMazid || Bina.khumasiMazid => true,
        _ => false,
      };
}

/// How many letters the augmentation adds. شذا العرف page1_0024:
/// ثلاثي مزيد comes in +1 (۳ أوزان), +2 (۵ أوزان), +3 (۴ أوزان).
enum ZiyadaKind { bihariWahid, biHarfayn, bithalathatiAhruf }

extension ZiyadaInfo on ZiyadaKind {
  String get arabic => switch (this) {
        ZiyadaKind.bihariWahid => 'مَزِيدٌ بِحَرْفٍ وَاحِدٍ',
        ZiyadaKind.biHarfayn => 'مَزِيدٌ بِحَرْفَيْنِ',
        ZiyadaKind.bithalathatiAhruf => 'مَزِيدٌ بِثَلَاثَةِ أَحْرُفٍ',
      };
}

// ═══════════════════════════════════════════════════════════════════════════
// الأقسام السبعة — by the nature of the root letters
// ═══════════════════════════════════════════════════════════════════════════

/// إرشاد الصرف مخ ۲۵ «بيان الأقسام السبعة» · شذا العرف page1_0016-0017
enum SahihMutal {
  salim,
  mudaaf,
  mahmuzFa,
  mahmuzAyn,
  mahmuzLam,
  mithal,
  ajwaf,
  naqis,
  lafifMafruq,
  lafifMaqrun,
}

extension SahihMutalInfo on SahihMutal {
  String get arabic => switch (this) {
        SahihMutal.salim => 'سَالِمٌ',
        SahihMutal.mudaaf => 'مُضَاعَفٌ',
        SahihMutal.mahmuzFa => 'مَهْمُوزُ الْفَاءِ',
        SahihMutal.mahmuzAyn => 'مَهْمُوزُ الْعَيْنِ',
        SahihMutal.mahmuzLam => 'مَهْمُوزُ اللَّامِ',
        SahihMutal.mithal => 'مِثَالٌ',
        SahihMutal.ajwaf => 'أَجْوَفُ',
        SahihMutal.naqis => 'نَاقِصٌ',
        SahihMutal.lafifMafruq => 'لَفِيفٌ مَفْرُوقٌ',
        SahihMutal.lafifMaqrun => 'لَفِيفٌ مَقْرُونٌ',
      };

  /// The upper split: صحيح vs معتل. «فالصحيح: ما خلت أصوله من أحرف العلّة»
  bool get isMutal => switch (this) {
        SahihMutal.mithal ||
        SahihMutal.ajwaf ||
        SahihMutal.naqis ||
        SahihMutal.lafifMafruq ||
        SahihMutal.lafifMaqrun =>
          true,
        _ => false,
      };

  bool get isMahmuz => switch (this) {
        SahihMutal.mahmuzFa || SahihMutal.mahmuzAyn || SahihMutal.mahmuzLam => true,
        _ => false,
      };
}

// ═══════════════════════════════════════════════════════════════════════════
// The ṣīgha grid — 14 cells
// ═══════════════════════════════════════════════════════════════════════════

enum Person { ghaib, mukhatab, mutakallim }

/// The Persian original names the mutakallim ṣīghas **مشترک** — shared
/// between masculine and feminine — so gender is a three-way choice, not two.
/// docs/sarf/07-tasrif-kabir.md § ۷.۰
enum Gender { mudhakkar, muannath, mushtarak }

enum Number { wahid, tathniya, jam }

/// The 14 ṣīghas in the order every madrasa recites them.
/// docs/sarf/07-tasrif-kabir.md § ۷.۱
enum Sigha {
  wahidMudhakkarGhaib,
  tathniyaMudhakkarGhaib,
  jamMudhakkarGhaib,
  wahidaMuannathGhaiba,
  tathniyaMuannathGhaiba,
  jamMuannathGhaiba,
  wahidMudhakkarMukhatab,
  tathniyaMudhakkarMukhatab,
  jamMudhakkarMukhatab,
  wahidaMuannathMukhataba,
  tathniyaMuannathMukhataba,
  jamMuannathMukhataba,
  wahidMutakallim,
  jamMutakallim,
}

extension SighaInfo on Sigha {
  int get order => index + 1;

  Person get person => switch (this) {
        Sigha.wahidMudhakkarGhaib ||
        Sigha.tathniyaMudhakkarGhaib ||
        Sigha.jamMudhakkarGhaib ||
        Sigha.wahidaMuannathGhaiba ||
        Sigha.tathniyaMuannathGhaiba ||
        Sigha.jamMuannathGhaiba =>
          Person.ghaib,
        Sigha.wahidMutakallim || Sigha.jamMutakallim => Person.mutakallim,
        _ => Person.mukhatab,
      };

  Gender get gender => switch (this) {
        Sigha.wahidMutakallim || Sigha.jamMutakallim => Gender.mushtarak,
        Sigha.wahidaMuannathGhaiba ||
        Sigha.tathniyaMuannathGhaiba ||
        Sigha.jamMuannathGhaiba ||
        Sigha.wahidaMuannathMukhataba ||
        Sigha.tathniyaMuannathMukhataba ||
        Sigha.jamMuannathMukhataba =>
          Gender.muannath,
        _ => Gender.mudhakkar,
      };

  Number get number => switch (this) {
        Sigha.tathniyaMudhakkarGhaib ||
        Sigha.tathniyaMuannathGhaiba ||
        Sigha.tathniyaMudhakkarMukhatab ||
        Sigha.tathniyaMuannathMukhataba =>
          Number.tathniya,
        Sigha.jamMudhakkarGhaib ||
        Sigha.jamMuannathGhaiba ||
        Sigha.jamMudhakkarMukhatab ||
        Sigha.jamMuannathMukhataba ||
        Sigha.jamMutakallim =>
          Number.jam,
        _ => Number.wahid,
      };

  /// The full Arabic name, exactly as إرشاد الصرف recites it:
  /// «صيغة الواحد المذكر الغائب».
  String get arabicName {
    final n = switch (number) {
      Number.wahid => gender == Gender.muannath ? 'الْوَاحِدَةِ' : 'الْوَاحِدِ',
      Number.tathniya => 'التَّثْنِيَةِ',
      Number.jam => 'الْجَمْعِ',
    };
    if (person == Person.mutakallim) {
      return number == Number.wahid
          ? 'صِيغَةُ الْوَاحِدِ الْمُتَكَلِّمِ الْمُشْتَرَكِ'
          : 'صِيغَةُ الْجَمْعِ الْمُتَكَلِّمِ مَعَ الْغَيْرِ الْمُشْتَرَكِ';
    }
    final g = gender == Gender.muannath ? 'الْمُؤَنَّثِ' : 'الْمُذَكَّرِ';
    final p = switch ((person, number, gender)) {
      (Person.ghaib, Number.wahid, Gender.muannath) => 'الْغَائِبَةِ',
      (Person.ghaib, Number.wahid, _) => 'الْغَائِبِ',
      (Person.ghaib, Number.tathniya, Gender.muannath) => 'الْغَائِبَتَيْنِ',
      (Person.ghaib, Number.tathniya, _) => 'الْغَائِبَيْنِ',
      (Person.ghaib, Number.jam, Gender.muannath) => 'الْغَائِبَاتِ',
      (Person.ghaib, Number.jam, _) => 'الْغَائِبِينَ',
      (_, Number.wahid, Gender.muannath) => 'الْمُخَاطَبَةِ',
      (_, Number.wahid, _) => 'الْمُخَاطَبِ',
      (_, Number.tathniya, Gender.muannath) => 'الْمُخَاطَبَتَيْنِ',
      (_, Number.tathniya, _) => 'الْمُخَاطَبَيْنِ',
      (_, Number.jam, Gender.muannath) => 'الْمُخَاطَبَاتِ',
      (_, Number.jam, _) => 'الْمُخَاطَبِينَ',
    };
    return 'صِيغَةُ $n $g $p';
  }

  /// The standalone pronoun, shown beside the ṣīgha so the reader can tell
  /// ضَرَبْتُمَا (dual masc.) from ضَرَبْتُمَا (dual fem.) — they are the
  /// same word and only the name distinguishes them.
  String get pronoun => switch (this) {
        Sigha.wahidMudhakkarGhaib => 'هُوَ',
        Sigha.tathniyaMudhakkarGhaib => 'هُمَا',
        Sigha.jamMudhakkarGhaib => 'هُمْ',
        Sigha.wahidaMuannathGhaiba => 'هِيَ',
        Sigha.tathniyaMuannathGhaiba => 'هُمَا',
        Sigha.jamMuannathGhaiba => 'هُنَّ',
        Sigha.wahidMudhakkarMukhatab => 'أَنْتَ',
        Sigha.tathniyaMudhakkarMukhatab => 'أَنْتُمَا',
        Sigha.jamMudhakkarMukhatab => 'أَنْتُمْ',
        Sigha.wahidaMuannathMukhataba => 'أَنْتِ',
        Sigha.tathniyaMuannathMukhataba => 'أَنْتُمَا',
        Sigha.jamMuannathMukhataba => 'أَنْتُنَّ',
        Sigha.wahidMutakallim => 'أَنَا',
        Sigha.jamMutakallim => 'نَحْنُ',
      };

  /// Does this cell accept **nūn al-tawkīd al-khafīfa**?
  ///
  /// شذا العرف page1_0047 forbids it after alif al-ithnayn and after the alif
  /// that separates nūn al-niswa; إرشاد الصرف then *shows* the consequence —
  /// its khafīfa tables run 3 cells (ḥāḍir) and 5 (ghāʾib) instead of 6 and 8.
  /// docs/sarf/07-tasrif-kabir.md § ۷.۳
  bool get acceptsNunKhafifa =>
      number != Number.tathniya &&
      !(number == Number.jam && gender == Gender.muannath);
}

/// The ṣīghas an amr/nahy addressed to the ḥāḍir actually has — the six
/// mukhāṭab cells. docs/sarf/07-tasrif-kabir.md § ۷.۳أ
const List<Sigha> hadirSighas = [
  Sigha.wahidMudhakkarMukhatab,
  Sigha.tathniyaMudhakkarMukhatab,
  Sigha.jamMudhakkarMukhatab,
  Sigha.wahidaMuannathMukhataba,
  Sigha.tathniyaMuannathMukhataba,
  Sigha.jamMuannathMukhataba,
];

/// The eight cells of an amr/nahy bi-l-lām: the six ghāʾib plus the two
/// mutakallim. docs/sarf/07-tasrif-kabir.md § ۷.۳ب
const List<Sigha> ghaibSighas = [
  Sigha.wahidMudhakkarGhaib,
  Sigha.tathniyaMudhakkarGhaib,
  Sigha.jamMudhakkarGhaib,
  Sigha.wahidaMuannathGhaiba,
  Sigha.tathniyaMuannathGhaiba,
  Sigha.jamMuannathGhaiba,
  Sigha.wahidMutakallim,
  Sigha.jamMutakallim,
];

// ═══════════════════════════════════════════════════════════════════════════
// The abwāb
// ═══════════════════════════════════════════════════════════════════════════

/// A bāb of the ثلاثي مجرد.
///
/// **The numbering follows إرشاد الصرف** — الباب الأول is ضَرَبَ يَضْرِبُ,
/// not نَصَرَ يَنْصُرُ. شذا العرف orders them differently, so both numbers
/// are kept and neither is ever hard-coded into a label.
/// docs/sarf/02-abwab.md § ۲.۱
class Bab {
  const Bab({
    required this.id,
    required this.irshadNumber,
    required this.shadhaNumber,
    required this.madiVowel,
    required this.mudariVowel,
    required this.exemplarMadi,
    required this.exemplarMudari,
  });

  final String id;
  final int irshadNumber;
  final int shadhaNumber;
  final Hrk madiVowel;
  final Hrk mudariVowel;
  final String exemplarMadi;
  final String exemplarMudari;

  String get label => '$exemplarMadi $exemplarMudari';

  /// The wazn as the books write it: فَعَلَ يَفْعِلُ.
  String get wazn {
    final m = 'فَع${madiVowel.mark}لَ';
    final d = 'يَفْع${mudariVowel.mark}لُ';
    return '$m $d';
  }
}

/// The six abwāb, in إرشاد الصرف's order. docs/sarf/02-abwab.md § ۲.۱
const Bab babDarb = Bab(
  id: 'darb',
  irshadNumber: 1,
  shadhaNumber: 2,
  madiVowel: Hrk.fatha,
  mudariVowel: Hrk.kasra,
  exemplarMadi: 'ضَرَبَ',
  exemplarMudari: 'يَضْرِبُ',
);
const Bab babNasr = Bab(
  id: 'nasr',
  irshadNumber: 2,
  shadhaNumber: 1,
  madiVowel: Hrk.fatha,
  mudariVowel: Hrk.damma,
  exemplarMadi: 'نَصَرَ',
  exemplarMudari: 'يَنْصُرُ',
);
const Bab babSami = Bab(
  id: 'sami',
  irshadNumber: 3,
  shadhaNumber: 4,
  madiVowel: Hrk.kasra,
  mudariVowel: Hrk.fatha,
  exemplarMadi: 'سَمِعَ',
  exemplarMudari: 'يَسْمَعُ',
);
const Bab babFath = Bab(
  id: 'fath',
  irshadNumber: 4,
  shadhaNumber: 3,
  madiVowel: Hrk.fatha,
  mudariVowel: Hrk.fatha,
  exemplarMadi: 'فَتَحَ',
  exemplarMudari: 'يَفْتَحُ',
);
const Bab babHasib = Bab(
  id: 'hasib',
  irshadNumber: 5,
  shadhaNumber: 6,
  madiVowel: Hrk.kasra,
  mudariVowel: Hrk.kasra,
  exemplarMadi: 'حَسِبَ',
  exemplarMudari: 'يَحْسِبُ',
);
const Bab babKaram = Bab(
  id: 'karam',
  irshadNumber: 6,
  shadhaNumber: 5,
  madiVowel: Hrk.damma,
  mudariVowel: Hrk.damma,
  exemplarMadi: 'كَرُمَ',
  exemplarMudari: 'يَكْرُمُ',
);

/// Ordered by irshadNumber — this is the order the app displays.
const List<Bab> abwabThulathiMujarrad = [
  babDarb,
  babNasr,
  babSami,
  babFath,
  babHasib,
  babKaram,
];

Bab? babById(String id) {
  for (final b in abwabThulathiMujarrad) {
    if (b.id == id) return b;
  }
  return null;
}
