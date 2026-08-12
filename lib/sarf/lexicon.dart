/// The سماعي layer.
///
/// The books are blunt about this: which bāb a ثلاثي مجرد belongs to cannot
/// be worked out, only heard —
///
/// > «كون الثلاثي على وزن معين من الأوزان الستة المتقدمة **سماعيّ**، فلا
/// > يعتمد في معرفتها على قاعدة» — شذا العرف page1_0023
///
/// So the app stores it rather than deriving it. What *can* be derived is a
/// good guess, and [guessBab] does that from the ḍawābiṭ the same page gives;
/// anything it returns is marked [Provenance.muwallad] and the UI says so.
library;

import 'arabic.dart';
import 'models.dart';

/// A root the lexicon knows: its bāb and its (سماعي) maṣdar.
class LexEntry {
  const LexEntry(this.babId, this.masdar, {this.gloss});
  final String babId;
  final String masdar;

  /// A short Arabic gloss, used to seed the header card.
  final String? gloss;
}

/// Seeded with the verbs the books themselves conjugate, plus the ones a
/// student meets first. Keyed by the bare root letters joined.
const Map<String, LexEntry> lexicon = {
  // ── باب ضرب (الباب الأول عند إرشاد الصرف) ──
  'ضرب': LexEntry('darb', 'ضَرْبٌ', gloss: 'الضَّرْبُ'),
  'جلس': LexEntry('darb', 'جُلُوسٌ', gloss: 'الْجُلُوسُ'),
  'ضجع': LexEntry('darb', 'ضَجْعٌ'),
  'وعد': LexEntry('darb', 'وَعْدٌ', gloss: 'الْوَعْدُ'),
  'وزن': LexEntry('darb', 'وَزْنٌ'),
  'وصل': LexEntry('darb', 'وَصْلٌ'),
  'باع': LexEntry('darb', 'بَيْعٌ'),
  'بيع': LexEntry('darb', 'بَيْعٌ', gloss: 'الْبَيْعُ'),
  'رمي': LexEntry('darb', 'رَمْيٌ', gloss: 'الرَّمْيُ'),
  'وقي': LexEntry('darb', 'وِقَايَةٌ'),
  'طوي': LexEntry('darb', 'طَيٌّ'),
  'فرر': LexEntry('darb', 'فِرَارٌ'),
  'ءتي': LexEntry('darb', 'إِتْيَانٌ'),
  'حمل': LexEntry('darb', 'حَمْلٌ'),
  'عرف': LexEntry('darb', 'مَعْرِفَةٌ'),
  'كسب': LexEntry('darb', 'كَسْبٌ', gloss: 'الْكَسْبُ'),
  'صرف': LexEntry('darb', 'صَرْفٌ', gloss: 'الصَّرْفُ'),
  'غفر': LexEntry('darb', 'غُفْرَانٌ'),
  'ملك': LexEntry('darb', 'مِلْكٌ'),
  'قدر': LexEntry('darb', 'قُدْرَةٌ'),
  'عقد': LexEntry('darb', 'عَقْدٌ'),
  'كذب': LexEntry('darb', 'كَذِبٌ'),
  'ضحك': LexEntry('darb', 'ضَحِكٌ'),
  'وجد': LexEntry('darb', 'وُجُودٌ'),
  'ورث': LexEntry('darb', 'إِرْثٌ'),
  'وضع': LexEntry('fath', 'وَضْعٌ'),

  // ── باب نصر ──
  'نصر': LexEntry('nasr', 'نَصْرٌ', gloss: 'النَّصْرُ'),
  'قعد': LexEntry('nasr', 'قُعُودٌ'),
  'كتب': LexEntry('nasr', 'كِتَابَةٌ', gloss: 'الْكِتَابَةُ'),
  'خرج': LexEntry('nasr', 'خُرُوجٌ'),
  'دخل': LexEntry('nasr', 'دُخُولٌ'),
  'قتل': LexEntry('nasr', 'قَتْلٌ'),
  'طلب': LexEntry('nasr', 'طَلَبٌ'),
  'ءخذ': LexEntry('nasr', 'أَخْذٌ', gloss: 'الْأَخْذُ'),
  'ءكل': LexEntry('nasr', 'أَكْلٌ'),
  'ءمر': LexEntry('nasr', 'أَمْرٌ'),
  'قول': LexEntry('nasr', 'قَوْلٌ', gloss: 'الْقَوْلُ'),
  'قال': LexEntry('nasr', 'قَوْلٌ'),
  'صوم': LexEntry('nasr', 'صَوْمٌ'),
  'عود': LexEntry('nasr', 'عَوْدَةٌ'),
  'قوم': LexEntry('nasr', 'قِيَامٌ'),
  'غزو': LexEntry('nasr', 'غَزْوٌ', gloss: 'الْغَزْوُ'),
  'دعو': LexEntry('nasr', 'دُعَاءٌ'),
  'تلو': LexEntry('nasr', 'تِلَاوَةٌ'),
  'مدد': LexEntry('nasr', 'مَدٌّ'),
  'ردد': LexEntry('nasr', 'رَدٌّ'),
  'شدد': LexEntry('nasr', 'شَدٌّ'),
  'سرر': LexEntry('nasr', 'سُرُورٌ'),
  'نظر': LexEntry('nasr', 'نَظَرٌ'),
  'ذكر': LexEntry('nasr', 'ذِكْرٌ'),
  'شكر': LexEntry('nasr', 'شُكْرٌ'),
  'حسب': LexEntry('nasr', 'حُسْبَانٌ'),

  // ── باب سمع ──
  'سمع': LexEntry('sami', 'سَمْعٌ', gloss: 'السَّمْعُ'),
  'علم': LexEntry('sami', 'عِلْمٌ', gloss: 'الْعِلْمُ'),
  'فرح': LexEntry('sami', 'فَرَحٌ'),
  'شرب': LexEntry('sami', 'شُرْبٌ'),
  'فهم': LexEntry('sami', 'فَهْمٌ'),
  'حفظ': LexEntry('sami', 'حِفْظٌ'),
  'عمل': LexEntry('sami', 'عَمَلٌ'),
  'حمد': LexEntry('sami', 'حَمْدٌ'),
  'خوف': LexEntry('sami', 'خَوْفٌ'),
  'خاف': LexEntry('sami', 'خَوْفٌ'),
  'هيب': LexEntry('sami', 'هَيْبَةٌ'),
  'رضي': LexEntry('sami', 'رِضًا', gloss: 'الرِّضَا'),
  'بقي': LexEntry('sami', 'بَقَاءٌ'),
  'لقي': LexEntry('sami', 'لِقَاءٌ'),
  'نسي': LexEntry('sami', 'نِسْيَانٌ'),
  'عضض': LexEntry('sami', 'عَضٌّ'),
  'وجل': LexEntry('sami', 'وَجَلٌ'),
  'ءمن': LexEntry('sami', 'أَمْنٌ'),
  'يبس': LexEntry('sami', 'يُبْسٌ'),
  'عور': LexEntry('sami', 'عَوَرٌ'),

  // ── باب فتح ──
  'فتح': LexEntry('fath', 'فَتْحٌ', gloss: 'الْفَتْحُ'),
  'ذهب': LexEntry('fath', 'ذَهَابٌ'),
  'سعي': LexEntry('fath', 'سَعْيٌ', gloss: 'السَّعْيُ'),
  'قرء': LexEntry('fath', 'قِرَاءَةٌ', gloss: 'الْقِرَاءَةُ'),
  'سءل': LexEntry('fath', 'سُؤَالٌ'),
  'منع': LexEntry('fath', 'مَنْعٌ'),
  'نفع': LexEntry('fath', 'نَفْعٌ'),
  'جعل': LexEntry('fath', 'جَعْلٌ'),
  'قطع': LexEntry('fath', 'قَطْعٌ'),
  'رفع': LexEntry('fath', 'رَفْعٌ'),
  'دفع': LexEntry('fath', 'دَفْعٌ'),
  'شهد': LexEntry('fath', 'شَهَادَةٌ'),
  'بحث': LexEntry('fath', 'بَحْثٌ'),
  'وهل': LexEntry('fath', 'وَهَلٌ'),

  // ── باب حسب ──
  'ولي': LexEntry('hasib', 'وِلَايَةٌ'),
  'ورع': LexEntry('hasib', 'وَرَعٌ'),
  'وثق': LexEntry('hasib', 'ثِقَةٌ'),
  'ومق': LexEntry('hasib', 'مِقَةٌ'),
  'يءس': LexEntry('hasib', 'يَأْسٌ'),

  // ── باب كرم ──
  'كرم': LexEntry('karam', 'كَرَمٌ', gloss: 'الْكَرَمُ'),
  'شرف': LexEntry('karam', 'شَرَفٌ', gloss: 'الشَّرَفُ'),
  'حسن': LexEntry('karam', 'حُسْنٌ'),
  'عظم': LexEntry('karam', 'عِظَمٌ'),
  'صعب': LexEntry('karam', 'صُعُوبَةٌ'),
  'كبر': LexEntry('karam', 'كِبَرٌ'),
  'صغر': LexEntry('karam', 'صِغَرٌ'),
  'قرب': LexEntry('karam', 'قُرْبٌ'),
  'بعد': LexEntry('karam', 'بُعْدٌ'),
  'طول': LexEntry('karam', 'طُولٌ'),
  'سرو': LexEntry('karam', 'سَرْوٌ'),
  'نهو': LexEntry('karam', 'نُهْيَةٌ'),
  'فصح': LexEntry('karam', 'فَصَاحَةٌ'),
  'جمل': LexEntry('karam', 'جَمَالٌ'),
  'لءم': LexEntry('karam', 'لُؤْمٌ'),
};

LexEntry? lookup(List<String> root) =>
    lexicon[root.map(normalizeRootLetter).join()];

/// Best-effort bāb when the lexicon has never heard of the root.
///
/// The ḍawābiṭ are shadow rules only — شذا العرف page1_0022–0023 offers them
/// «غير أنه يمكن تقريبه بمراعاة هذه الضوابط» and no more than that.
({Bab bab, Provenance provenance}) guessBab(
  List<String> root,
  SahihMutal type,
) {
  final found = lookup(root);
  if (found != null) {
    final b = babById(found.babId);
    if (b != null) return (bab: b, provenance: Provenance.samai);
  }

  final f = normalizeRootLetter(root[0]);
  final a = root.length > 1 ? normalizeRootLetter(root[1]) : f;
  final l = root.length > 2 ? normalizeRootLetter(root[2]) : a;

  // الأجوف: واوي ← نصر، يائي ← ضرب. شذا العرف page1_0022 (التنبيه الرابع)
  if (type == SahihMutal.ajwaf) {
    return (bab: a == waw ? babNasr : babDarb, provenance: Provenance.muwallad);
  }
  // الناقص: واوي ← نصر، يائي ← ضرب — unless the lām is ألف in both, which is
  // باب فتح.
  if (type == SahihMutal.naqis) {
    return (bab: l == waw ? babNasr : babDarb, provenance: Provenance.muwallad);
  }
  // «كل ما كانت عينهُ مفتوحةٌ في الماضي والمضارع، فهو حَلْقيُّ العين أو اللام»
  if (isHalqi(a) || isHalqi(l)) {
    return (bab: babFath, provenance: Provenance.muwallad);
  }
  // «فَعَلَ المفتوحَ العين، إن كان أوَّله همزة أو واوًا، فالغالب أنه من باب ضرب»
  if (isHamza(f) || f == waw) {
    return (bab: babDarb, provenance: Provenance.muwallad);
  }
  // المضاعف: متعدٍّ ← نصر، لازم ← ضرب. Transitivity is itself سماعي, so the
  // commoner of the two is taken.
  if (type == SahihMutal.mudaaf) {
    return (bab: babNasr, provenance: Provenance.muwallad);
  }
  // «الأبواب الثلاثة الأولى تسمى دعائم الأبواب، وهى فى الكثرة على ذلك الترتيب»
  return (bab: babDarb, provenance: Provenance.muwallad);
}

/// The قياسي maṣdar of a ثلاثي, used when the lexicon has no entry.
/// شذا العرف page1_0057 — and note that a great many are شاذّ, so this is
/// only ever a fallback.
String qiyasiMasdar(List<String> r, Bab bab) {
  final f = r[0], a = r.length > 1 ? r[1] : r[0], l = r.length > 2 ? r[2] : r[0];
  return switch (bab.id) {
    // فَعُلَ ← فُعُولَةٌ
    'karam' => '$f${damma}$a${damma}${waw}$l${fatha}${taMarbuta}',
    // فَعِلَ اللازم ← فَعَلٌ
    'sami' || 'hasib' => '$f${fatha}$a${fatha}$l${dammatan}',
    // فَعَلَ اللازم ← فُعُولٌ
    _ => '$f${damma}$a${damma}${waw}$l${dammatan}',
  };
}
