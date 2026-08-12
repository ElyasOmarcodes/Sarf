/// The awzān: how each bāb builds its stem, and how a typed word is matched
/// back to one.
///
/// Sources: شذا العرف page1_0024–0026 (the +1/+2/+3 lists) and إرشاد الصرف
/// مخ ۱۴۱–۱۴۲ («خلاصة الأبواب إجمالًا» — ۴۰ بابًا). docs/sarf/02-abwab.md
library;

import 'arabic.dart';
import 'lang.dart';
import 'models.dart';

/// A slot in a wazn's written skeleton: either a root position or a fixed
/// letter. Matching happens on the **rasm** — the doubled ʿayn of فَعَّلَ is
/// written once, so `عَلَّمَ` and `عَلِمَ` share a skeleton and the engine
/// has to offer both readings.
sealed class Slot {
  const Slot();
}

class RootSlot extends Slot {
  const RootSlot(this.i);
  final int i; // 0=ف 1=ع 2=ل 3=ل٢ 4=ل٣
}

class LitSlot extends Slot {
  const LitSlot(this.c);
  final String c;
}

const _f = RootSlot(0);
const _a = RootSlot(1);
const _l = RootSlot(2);
const _l2 = RootSlot(3);
const _l3 = RootSlot(4);

/// A verbal bāb: its identity, its place in the six-way بناء split, and the
/// stems it builds.
class Wazn {
  const Wazn({
    required this.id,
    required this.arabicName,
    required this.madiPattern,
    required this.mudariPattern,
    required this.masdarPattern,
    required this.bina,
    required this.skeleton,
    this.ziyada,
    this.meaning,
  });

  final String id;

  /// The maṣdar-name the books call the bāb by: الْإِفْعَال, التَّفْعِيل …
  final String arabicName;
  final String madiPattern;
  final String mudariPattern;
  final String masdarPattern;
  final Bina bina;
  final ZiyadaKind? ziyada;

  /// Written skeleton, for matching a typed word.
  final List<Slot> skeleton;

  /// «معاني صيغ الزوائد» — the headline sense, docs/sarf/02-abwab.md § ۲.۴.
  final L4? meaning;

  int get rootLength => bina.rootLength;

  bool get isThulathiMujarrad => bina == Bina.thulathiMujarrad;
}

// ═══════════════════════════════════════════════════════════════════════════
// The table
// ═══════════════════════════════════════════════════════════════════════════

const Wazn waznThulathiMujarrad = Wazn(
  id: 'mujarrad3',
  arabicName: 'الثُّلَاثِيُّ الْمُجَرَّدُ',
  madiPattern: 'فَعَلَ',
  mudariPattern: 'يَفْعِلُ',
  masdarPattern: 'فَعْلٌ',
  bina: Bina.thulathiMujarrad,
  skeleton: [_f, _a, _l],
);

const List<Wazn> awzanThulathiMazid = [
  Wazn(
    id: 'ifal',
    arabicName: 'الْإِفْعَالُ',
    madiPattern: 'أَفْعَلَ',
    mudariPattern: 'يُفْعِلُ',
    masdarPattern: 'إِفْعَالٌ',
    bina: Bina.thulathiMazid,
    ziyada: ZiyadaKind.bihariWahid,
    skeleton: [LitSlot(alif), _f, _a, _l],
    meaning: L4(
      'تعدیه — لازم فعل متعدي کول (أقمتُ زیداً). همدارنګه: صیرورت، دخول، '
          'سلب او ازاله.',
      'تعدیه — لازم را متعدی کردن (أقمتُ زیداً). و نیز: صیرورت، دخول، سلب و '
          'ازاله.',
      'التَّعْدِيَةُ، وَصَيْرُورَةُ شَيْءٍ ذَا شَيْءٍ، وَالدُّخُولُ فِي '
          'شَيْءٍ، وَالسَّلْبُ وَالْإِزَالَةُ.',
      'Making an intransitive verb transitive; also entering a state, coming '
          'to possess something, or removing it.',
    ),
  ),
  Wazn(
    id: 'tafil',
    arabicName: 'التَّفْعِيلُ',
    madiPattern: 'فَعَّلَ',
    mudariPattern: 'يُفَعِّلُ',
    masdarPattern: 'تَفْعِيلٌ',
    bina: Bina.thulathiMazid,
    ziyada: ZiyadaKind.bihariWahid,
    skeleton: [_f, _a, _l],
    meaning: L4(
      'تکثیر — د فعل، فاعل یا مفعول ډېرښت (غلَّقَ الأبواب). همدارنګه تعدیه، '
          'ازاله، او نسبت.',
      'تکثیر — فزونی در فعل، فاعل یا مفعول (غلَّقَ الأبواب). و نیز تعدیه، '
          'ازاله و نسبت.',
      'التَّكْثِيرُ فِي الْفِعْلِ أَوِ الْفَاعِلِ أَوِ الْمَفْعُولِ، '
          'وَالتَّعْدِيَةُ، وَالْإِزَالَةُ، وَنِسْبَةُ الشَّيْءِ إِلَى '
          'أَصْلِ الْفِعْلِ.',
      'Doing something a great deal, or to many objects; also transitivising, '
          'removing, and ascribing.',
    ),
  ),
  Wazn(
    id: 'mufaala',
    arabicName: 'الْمُفَاعَلَةُ',
    madiPattern: 'فَاعَلَ',
    mudariPattern: 'يُفَاعِلُ',
    masdarPattern: 'مُفَاعَلَةٌ',
    bina: Bina.thulathiMazid,
    ziyada: ZiyadaKind.bihariWahid,
    skeleton: [_f, LitSlot(alif), _a, _l],
    meaning: L4(
      'مشارکت — د دوو یا زیاتو ترمنځ (ماشیته)؛ پیل‌کوونکی فاعل دی. '
          'همدارنګه موالات.',
      'مشارکت میان دو یا بیشتر (ماشیته)؛ آغازکننده فاعل است. و نیز موالات.',
      'الْمُشَارَكَةُ بَيْنَ اثْنَيْنِ فَأَكْثَرَ، وَالْمُوَالَاةُ.',
      'Doing something mutually with someone else; also doing it continuously.',
    ),
  ),
  Wazn(
    id: 'tafaul',
    arabicName: 'التَّفَعُّلُ',
    madiPattern: 'تَفَعَّلَ',
    mudariPattern: 'يَتَفَعَّلُ',
    masdarPattern: 'تَفَعُّلٌ',
    bina: Bina.thulathiMazid,
    ziyada: ZiyadaKind.biHarfayn,
    skeleton: [LitSlot(ta), _f, _a, _l],
    meaning: L4(
      'مطاوعت د فعَّل (نبَّهته فتنبَّه)، تکلُّف، اتخاذ، تجنُّب، او تدریج.',
      'مطاوعت فعَّل (نبَّهته فتنبَّه)، تکلّف، اتخاذ، تجنّب و تدریج.',
      'مُطَاوَعَةُ فَعَّلَ، وَالتَّكَلُّفُ، وَالِاتِّخَاذُ، '
          'وَالتَّجَنُّبُ، وَالتَّدْرِيجُ.',
      'Responding to the faʿʿala form; also taking something on with effort, '
          'adopting it, avoiding it, or doing it step by step.',
    ),
  ),
  Wazn(
    id: 'tafaaul',
    arabicName: 'التَّفَاعُلُ',
    madiPattern: 'تَفَاعَلَ',
    mudariPattern: 'يَتَفَاعَلُ',
    masdarPattern: 'تَفَاعُلٌ',
    bina: Bina.thulathiMazid,
    ziyada: ZiyadaKind.biHarfayn,
    skeleton: [LitSlot(ta), _f, LitSlot(alif), _a, _l],
    meaning: L4(
      'تشریک — دواړه فاعلان دي (تجاذبا)؛ تظاهر بې حقیقته (تناوَمَ)؛ تدریج؛ '
          'مطاوعت د فاعَلَ.',
      'تشریک — هر دو فاعل‌اند (تجاذبا)؛ تظاهر بدون حقیقت (تناوَمَ)؛ تدریج؛ '
          'مطاوعت فاعَلَ.',
      'التَّشْرِيكُ بَيْنَ اثْنَيْنِ فَأَكْثَرَ، وَالتَّظَاهُرُ '
          'بِالْفِعْلِ دُونَ حَقِيقَتِهِ، وَالتَّدْرِيجُ، وَمُطَاوَعَةُ '
          'فَاعَلَ.',
      'Both parties act; also feigning the act, doing it gradually, and '
          'responding to the fāʿala form.',
    ),
  ),
  Wazn(
    id: 'iftial',
    arabicName: 'الِافْتِعَالُ',
    madiPattern: 'افْتَعَلَ',
    mudariPattern: 'يَفْتَعِلُ',
    masdarPattern: 'افْتِعَالٌ',
    bina: Bina.thulathiMazid,
    ziyada: ZiyadaKind.biHarfayn,
    skeleton: [LitSlot(alif), _f, LitSlot(ta), _a, _l],
    meaning: L4(
      'اتخاذ، اجتهاد او طلب (اکتسب)، تشارک، اظهار، مبالغه، او د ثلاثي مطاوعت.',
      'اتخاذ، اجتهاد و طلب (اکتسب)، تشارک، اظهار، مبالغه و مطاوعت ثلاثی.',
      'الِاتِّخَاذُ، وَالِاجْتِهَادُ وَالطَّلَبُ، وَالتَّشَارُكُ، '
          'وَالْإِظْهَارُ، وَالْمُبَالَغَةُ، وَمُطَاوَعَةُ الثُّلَاثِيِّ.',
      'Taking something for oneself, striving after it, sharing in it, showing '
          'it, doing it intensely — and responding to the bare form.',
    ),
  ),
  Wazn(
    id: 'infial',
    arabicName: 'الِانْفِعَالُ',
    madiPattern: 'انْفَعَلَ',
    mudariPattern: 'يَنْفَعِلُ',
    masdarPattern: 'انْفِعَالٌ',
    bina: Bina.thulathiMazid,
    ziyada: ZiyadaKind.biHarfayn,
    skeleton: [LitSlot(alif), LitSlot(nun), _f, _a, _l],
    meaning: L4(
      'یوازې مطاوعت (کسرته فانکسر). نو تل لازم دی، او یوازې په علاجي '
          'فعلونو کې راځي.',
      'تنها مطاوعت (کسرته فانکسر). پس همیشه لازم است و تنها در افعال علاجی '
          'می‌آید.',
      'الْمُطَاوَعَةُ لَا غَيْرُ، وَلِهَذَا لَا يَكُونُ إِلَّا لَازِمًا، '
          'وَلَا يَكُونُ إِلَّا فِي الْأَفْعَالِ الْعِلَاجِيَّةِ.',
      'Only ever the passive-response sense — so it is always intransitive, '
          'and only used of physical actions.',
    ),
  ),
  Wazn(
    id: 'istifal',
    arabicName: 'الِاسْتِفْعَالُ',
    madiPattern: 'اسْتَفْعَلَ',
    mudariPattern: 'يَسْتَفْعِلُ',
    masdarPattern: 'اسْتِفْعَالٌ',
    bina: Bina.thulathiMazid,
    ziyada: ZiyadaKind.bithalathatiAhruf,
    skeleton: [LitSlot(alif), LitSlot(sin), LitSlot(ta), _f, _a, _l],
    meaning: L4(
      'طلب (استغفر)، صیرورت، د یو شي د صفت اعتقاد، اختصار حکایت، قوت، '
          'او مصادفت.',
      'طلب (استغفر)، صیرورت، اعتقاد صفت شیء، اختصار حکایت، قوّت و مصادفت.',
      'الطَّلَبُ، وَالصَّيْرُورَةُ، وَاعْتِقَادُ صِفَةِ الشَّيْءِ، '
          'وَاخْتِصَارُ حِكَايَةِ الشَّيْءِ، وَالْقُوَّةُ، '
          'وَالْمُصَادَفَةُ.',
      'Asking for something, turning into it, holding it to be so, saying a '
          'set phrase in short, intensity, and finding it to be the case.',
    ),
  ),
  Wazn(
    id: 'ifilal',
    arabicName: 'الِافْعِلَالُ',
    madiPattern: 'افْعَلَّ',
    mudariPattern: 'يَفْعَلُّ',
    masdarPattern: 'افْعِلَالٌ',
    bina: Bina.thulathiMazid,
    ziyada: ZiyadaKind.biHarfayn,
    // The doubled lām is written once, but the shadda-expanded candidate
    // spells it out — so the skeleton names it twice.
    skeleton: [LitSlot(alif), _f, _a, _l, _l],
    meaning: L4(
      'د رنګ یا عیب قوت (احمرَّ، اعورَّ). تل لازم دی.',
      'قوّت رنگ یا عیب (احمرَّ، اعورَّ). همیشه لازم است.',
      'قُوَّةُ اللَّوْنِ أَوِ الْعَيْبِ، وَلَا يَكُونُ إِلَّا لَازِمًا.',
      'An intense colour or bodily defect. Always intransitive.',
    ),
  ),
  Wazn(
    id: 'ifilal2',
    arabicName: 'الِافْعِيلَالُ',
    madiPattern: 'افْعَالَّ',
    mudariPattern: 'يَفْعَالُّ',
    masdarPattern: 'افْعِيلَالٌ',
    bina: Bina.thulathiMazid,
    ziyada: ZiyadaKind.bithalathatiAhruf,
    skeleton: [LitSlot(alif), _f, _a, LitSlot(alif), _l],
    meaning: L4(
      'له افعلَّ څخه قوي‌تر رنګ (احمارَّ).',
      'رنگی قوی‌تر از افعلَّ (احمارَّ).',
      'أَقْوَى مِنَ افْعَلَّ فِي اللَّوْنِ.',
      'A colour even more intense than the ifʿalla form.',
    ),
  ),
  Wazn(
    id: 'ifiwwal',
    arabicName: 'الِافْعِوَّالُ',
    madiPattern: 'افْعَوَّلَ',
    mudariPattern: 'يَفْعَوِّلُ',
    masdarPattern: 'افْعِوَّالٌ',
    bina: Bina.thulathiMazid,
    ziyada: ZiyadaKind.bithalathatiAhruf,
    skeleton: [LitSlot(alif), _f, _a, LitSlot(waw), _l],
    meaning: L4('د معنی قوت.', 'قوّت معنا.', 'قُوَّةُ الْمَعْنَى.',
        'Intensity of the base meaning.'),
  ),
  Wazn(
    id: 'ifiyal',
    arabicName: 'الِافْعِيعَالُ',
    madiPattern: 'افْعَوْعَلَ',
    mudariPattern: 'يَفْعَوْعِلُ',
    masdarPattern: 'افْعِيعَالٌ',
    bina: Bina.thulathiMazid,
    ziyada: ZiyadaKind.bithalathatiAhruf,
    skeleton: [LitSlot(alif), _f, _a, LitSlot(waw), _a, _l],
    meaning: L4('د معنی قوت (اعشوشب المکان).', 'قوّت معنا (اعشوشب المکان).',
        'قُوَّةُ الْمَعْنَى، نَحْوُ اعْشَوْشَبَ الْمَكَانُ.',
        'Intensity of the base meaning — the place became thick with grass.'),
  ),
];

const List<Wazn> awzanRubai = [
  Wazn(
    id: 'falala',
    arabicName: 'الْفَعْلَلَةُ',
    madiPattern: 'فَعْلَلَ',
    mudariPattern: 'يُفَعْلِلُ',
    masdarPattern: 'فَعْلَلَةٌ',
    bina: Bina.rubaiMujarrad,
    skeleton: [_f, _a, _l, _l2],
  ),
  Wazn(
    id: 'tafalul',
    arabicName: 'التَّفَعْلُلُ',
    madiPattern: 'تَفَعْلَلَ',
    mudariPattern: 'يَتَفَعْلَلُ',
    masdarPattern: 'تَفَعْلُلٌ',
    bina: Bina.rubaiMazid,
    ziyada: ZiyadaKind.bihariWahid,
    skeleton: [LitSlot(ta), _f, _a, _l, _l2],
  ),
  Wazn(
    id: 'ifanlal',
    arabicName: 'الِافْعِنْلَالُ',
    madiPattern: 'افْعَنْلَلَ',
    mudariPattern: 'يَفْعَنْلِلُ',
    masdarPattern: 'افْعِنْلَالٌ',
    bina: Bina.rubaiMazid,
    ziyada: ZiyadaKind.biHarfayn,
    skeleton: [LitSlot(alif), _f, _a, LitSlot(nun), _l, _l2],
  ),
  Wazn(
    id: 'ifillal',
    arabicName: 'الِافْعِلَّالُ',
    madiPattern: 'افْعَلَلَّ',
    mudariPattern: 'يَفْعَلِلُّ',
    masdarPattern: 'افْعِلَّالٌ',
    bina: Bina.rubaiMazid,
    ziyada: ZiyadaKind.biHarfayn,
    skeleton: [LitSlot(alif), _f, _a, _l, _l2],
  ),
];

const Wazn waznKhumasiMujarrad = Wazn(
  id: 'faalall',
  arabicName: 'الْخُمَاسِيُّ الْمُجَرَّدُ',
  madiPattern: 'فَعَلَّلَ',
  mudariPattern: '—',
  masdarPattern: '—',
  bina: Bina.khumasiMujarrad,
  skeleton: [_f, _a, _l, _l2, _l3],
);

/// Every verbal wazn the matcher knows, longest skeleton first so that
/// اسْتَفْعَلَ is tried before فَعَلَ.
List<Wazn> get allVerbAwzan => [
      ...awzanThulathiMazid,
      ...awzanRubai,
      waznThulathiMujarrad,
      waznKhumasiMujarrad,
    ];

Wazn? waznById(String id) {
  for (final w in allVerbAwzan) {
    if (w.id == id) return w;
  }
  return null;
}

// ═══════════════════════════════════════════════════════════════════════════
// Derived-noun patterns — used for recognising a typed مُكْتَسِب or مَضْرُوب
// ═══════════════════════════════════════════════════════════════════════════

/// What a matched noun turned out to be.
enum DerivedKind {
  ismFail,
  ismMaful,
  masdar,
  ismZarf,
  ismAala,
  ismTafdil,
  sifaMushabbaha,
  ismMubalagha,
}

class NounPattern {
  const NounPattern({
    required this.kind,
    required this.pattern,
    required this.skeleton,
    required this.waznId,
  });

  final DerivedKind kind;
  final String pattern;
  final List<Slot> skeleton;

  /// Which verbal bāb this noun belongs to.
  final String waznId;
}

const List<NounPattern> nounPatterns = [
  // ── from the ثلاثي مجرد ──
  NounPattern(
    kind: DerivedKind.ismFail,
    pattern: 'فَاعِلٌ',
    skeleton: [_f, LitSlot(alif), _a, _l],
    waznId: 'mujarrad3',
  ),
  NounPattern(
    kind: DerivedKind.ismMaful,
    pattern: 'مَفْعُولٌ',
    skeleton: [LitSlot(mim), _f, _a, LitSlot(waw), _l],
    waznId: 'mujarrad3',
  ),
  NounPattern(
    kind: DerivedKind.ismZarf,
    pattern: 'مَفْعَلٌ',
    skeleton: [LitSlot(mim), _f, _a, _l],
    waznId: 'mujarrad3',
  ),
  NounPattern(
    kind: DerivedKind.ismAala,
    pattern: 'مِفْعَالٌ',
    skeleton: [LitSlot(mim), _f, _a, LitSlot(alif), _l],
    waznId: 'mujarrad3',
  ),
  NounPattern(
    kind: DerivedKind.ismTafdil,
    pattern: 'أَفْعَلُ',
    skeleton: [LitSlot(alif), _f, _a, _l],
    waznId: 'mujarrad3',
  ),
  NounPattern(
    kind: DerivedKind.sifaMushabbaha,
    pattern: 'فَعِيلٌ',
    skeleton: [_f, _a, LitSlot(ya), _l],
    waznId: 'mujarrad3',
  ),
  // فَعَّالٌ is deliberately absent: its rasm is identical to the bare
  // فَعَلَ, so listing it here made every three-letter word report a
  // spurious second reading. It is still produced as a مشتق.
  // ── from the مزيد ──
  NounPattern(
    kind: DerivedKind.ismFail,
    pattern: 'مُفْعِلٌ',
    skeleton: [LitSlot(mim), _f, _a, _l],
    waznId: 'ifal',
  ),
  NounPattern(
    kind: DerivedKind.ismFail,
    pattern: 'مُفَعِّلٌ',
    skeleton: [LitSlot(mim), _f, _a, _l],
    waznId: 'tafil',
  ),
  NounPattern(
    kind: DerivedKind.ismFail,
    pattern: 'مُفَاعِلٌ',
    skeleton: [LitSlot(mim), _f, LitSlot(alif), _a, _l],
    waznId: 'mufaala',
  ),
  NounPattern(
    kind: DerivedKind.ismFail,
    pattern: 'مُتَفَعِّلٌ',
    skeleton: [LitSlot(mim), LitSlot(ta), _f, _a, _l],
    waznId: 'tafaul',
  ),
  NounPattern(
    kind: DerivedKind.ismFail,
    pattern: 'مُتَفَاعِلٌ',
    skeleton: [LitSlot(mim), LitSlot(ta), _f, LitSlot(alif), _a, _l],
    waznId: 'tafaaul',
  ),
  NounPattern(
    kind: DerivedKind.ismFail,
    pattern: 'مُفْتَعِلٌ',
    skeleton: [LitSlot(mim), _f, LitSlot(ta), _a, _l],
    waznId: 'iftial',
  ),
  NounPattern(
    kind: DerivedKind.ismFail,
    pattern: 'مُنْفَعِلٌ',
    skeleton: [LitSlot(mim), LitSlot(nun), _f, _a, _l],
    waznId: 'infial',
  ),
  NounPattern(
    kind: DerivedKind.ismFail,
    pattern: 'مُسْتَفْعِلٌ',
    skeleton: [LitSlot(mim), LitSlot(sin), LitSlot(ta), _f, _a, _l],
    waznId: 'istifal',
  ),
  NounPattern(
    kind: DerivedKind.ismFail,
    pattern: 'مُفَعْلِلٌ',
    skeleton: [LitSlot(mim), _f, _a, _l, _l2],
    waznId: 'falala',
  ),
  // ── maṣādir of the مزيد ──
  NounPattern(
    kind: DerivedKind.masdar,
    pattern: 'إِفْعَالٌ',
    skeleton: [LitSlot(alif), _f, _a, LitSlot(alif), _l],
    waznId: 'ifal',
  ),
  NounPattern(
    kind: DerivedKind.masdar,
    pattern: 'تَفْعِيلٌ',
    skeleton: [LitSlot(ta), _f, _a, LitSlot(ya), _l],
    waznId: 'tafil',
  ),
  NounPattern(
    kind: DerivedKind.masdar,
    pattern: 'مُفَاعَلَةٌ',
    skeleton: [LitSlot(mim), _f, LitSlot(alif), _a, _l, LitSlot(taMarbuta)],
    waznId: 'mufaala',
  ),
  NounPattern(
    kind: DerivedKind.masdar,
    pattern: 'افْتِعَالٌ',
    skeleton: [LitSlot(alif), _f, LitSlot(ta), _a, LitSlot(alif), _l],
    waznId: 'iftial',
  ),
  NounPattern(
    kind: DerivedKind.masdar,
    pattern: 'انْفِعَالٌ',
    skeleton: [LitSlot(alif), LitSlot(nun), _f, _a, LitSlot(alif), _l],
    waznId: 'infial',
  ),
  NounPattern(
    kind: DerivedKind.masdar,
    pattern: 'اسْتِفْعَالٌ',
    skeleton: [
      LitSlot(alif),
      LitSlot(sin),
      LitSlot(ta),
      _f,
      _a,
      LitSlot(alif),
      _l,
    ],
    waznId: 'istifal',
  ),
  NounPattern(
    kind: DerivedKind.masdar,
    pattern: 'فَعْلَلَةٌ',
    skeleton: [_f, _a, _l, _l2, LitSlot(taMarbuta)],
    waznId: 'falala',
  ),
];

extension DerivedKindInfo on DerivedKind {
  String get arabic => switch (this) {
        DerivedKind.ismFail => 'اسْمُ الْفَاعِلِ',
        DerivedKind.ismMaful => 'اسْمُ الْمَفْعُولِ',
        DerivedKind.masdar => 'الْمَصْدَرُ',
        DerivedKind.ismZarf => 'اسْمُ الزَّمَانِ وَالْمَكَانِ',
        DerivedKind.ismAala => 'اسْمُ الْآلَةِ',
        DerivedKind.ismTafdil => 'اسْمُ التَّفْضِيلِ',
        DerivedKind.sifaMushabbaha => 'الصِّفَةُ الْمُشَبَّهَةُ',
        DerivedKind.ismMubalagha => 'اسْمُ الْمُبَالَغَةِ',
      };
}
