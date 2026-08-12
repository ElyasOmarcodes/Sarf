/// الصرف الصغير and الصرف الكبير — the two tables the app exists to show.
///
/// The section list and its ṣīgha counts come straight from the Persian
/// original of إرشاد الصرف, مخ ۵–۲۳: 6 cells for a ḥāḍir amr, 8 for a ghāʾib
/// one, and 3 / 5 once the light nūn is attached, because that nūn cannot
/// follow an alif. docs/sarf/07-tasrif-kabir.md § ۷.۲–۷.۳
library;

import 'arabic.dart';
import 'awzan.dart';
import 'conjugator.dart';
import 'lang.dart';
import 'models.dart';

/// Which family of the التصريف الكبير a section belongs to — used only to
/// group the list in the UI.
enum SectionGroup { madi, mudari, amr, nahy, mushtaqqat }

class SarfSection {
  const SarfSection({
    required this.id,
    required this.group,
    required this.arabicTitle,
    required this.title,
    required this.build,
    required this.sighas,
  });

  final String id;
  final SectionGroup group;

  /// The heading as إرشاد الصرف writes it.
  final String arabicTitle;

  /// The same heading for the reader.
  final L4 title;

  final List<SighaForm> Function(VerbSpec) build;

  /// How many cells this section actually has.
  final int sighas;
}

List<SighaForm> _all(VerbSpec s, SighaForm Function(Sigha) f) =>
    Sigha.values.map(f).toList();

List<SighaForm> _over(List<Sigha> set, SighaForm Function(Sigha) f) =>
    set.map(f).toList();

/// The ḥāḍir/ghāʾib cells that survive the light nūn.
List<Sigha> _khafifaOf(List<Sigha> set) =>
    set.where((g) => g.acceptsNunKhafifa).toList();

/// Every section of the التصريف الكبير, in the book's order.
List<SarfSection> sectionsFor(VerbSpec s) {
  final hadirKh = _khafifaOf(hadirSighas);
  final ghaibKh = _khafifaOf(ghaibSighas);

  return [
    SarfSection(
      id: 'madi_maalum',
      group: SectionGroup.madi,
      arabicTitle: 'الْمَاضِي الْمَعْلُومُ',
      title: L4('ماضي معلوم', 'ماضی معلوم', 'الْمَاضِي الْمَعْلُومُ',
          'Past — active'),
      sighas: 14,
      build: (v) => _all(v, (g) => buildMadi(v, g, Voice.maalum)),
    ),
    SarfSection(
      id: 'madi_majhul',
      group: SectionGroup.madi,
      arabicTitle: 'الْمَاضِي الْمَجْهُولُ',
      title: L4('ماضي مجهول', 'ماضی مجهول', 'الْمَاضِي الْمَجْهُولُ',
          'Past — passive'),
      sighas: 14,
      build: (v) => _all(v, (g) => buildMadi(v, g, Voice.majhul)),
    ),
    SarfSection(
      id: 'madi_nafy',
      group: SectionGroup.madi,
      arabicTitle: 'الْمَاضِي الْمَنْفِيُّ بِـ«مَا»',
      title: L4('ماضي منفي په «ما»', 'ماضی منفی به «ما»',
          'الْمَاضِي الْمَنْفِيُّ بِـ«مَا»', 'Past negated with mā'),
      sighas: 14,
      build: (v) => _all(v, (g) => buildMadi(v, g, Voice.maalum, prefix: 'مَا')),
    ),
    SarfSection(
      id: 'mudari_maalum',
      group: SectionGroup.mudari,
      arabicTitle: 'الْمُضَارِعُ الْمَعْلُومُ',
      title: L4('مضارع معلوم', 'مضارع معلوم', 'الْمُضَارِعُ الْمَعْلُومُ',
          'Present — active'),
      sighas: 14,
      build: (v) => _all(v, (g) => buildMudari(v, g, Voice.maalum)),
    ),
    SarfSection(
      id: 'mudari_majhul',
      group: SectionGroup.mudari,
      arabicTitle: 'الْمُضَارِعُ الْمَجْهُولُ',
      title: L4('مضارع مجهول', 'مضارع مجهول', 'الْمُضَارِعُ الْمَجْهُولُ',
          'Present — passive'),
      sighas: 14,
      build: (v) => _all(v, (g) => buildMudari(v, g, Voice.majhul)),
    ),
    SarfSection(
      id: 'nafy_la',
      group: SectionGroup.mudari,
      arabicTitle: 'النَّفْيُ بِـ«لَا»',
      title: L4('نفي په «لا»', 'نفی به «لا»', 'النَّفْيُ بِـ«لَا»',
          'Negated with lā'),
      sighas: 14,
      build: (v) =>
          _all(v, (g) => buildMudari(v, g, Voice.maalum, prefix: 'لَا')),
    ),
    SarfSection(
      id: 'nafy_lan',
      group: SectionGroup.mudari,
      arabicTitle: 'النَّفْيُ الْمُؤَكَّدُ بِـ«لَنْ»',
      title: L4('نفي مؤکد په «لن»', 'نفی مؤکد به «لن»',
          'النَّفْيُ الْمُؤَكَّدُ بِـ«لَنْ»', 'Emphatic negation with lan'),
      sighas: 14,
      build: (v) => _all(
          v,
          (g) => buildMudari(v, g, Voice.maalum,
              mood: Mood.mansub, prefix: 'لَنْ')),
    ),
    SarfSection(
      id: 'juhd_maalum',
      group: SectionGroup.mudari,
      arabicTitle: 'الْجَحْدُ الْمَعْلُومُ بِـ«لَمْ»',
      title: L4('جحد معلوم په «لم»', 'جحد معلوم به «لم»',
          'الْجَحْدُ الْمَعْلُومُ بِـ«لَمْ»', 'Past denial with lam'),
      sighas: 14,
      build: (v) => _all(
          v,
          (g) => buildMudari(v, g, Voice.maalum,
              mood: Mood.majzum, prefix: 'لَمْ')),
    ),
    SarfSection(
      id: 'juhd_majhul',
      group: SectionGroup.mudari,
      arabicTitle: 'الْجَحْدُ الْمَجْهُولُ بِـ«لَمْ»',
      title: L4('جحد مجهول په «لم»', 'جحد مجهول به «لم»',
          'الْجَحْدُ الْمَجْهُولُ بِـ«لَمْ»', 'Past denial, passive'),
      sighas: 14,
      build: (v) => _all(
          v,
          (g) => buildMudari(v, g, Voice.majhul,
              mood: Mood.majzum, prefix: 'لَمْ')),
    ),
    SarfSection(
      id: 'mustaqbal_thaqila',
      group: SectionGroup.mudari,
      arabicTitle: 'الْمُسْتَقْبَلُ الْمُؤَكَّدُ بِالنُّونِ الثَّقِيلَةِ',
      title: L4('مستقبل مؤکد په ثقیله نون', 'مستقبل مؤکد به نون ثقیله',
          'الْمُسْتَقْبَلُ الْمُؤَكَّدُ بِالنُّونِ الثَّقِيلَةِ',
          'Future, emphatic — heavy nūn'),
      sighas: 14,
      build: (v) => _all(
          v,
          (g) => buildMudari(v, g, Voice.maalum,
              tawkid: Tawkid.thaqila, prefix: 'لَـ')),
    ),
    SarfSection(
      id: 'mustaqbal_khafifa',
      group: SectionGroup.mudari,
      arabicTitle: 'الْمُسْتَقْبَلُ الْمُؤَكَّدُ بِالنُّونِ الْخَفِيفَةِ',
      title: L4('مستقبل مؤکد په خفیفه نون', 'مستقبل مؤکد به نون خفیفه',
          'الْمُسْتَقْبَلُ الْمُؤَكَّدُ بِالنُّونِ الْخَفِيفَةِ',
          'Future, emphatic — light nūn'),
      // Only the cells with no alif and no nūn al-niswa survive.
      sighas: _khafifaOf(Sigha.values.toList()).length,
      build: (v) => _over(
          _khafifaOf(Sigha.values.toList()),
          (g) => buildMudari(v, g, Voice.maalum,
              tawkid: Tawkid.khafifa, prefix: 'لَـ')),
    ),
    SarfSection(
      id: 'amr_hadir',
      group: SectionGroup.amr,
      arabicTitle: 'الْأَمْرُ الْحَاضِرُ الْمَعْلُومُ',
      title: L4('امر حاضر معلوم', 'امر حاضر معلوم',
          'الْأَمْرُ الْحَاضِرُ الْمَعْلُومُ', 'Imperative — 2nd person'),
      sighas: 6,
      build: (v) => _over(hadirSighas, (g) => buildAmr(v, g)),
    ),
    SarfSection(
      id: 'amr_hadir_thaqila',
      group: SectionGroup.amr,
      arabicTitle: 'الْأَمْرُ الْحَاضِرُ الْمُؤَكَّدُ بِالثَّقِيلَةِ',
      title: L4('امر حاضر مؤکد په ثقیله', 'امر حاضر مؤکد به ثقیله',
          'الْأَمْرُ الْحَاضِرُ الْمُؤَكَّدُ بِالثَّقِيلَةِ',
          'Imperative, emphatic — heavy nūn'),
      sighas: 6,
      build: (v) => _over(hadirSighas, (g) => buildAmr(v, g, tawkid: Tawkid.thaqila)),
    ),
    SarfSection(
      id: 'amr_hadir_khafifa',
      group: SectionGroup.amr,
      arabicTitle: 'الْأَمْرُ الْحَاضِرُ الْمُؤَكَّدُ بِالْخَفِيفَةِ',
      title: L4('امر حاضر مؤکد په خفیفه', 'امر حاضر مؤکد به خفیفه',
          'الْأَمْرُ الْحَاضِرُ الْمُؤَكَّدُ بِالْخَفِيفَةِ',
          'Imperative, emphatic — light nūn'),
      sighas: 3,
      build: (v) => _over(hadirKh, (g) => buildAmr(v, g, tawkid: Tawkid.khafifa)),
    ),
    SarfSection(
      id: 'amr_ghaib',
      group: SectionGroup.amr,
      arabicTitle: 'الْأَمْرُ الْغَائِبُ بِاللَّامِ',
      title: L4('امر غائب په لام', 'امر غائب به لام',
          'الْأَمْرُ الْغَائِبُ بِاللَّامِ', 'Jussive with lām'),
      sighas: 8,
      build: (v) => _over(
          ghaibSighas,
          (g) => buildMudari(v, g, Voice.maalum,
              mood: Mood.majzum, lamAmr: true)),
    ),
    SarfSection(
      id: 'amr_hadir_majhul',
      group: SectionGroup.amr,
      arabicTitle: 'الْأَمْرُ الْحَاضِرُ الْمَجْهُولُ',
      title: L4('امر حاضر مجهول', 'امر حاضر مجهول',
          'الْأَمْرُ الْحَاضِرُ الْمَجْهُولُ', 'Imperative — passive'),
      sighas: 6,
      build: (v) => _over(
          hadirSighas,
          (g) => buildMudari(v, g, Voice.majhul,
              mood: Mood.majzum, lamAmr: true)),
    ),
    SarfSection(
      id: 'nahy_hadir',
      group: SectionGroup.nahy,
      arabicTitle: 'النَّهْيُ الْحَاضِرُ الْمَعْلُومُ',
      title: L4('نهي حاضر معلوم', 'نهی حاضر معلوم',
          'النَّهْيُ الْحَاضِرُ الْمَعْلُومُ', 'Prohibition — 2nd person'),
      sighas: 6,
      build: (v) => _over(
          hadirSighas,
          (g) => buildMudari(v, g, Voice.maalum,
              mood: Mood.majzum, prefix: 'لَا')),
    ),
    SarfSection(
      id: 'nahy_hadir_thaqila',
      group: SectionGroup.nahy,
      arabicTitle: 'النَّهْيُ الْمُؤَكَّدُ بِالثَّقِيلَةِ',
      title: L4('نهي مؤکد په ثقیله', 'نهی مؤکد به ثقیله',
          'النَّهْيُ الْمُؤَكَّدُ بِالثَّقِيلَةِ',
          'Prohibition, emphatic — heavy nūn'),
      sighas: 6,
      build: (v) => _over(
          hadirSighas,
          (g) => buildMudari(v, g, Voice.maalum,
              tawkid: Tawkid.thaqila, prefix: 'لَا')),
    ),
    SarfSection(
      id: 'nahy_hadir_khafifa',
      group: SectionGroup.nahy,
      arabicTitle: 'النَّهْيُ الْمُؤَكَّدُ بِالْخَفِيفَةِ',
      title: L4('نهي مؤکد په خفیفه', 'نهی مؤکد به خفیفه',
          'النَّهْيُ الْمُؤَكَّدُ بِالْخَفِيفَةِ',
          'Prohibition, emphatic — light nūn'),
      sighas: 3,
      build: (v) => _over(
          hadirKh,
          (g) => buildMudari(v, g, Voice.maalum,
              tawkid: Tawkid.khafifa, prefix: 'لَا')),
    ),
    SarfSection(
      id: 'nahy_ghaib',
      group: SectionGroup.nahy,
      arabicTitle: 'النَّهْيُ الْغَائِبُ',
      title: L4('نهي غائب', 'نهی غائب', 'النَّهْيُ الْغَائِبُ',
          'Prohibition — 3rd person'),
      sighas: 8,
      build: (v) => _over(
          ghaibSighas,
          (g) => buildMudari(v, g, Voice.maalum,
              mood: Mood.majzum, prefix: 'لَا')),
    ),
    SarfSection(
      id: 'nahy_ghaib_khafifa',
      group: SectionGroup.nahy,
      arabicTitle: 'النَّهْيُ الْغَائِبُ بِالْخَفِيفَةِ',
      title: L4('نهي غائب په خفیفه', 'نهی غائب به خفیفه',
          'النَّهْيُ الْغَائِبُ بِالْخَفِيفَةِ',
          'Prohibition, 3rd person — light nūn'),
      sighas: 5,
      build: (v) => _over(
          ghaibKh,
          (g) => buildMudari(v, g, Voice.maalum,
              tawkid: Tawkid.khafifa, prefix: 'لَا')),
    ),
  ];
}

// ═══════════════════════════════════════════════════════════════════════════
// المشتقات — the derived nouns
// ═══════════════════════════════════════════════════════════════════════════

class Mushtaqq {
  const Mushtaqq({
    required this.kind,
    required this.arabicName,
    required this.text,
    required this.pattern,
    this.provenance = Provenance.qiyasi,
  });

  final DerivedKind kind;
  final String arabicName;
  final String text;
  final String pattern;
  final Provenance provenance;
}

/// اسم الفاعل واسم المفعول والظرف والآلة والتفضيل، من الثلاثي وغيره.
/// شذا العرف page1_0062–0065 · إرشاد الصرف (فارسي) مخ ۲۳
List<Mushtaqq> mushtaqqatFor(VerbSpec s) {
  final f = s.f, a = s.a, l = s.l;
  final out = <Mushtaqq>[];

  if (s.isMujarrad3) {
    // فَاعِلٌ — with قلب العين همزةً when the verb itself was أجوف معلّ.
    // Built as letters, not text, so the renderer seats the hamza properly:
    // after a long alif a *kasra*-bearing hamza takes a yāʾ chair — قَائِلٌ.
    final fail = s.type == SahihMutal.ajwaf
        ? '${renderLetters([
            Ltr(f, Hrk.fatha),
            const Ltr(alif),
            const Ltr(hamza, Hrk.kasra),
            Ltr(l),
          ])}$dammatan'
        : '$f${fatha}${alif}$a${kasra}$l${dammatan}';
    out.add(Mushtaqq(
      kind: DerivedKind.ismFail,
      arabicName: 'اسْمُ الْفَاعِلِ',
      pattern: 'فَاعِلٌ',
      text: fail,
    ));

    // مَفْعُولٌ — the أجوف and ناقص both shorten it. شذا العرف page1_0151
    final String maful;
    if (s.type == SahihMutal.ajwaf) {
      maful = a == waw
          ? 'مَ$f${damma}${waw}$l${dammatan}'
          : 'مَ$f${kasra}${ya}$l${dammatan}';
    } else if (s.type == SahihMutal.naqis) {
      maful = 'مَ$f${sukun}$a${kasra}${ya}${shadda}${dammatan}';
    } else {
      maful = 'مَ$f${sukun}$a${damma}${waw}$l${dammatan}';
    }
    out.add(Mushtaqq(
      kind: DerivedKind.ismMaful,
      arabicName: 'اسْمُ الْمَفْعُولِ',
      pattern: 'مَفْعُولٌ',
      text: maful,
    ));

    // ظرف الزمان والمكان — مَفْعَلٌ, or مَفْعِلٌ when the muḍāriʿ is yafʿilu.
    //
    // مَفْعَل is «الاسم المشبه للفعل المضارع وزنًا» and so takes الإعلال
    // بالنقل just as the verb does: مَقْوَل ← مَقَام‑style, giving مَقَالٌ.
    // (مِفْعَل and مِفْعَال do *not* — their kasra stops them resembling the
    // muḍāriʿ, «ووجَبَ التصحيح» — which is why مِقْوَلٌ below stays sound.)
    // شذا العرف page1_0151
    final zarfKasra = s.mudariAynVowel == Hrk.kasra;
    final String zarf;
    if (s.type == SahihMutal.ajwaf) {
      zarf = 'مَ$f${fatha}${alif}$l${dammatan}';
    } else if (s.type == SahihMutal.naqis) {
      zarf = 'مَ$f${sukun}$a${fatha}$alifMaqsura';
    } else {
      zarf = 'مَ$f${sukun}$a${zarfKasra ? kasra : fatha}$l${dammatan}';
    }
    out.add(Mushtaqq(
      kind: DerivedKind.ismZarf,
      arabicName: 'ظَرْفُ الزَّمَانِ وَالْمَكَانِ',
      pattern: s.type == SahihMutal.ajwaf
          ? 'مَفَالٌ'
          : (zarfKasra ? 'مَفْعِلٌ' : 'مَفْعَلٌ'),
      text: zarf,
    ));

    // The three sizes of اسم الآلة — a refinement the Persian original keeps
    // and the Arabic abridgement drops. docs/sarf/07-tasrif-kabir.md § ۷.۴
    out.add(Mushtaqq(
      kind: DerivedKind.ismAala,
      arabicName: 'اسْمُ الْآلَةِ (الصُّغْرَى)',
      pattern: 'مِفْعَلٌ',
      text: 'مِ$f${sukun}$a${fatha}$l${dammatan}',
    ));
    out.add(Mushtaqq(
      kind: DerivedKind.ismAala,
      arabicName: 'اسْمُ الْآلَةِ (الْوُسْطَى)',
      pattern: 'مِفْعَلَةٌ',
      text: 'مِ$f${sukun}$a${fatha}$l${fatha}${taMarbuta}${dammatan}',
    ));
    out.add(Mushtaqq(
      kind: DerivedKind.ismAala,
      arabicName: 'اسْمُ الْآلَةِ (الْكُبْرَى)',
      pattern: 'مِفْعَالٌ',
      text: 'مِ$f${sukun}$a${fatha}${alif}$l${dammatan}',
    ));

    out.add(Mushtaqq(
      kind: DerivedKind.ismTafdil,
      arabicName: 'اسْمُ التَّفْضِيلِ (الْمُذَكَّرُ)',
      pattern: 'أَفْعَلُ',
      text: 'أَ$f${sukun}$a${fatha}$l${damma}',
    ));
    out.add(Mushtaqq(
      kind: DerivedKind.ismTafdil,
      arabicName: 'اسْمُ التَّفْضِيلِ (الْمُؤَنَّثُ)',
      pattern: 'فُعْلَى',
      text: '$f${damma}$a${sukun}$l${fatha}$alifMaqsura',
    ));
    out.add(Mushtaqq(
      kind: DerivedKind.ismMubalagha,
      arabicName: 'اسْمُ الْمُبَالَغَةِ',
      pattern: 'فَعَّالٌ',
      text: '$f${fatha}$a${shadda}${fatha}$l${dammatan}',
      provenance: Provenance.samai,
    ));
    return out;
  }

  // ── غير الثلاثي: اسم الفاعل on the muḍāriʿ's own shape, with the ḥarf
  //    al-muḍāraʿa replaced by a ḍamma-bearing mīm. شذا العرف page1_0063 ──
  final mud = buildMudari(s, Sigha.wahidMudhakkarGhaib, Voice.maalum).text;
  final mudMaf = buildMudari(s, Sigha.wahidMudhakkarGhaib, Voice.majhul).text;
  String swapPrefix(String w) {
    // Drop the ḥarf al-muḍāraʿa together with its vowel and put مُ there
    // instead — «بإبدال حرف المضارعة ميمًا مضمومة». شذا العرف page1_0063
    final chars = w.split('');
    var i = 1;
    while (i < chars.length && tashkeel.contains(chars[i])) {
      i++;
    }
    return 'مُ${chars.sublist(i).join()}';
  }

  out.add(Mushtaqq(
    kind: DerivedKind.ismFail,
    arabicName: 'اسْمُ الْفَاعِلِ',
    pattern: 'عَلَى زِنَةِ مُضَارِعِهِ',
    text: _trimFinalVowel(swapPrefix(mud)),
  ));
  out.add(Mushtaqq(
    kind: DerivedKind.ismMaful,
    arabicName: 'اسْمُ الْمَفْعُولِ',
    pattern: 'عَلَى زِنَةِ مُضَارِعِهِ الْمَجْهُولِ',
    text: _trimFinalVowel(swapPrefix(mudMaf)),
  ));
  out.add(Mushtaqq(
    kind: DerivedKind.masdar,
    arabicName: 'الْمَصْدَرُ',
    pattern: s.wazn.masdarPattern,
    text: s.resolvedMasdar,
  ));
  return out;
}

/// Replace the iʿrāb ḍamma of a verb with tanwīn, so مُكْرِمُ reads مُكْرِمٌ.
String _trimFinalVowel(String w) {
  if (w.endsWith(damma)) return '${w.substring(0, w.length - 1)}$dammatan';
  if (w.endsWith(fatha)) return '${w.substring(0, w.length - 1)}$fathatan';
  return w;
}

// ═══════════════════════════════════════════════════════════════════════════
// الصرف الصغير
// ═══════════════════════════════════════════════════════════════════════════

/// One clause of the ṣarf ṣaghīr line, so the UI can chip them individually.
class SaghirItem {
  const SaghirItem({
    required this.label,
    required this.text,
    required this.form,
  });

  final L4 label;
  final String text;

  /// The underlying [SighaForm] when this clause is a conjugated cell — that
  /// is what carries the i'lāl chain to show on tap.
  final SighaForm? form;
}

/// «چون الضَّرْبُ: ضَرَبَ يَضْرِبُ ضَرْبًا فَهُوَ ضَارِبٌ وَذَاكَ مَضْرُوبٌ …»
/// إرشاد الصرف (فارسي) مخ ۴ · docs/sarf/07-tasrif-kabir.md § ۷.۵
List<SaghirItem> sarfSaghir(VerbSpec s) {
  const g = Sigha.wahidMudhakkarGhaib;
  final mush = mushtaqqatFor(s);
  String of(DerivedKind k, [int nth = 0]) {
    final hits = mush.where((m) => m.kind == k).toList();
    return nth < hits.length ? hits[nth].text : '';
  }

  final items = <SaghirItem>[
    SaghirItem(
      label: L4('مصدر', 'مصدر', 'الْمَصْدَرُ', 'Verbal noun'),
      text: s.resolvedMasdar,
      form: null,
    ),
    SaghirItem(
      label: L4('ماضي معلوم', 'ماضی معلوم', 'الْمَاضِي', 'Past'),
      text: buildMadi(s, g, Voice.maalum).text,
      form: buildMadi(s, g, Voice.maalum),
    ),
    SaghirItem(
      label: L4('مضارع معلوم', 'مضارع معلوم', 'الْمُضَارِعُ', 'Present'),
      text: buildMudari(s, g, Voice.maalum).text,
      form: buildMudari(s, g, Voice.maalum),
    ),
    SaghirItem(
      label: L4('اسم فاعل', 'اسم فاعل', 'اسْمُ الْفَاعِلِ', 'Active participle'),
      text: of(DerivedKind.ismFail),
      form: null,
    ),
    SaghirItem(
      label:
          L4('اسم مفعول', 'اسم مفعول', 'اسْمُ الْمَفْعُولِ', 'Passive participle'),
      text: of(DerivedKind.ismMaful),
      form: null,
    ),
    SaghirItem(
      label: L4('ماضي مجهول', 'ماضی مجهول', 'الْمَاضِي الْمَجْهُولُ',
          'Past, passive'),
      text: buildMadi(s, g, Voice.majhul).text,
      form: buildMadi(s, g, Voice.majhul),
    ),
    SaghirItem(
      label: L4('مضارع مجهول', 'مضارع مجهول', 'الْمُضَارِعُ الْمَجْهُولُ',
          'Present, passive'),
      text: buildMudari(s, g, Voice.majhul).text,
      form: buildMudari(s, g, Voice.majhul),
    ),
    SaghirItem(
      label: L4('جحد', 'جحد', 'الْجَحْدُ', 'Denial (lam)'),
      text: buildMudari(s, g, Voice.maalum,
              mood: Mood.majzum, prefix: 'لَمْ')
          .text,
      form: buildMudari(s, g, Voice.maalum, mood: Mood.majzum, prefix: 'لَمْ'),
    ),
    SaghirItem(
      label: L4('نفي', 'نفی', 'النَّفْيُ', 'Negation (lā)'),
      text: buildMudari(s, g, Voice.maalum, prefix: 'لَا').text,
      form: buildMudari(s, g, Voice.maalum, prefix: 'لَا'),
    ),
    SaghirItem(
      label: L4('نفي په لن', 'نفی به لن', 'النَّفْيُ بِـ«لَنْ»',
          'Negation (lan)'),
      text: buildMudari(s, g, Voice.maalum,
              mood: Mood.mansub, prefix: 'لَنْ')
          .text,
      form: buildMudari(s, g, Voice.maalum, mood: Mood.mansub, prefix: 'لَنْ'),
    ),
    SaghirItem(
      label: L4('امر حاضر', 'امر حاضر', 'الْأَمْرُ', 'Imperative'),
      text: buildAmr(s, Sigha.wahidMudhakkarMukhatab).text,
      form: buildAmr(s, Sigha.wahidMudhakkarMukhatab),
    ),
    SaghirItem(
      label: L4('امر غائب', 'امر غائب', 'الْأَمْرُ الْغَائِبُ',
          'Jussive'),
      text: buildMudari(s, g, Voice.maalum, mood: Mood.majzum, lamAmr: true)
          .text,
      form: buildMudari(s, g, Voice.maalum, mood: Mood.majzum, lamAmr: true),
    ),
    SaghirItem(
      label: L4('نهي', 'نهی', 'النَّهْيُ', 'Prohibition'),
      text: buildMudari(s, Sigha.wahidMudhakkarMukhatab, Voice.maalum,
              mood: Mood.majzum, prefix: 'لَا')
          .text,
      form: buildMudari(s, Sigha.wahidMudhakkarMukhatab, Voice.maalum,
          mood: Mood.majzum, prefix: 'لَا'),
    ),
  ];

  if (s.isMujarrad3) {
    items.addAll([
      SaghirItem(
        label: L4('ظرف', 'ظرف', 'الظَّرْفُ', 'Time/place noun'),
        text: of(DerivedKind.ismZarf),
        form: null,
      ),
      SaghirItem(
        label: L4('اسم آله', 'اسم آله', 'اسْمُ الْآلَةِ', 'Instrument noun'),
        text: of(DerivedKind.ismAala),
        form: null,
      ),
      SaghirItem(
        label: L4('اسم تفضیل', 'اسم تفضیل', 'اسْمُ التَّفْضِيلِ',
            'Comparative'),
        text: of(DerivedKind.ismTafdil),
        form: null,
      ),
    ]);
  }
  return items.where((i) => i.text.isNotEmpty).toList();
}

/// The ṣarf ṣaghīr as the one running line a student recites.
String sarfSaghirLine(VerbSpec s) =>
    sarfSaghir(s).map((i) => i.text).join(' · ');
