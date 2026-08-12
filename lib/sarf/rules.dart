/// The named rules of الإعلال والإبدال, each with its book reference.
///
/// إرشاد الصرف gives its rules proper names — قاعدة عِدَة, قاعدة قال وباع,
/// قاعدة قُلْنَ طُلْنَ — and that is what makes the app able to answer *why*
/// rather than only *what* (CLAUDE.md § ۲). Every transformation the engine
/// performs cites one of these.
library;

import 'lang.dart';

enum RuleId {
  /// قلب الواو والياء ألفًا — «قاعدة قال وباع»
  qalbWawYaAlifan,

  /// الإعلال بالنقل — يَقُولُ، يَبِيعُ، يَخَافُ
  ilalBinNaql,

  /// حذف حرف العلة لالتقاء الساكنين — قُلْ، بِعْ، خَفْ
  hadhfLiltiqaSakinayn,

  /// قاعدة قُلْنَ طُلْنَ — ḍamm of the fāʾ after the ʿayn drops
  qaidaQulnaTulna,

  /// قاعدة خِفْنَ بِعْنَ — kasr of the fāʾ after the ʿayn drops
  qaidaKhifnaBina,

  /// قاعدة عِدَة — the wāw of a mithāl drops
  qaidaIda,

  /// حذف فاء المثال من المضارع — وَعَدَ ← يَعِدُ
  hadhfFaAlMithal,

  /// قاعدة لم يَدْعُ — the final ḥarf ʿilla drops at jazm and in the amr
  qaidaLamYadu,

  /// حذف لام الناقص عند واو الجماعة — سَعَوْا، رَضُوا
  hadhfLamNaqisWawJamaa,

  /// قلب لام الناقص — غَزَا ← غَزَوْتُ
  raddLamNaqisIlaAslih,

  /// فاء الافتعال — اتَّعَدَ، اصْطَبَرَ، اضْطَرَبَ، ازْدَجَرَ، ادَّكَرَ
  faAlIftial,

  /// حذف همزة أفْعَلَ من المضارع والوصفين
  hadhfHamzatAfal,

  /// قلب الواو والياء همزةً في اسم الفاعل — قَائِلٌ، بَائِعٌ
  qalbWawYaHamzatan,

  /// إعلال اسم المفعول — مَقُولٌ، مَبِيعٌ
  ilalIsmMaful,

  /// الإدغام في المضاعف
  idghamMudaaf,

  /// فك الإدغام عند ضمير الرفع المتحرك — مَدَدْتُ
  fakkIdgham,

  /// اجتماع الهمزتين — أَأْمَنَ ← آمَنَ
  ijtimaHamzatayn,

  /// حذف همزة أخذ وأكل في الأمر — خُذْ، كُلْ
  hadhfHamzatAmr,

  /// إعلال مصدر الإفعال والاستفعال — إقْوَام ← إقَامَة
  ilalMasdarIfal,

  /// قلب الألف ياءً أو واوًا حسب ما قبلها
  qalbAlifLilharaka,

  /// التقاء الساكنين — تحريك أو حذف
  iltiqaSakinayn,
}

/// A rule's identity: its Arabic name, the reason it fires, and where it is
/// written down.
class RuleInfo {
  const RuleInfo({
    required this.id,
    required this.arabicName,
    required this.taleel,
    required this.source,
  });

  final RuleId id;

  /// The name the book gives it — never translated.
  final String arabicName;

  /// Why the change happens, in the reader's language.
  final L4 taleel;

  /// Book + locator, e.g. 'شذا العرف · page1_0145'.
  final String source;
}

const Map<RuleId, RuleInfo> ruleTable = {
  RuleId.qalbWawYaAlifan: RuleInfo(
    id: RuleId.qalbWawYaAlifan,
    arabicName: 'قَاعِدَةُ قَالَ وَبَاعَ',
    taleel: L4(
      'واو یا یاء الف ته واوښتله، ځکه چې متحرکه وه او مخکې یې فتحه وه.',
      'واو یا یاء به الف بدل شد، زیرا متحرک بود و ما قبلش مفتوح.',
      'قُلِبَتِ الْوَاوُ أَوِ الْيَاءُ أَلِفًا لِتَحَرُّكِهَا وَانْفِتَاحِ مَا قَبْلَهَا.',
      'The wāw or yāʾ became an alif: it was vowelled and the letter before it '
          'carried fatḥa.',
    ),
    source: 'شذا العرف · page1_0145 · إرشاد الصرف مخ ۱۱۲',
  ),
  RuleId.ilalBinNaql: RuleInfo(
    id: RuleId.ilalBinNaql,
    arabicName: 'الْإِعْلَالُ بِالنَّقْلِ',
    taleel: L4(
      'د معتل حرکت مخکینې ساکن صحیح حرف ته ونقل شو؛ که معتل له حرکت سره مجانس '
          'نه و، هغه حرف ته واوښت چې ورسره مجانس دی.',
      'حرکت حرف معتل به ساکن صحیح ما قبل نقل شد؛ اگر معتل با آن حرکت مجانس '
          'نبود، به حرفِ مجانس بدل شد.',
      'نُقِلَتْ حَرَكَةُ الْمُعْتَلِّ إِلَى السَّاكِنِ الصَّحِيحِ قَبْلَهُ، '
          'فَإِنْ لَمْ يُجَانِسْهَا قُلِبَ حَرْفًا يُجَانِسُهَا.',
      'The weak letter’s vowel moved onto the sound consonant before it; if the '
          'weak letter did not match that vowel it changed to the one that does.',
    ),
    source: 'شذا العرف · page1_0150',
  ),
  RuleId.hadhfLiltiqaSakinayn: RuleInfo(
    id: RuleId.hadhfLiltiqaSakinayn,
    arabicName: 'الْحَذْفُ لِالْتِقَاءِ السَّاكِنَيْنِ',
    taleel: L4(
      'دوه ساکنه سره ولګېدل، نو لومړی — چې مدّه وه — حذف شو.',
      'دو ساکن با هم برخوردند، پس اوّلی که مدّه بود حذف شد.',
      'الْتَقَى سَاكِنَانِ فَحُذِفَ الْأَوَّلُ لِكَوْنِهِ مَدَّةً.',
      'Two sukūns met, so the first — being a lengthening letter — was dropped.',
    ),
    source: 'شذا العرف · page1_0164',
  ),
  RuleId.qaidaQulnaTulna: RuleInfo(
    id: RuleId.qaidaQulnaTulna,
    arabicName: 'قَاعِدَةُ قُلْنَ طُلْنَ',
    taleel: L4(
      'د واو (غیر مکسورې) له حذفه وروسته فاء واجباً ضمه مومي، ترڅو پر '
          'حذف‌شوي واو دلالت وکړي.',
      'پس از حذف واوِ غیر مکسور، فاء واجباً مضموم می‌شود تا بر واوِ محذوف '
          'دلالت کند.',
      'كُلُّ وَاوٍ غَيْرِ مَكْسُورَةٍ إِذَا حُذِفَتْ بَعْدَ قَلْبِهَا أَلِفًا '
          'ضُمَّتِ الْفَاءُ وُجُوبًا.',
      'When a non-kasra wāw drops after turning into an alif, the fāʾ must take '
          'ḍamma — the vowel is what still points to the wāw.',
    ),
    source: 'إرشاد الصرف مخ ۱۱۴',
  ),
  RuleId.qaidaKhifnaBina: RuleInfo(
    id: RuleId.qaidaKhifnaBina,
    arabicName: 'قَاعِدَةُ خِفْنَ بِعْنَ',
    taleel: L4(
      'د مکسورې واو یا د یاء له حذفه وروسته فاء واجباً کسره مومي.',
      'پس از حذف واو مکسور یا یاء، فاء واجباً مکسور می‌شود.',
      'كُلُّ وَاوٍ مَكْسُورَةٍ أَوْ يَاءٍ مُطْلَقَةٍ إِذَا حُذِفَتْ بَعْدَ '
          'قَلْبِهَا أَلِفًا كُسِرَتِ الْفَاءُ وُجُوبًا.',
      'When a kasra-bearing wāw, or any yāʾ, drops after turning into an alif, '
          'the fāʾ must take kasra.',
    ),
    source: 'إرشاد الصرف مخ ۱۱۴',
  ),
  RuleId.qaidaIda: RuleInfo(
    id: RuleId.qaidaIda,
    arabicName: 'قَاعِدَةُ عِدَةٍ',
    taleel: L4(
      'د مصدر په فاء کې واو غورځي، کسره یې راتلونکي حرف ته نقلیږي، او په '
          'آخر کې د عوض تاء زیاتیږي.',
      'واوِ واقع در فاءِ مصدر می‌افتد، کسره‌اش به ما بعد نقل می‌شود، و در آخر '
          'تاء عوض افزوده می‌شود.',
      'تَسْقُطُ الْوَاوُ الْوَاقِعَةُ فِي فَاءِ مَصْدَرٍ وَزْنُهُ فِعْلٌ، '
          'وَتُنْقَلُ كَسْرَتُهَا إِلَى مَا بَعْدَهَا، وَتُزَادُ التَّاءُ '
          'عِوَضًا عَنْهَا.',
      'The wāw at the head of the maṣdar drops, its kasra moves to the next '
          'letter, and a tāʾ is added at the end to stand in for it.',
    ),
    source: 'إرشاد الصرف مخ ۱۰۶',
  ),
  RuleId.hadhfFaAlMithal: RuleInfo(
    id: RuleId.hadhfFaAlMithal,
    arabicName: 'حَذْفُ فَاءِ الْمِثَالِ',
    taleel: L4(
      'د واوي مثال فاء له مضارع څخه غورځي کله چې مضارع یې پر «يَفْعِلُ» وي؛ '
          'امر هم د هغې فرع دی نو هلته هم غورځي.',
      'فاءِ مثالِ واوی از مضارع می‌افتد هرگاه مضارع بر «يَفْعِلُ» باشد؛ امر '
          'نیز فرع اوست پس در آن هم می‌افتد.',
      'تُحْذَفُ فَاءُ الْمِثَالِ الْوَاوِيِّ مِنَ الْمُضَارِعِ إِذَا كَانَ '
          'عَلَى وَزْنِ يَفْعِلُ، وَمِنَ الْأَمْرِ لِأَنَّهُ فَرْعُهُ.',
      'The wāw that opens a mithāl drops from the muḍāriʿ when that muḍāriʿ is '
          'yafʿilu — and from the imperative, which is derived from it.',
    ),
    source: 'شذا العرف · page1_0050',
  ),
  RuleId.qaidaLamYadu: RuleInfo(
    id: RuleId.qaidaLamYadu,
    arabicName: 'قَاعِدَةُ لَمْ يَدْعُ',
    taleel: L4(
      'د مضارع له آخره حرف علت واجباً حذفیږي کله چې جازم پرې راشي یا امر '
          'ترې جوړ شي.',
      'حرف علت از آخر مضارع واجباً حذف می‌شود هنگام دخول جازم و هنگام بناءِ امر.',
      'يَجِبُ حَذْفُ حَرْفِ الْعِلَّةِ مِنْ آخِرِ الْفِعْلِ الْمُضَارِعِ عِنْدَ '
          'دُخُولِ الْجَوَازِمِ وَعِنْدَ بِنَاءِ الْأَمْرِ.',
      'The final weak letter must drop when a jāzim enters the muḍāriʿ, and in '
          'the imperative built from it.',
    ),
    source: 'إرشاد الصرف مخ ۱۲۳',
  ),
  RuleId.hadhfLamNaqisWawJamaa: RuleInfo(
    id: RuleId.hadhfLamNaqisWawJamaa,
    arabicName: 'حَذْفُ لَامِ النَّاقِصِ عِنْدَ وَاوِ الْجَمَاعَةِ',
    taleel: L4(
      'د واو الجماعة په وخت کې د ناقص لام غورځي؛ که محذوف الف وه مخکې یې '
          'فتحه پاتې کیږي، که واو یا یاء وه نو ضمه.',
      'هنگام واو جماعت لامِ ناقص می‌افتد؛ اگر محذوف الف بود ما قبل مفتوح '
          'می‌ماند، و اگر واو یا یاء بود مضموم می‌شود.',
      'يُحْذَفُ حَرْفُ الْعِلَّةِ عِنْدَ إِسْنَادِهِ لِوَاوِ الْجَمَاعَةِ، '
          'وَيَبْقَى فَتْحُ مَا قَبْلَهُ إِنْ كَانَ الْمَحْذُوفُ أَلِفًا، '
          'وَيُضَمُّ إِنْ كَانَ وَاوًا أَوْ يَاءً.',
      'Before wāw al-jamāʿa the final weak letter drops: a dropped alif leaves '
          'fatḥa behind, a dropped wāw or yāʾ leaves ḍamma.',
    ),
    source: 'شذا العرف · page1_0051',
  ),
  RuleId.raddLamNaqisIlaAslih: RuleInfo(
    id: RuleId.raddLamNaqisIlaAslih,
    arabicName: 'رَدُّ لَامِ النَّاقِصِ إِلَى أَصْلِهَا',
    taleel: L4(
      'کله چې ناقص فعل بارز ضمیر ته اسناد شي، الف بېرته خپل اصل (واو یا یاء) '
          'ته ورګرځي.',
      'هنگام اسناد فعل ناقص به ضمیر بارز، الف به اصل خود (واو یا یاء) '
          'باز می‌گردد.',
      'تُقْلَبُ الْأَلِفُ وَاوًا أَوْ يَاءً تَبَعًا لِأَصْلِهَا عِنْدَ '
          'إِسْنَادِ النَّاقِصِ إِلَى الضَّمَائِرِ الْبَارِزَةِ.',
      'When a nāqiṣ verb takes an overt pronoun the alif returns to whichever '
          'letter it came from — wāw or yāʾ.',
    ),
    source: 'شذا العرف · page1_0051',
  ),
  RuleId.faAlIftial: RuleInfo(
    id: RuleId.faAlIftial,
    arabicName: 'فَاءُ الِافْتِعَالِ وَتَاؤُهُ',
    taleel: L4(
      'د افتعال د فاء له مخې د باب تاء بدلیږي: واو/یاء → تاء (ادغام)؛ '
          'حروف اطباق → طاء؛ د/ذ/ز → دال.',
      'تاءِ افتعال به حسب فاء تغییر می‌کند: واو/یاء → تاء (با ادغام)؛ حروف '
          'اطباق → طاء؛ د/ذ/ز → دال.',
      'تَتَغَيَّرُ تَاءُ الِافْتِعَالِ بِحَسَبِ فَائِهِ: الْوَاوُ وَالْيَاءُ '
          'تُبْدَلَانِ تَاءً وَتُدْغَمَانِ، وَأَحْرُفُ الْإِطْبَاقِ تُبْدَلُ '
          'التَّاءُ مَعَهَا طَاءً، وَالدَّالُ وَالذَّالُ وَالزَّايُ دَالًا.',
      'The tāʾ of iftaʿala reshapes itself to the root’s first letter: wāw/yāʾ '
          'assimilate into it, the emphatic letters turn it into ṭāʾ, and '
          'd/dh/z turn it into dāl.',
    ),
    source: 'شذا العرف · page1_0147',
  ),
  RuleId.hadhfHamzatAfal: RuleInfo(
    id: RuleId.hadhfHamzatAfal,
    arabicName: 'حَذْفُ هَمْزَةِ أَفْعَلَ',
    taleel: L4(
      'د أفْعَلَ همزه له مضارع او دواړو وصفونو حذفیږي، ځکه چې د متکلم په '
          'صیغه کې دوه همزې سره یوځای کیږي، او نور یې پرې حمل شول.',
      'همزهٔ أفْعَلَ از مضارع و هر دو وصف حذف می‌شود، زیرا در صیغهٔ متکلم دو '
          'همزه جمع می‌شود، و بقیه بر آن حمل شدند.',
      'تُحْذَفُ هَمْزَةُ أَفْعَلَ مِنَ الْمُضَارِعِ وَوَصْفَيْهِ كَرَاهَةَ '
          'اجْتِمَاعِ الْهَمْزَتَيْنِ فِي الْمَبْدُوءِ بِهَمْزَةِ '
          'الْمُتَكَلِّمِ، وَحُمِلَ غَيْرُهُ عَلَيْهِ.',
      'The hamza of afʿala drops from the muḍāriʿ and both participles: it '
          'would collide with the speaker’s own hamza in ʾuʾakrimu, and the '
          'rest of the paradigm followed suit.',
    ),
    source: 'شذا العرف · page1_0153',
  ),
  RuleId.qalbWawYaHamzatan: RuleInfo(
    id: RuleId.qalbWawYaHamzatan,
    arabicName: 'قَلْبُ الْوَاوِ وَالْيَاءِ هَمْزَةً',
    taleel: L4(
      'د اسم فاعل عین همزې ته اوړي، ځکه چې په فعل کې یې اعلال شوی و.',
      'عینِ اسم فاعل به همزه بدل می‌شود، زیرا در فعل معلّ شده بود.',
      'تُقْلَبُ الْوَاوُ وَالْيَاءُ هَمْزَةً إِذَا وَقَعَتَا عَيْنًا لِاسْمِ '
          'فَاعِلِ فِعْلٍ أُعِلَّتَا فِيهِ.',
      'The middle wāw/yāʾ of an active participle becomes hamza when the verb '
          'it comes from had that letter altered.',
    ),
    source: 'شذا العرف · page1_0133',
  ),
  RuleId.ilalIsmMaful: RuleInfo(
    id: RuleId.ilalIsmMaful,
    arabicName: 'إِعْلَالُ صِيغَةِ مَفْعُولٍ',
    taleel: L4(
      'یو مدّ حذف شو؛ په یائي کې ضمه کسرې ته واوښته، هسې نه چې یاء واو شي '
          'او واوي له یائي سره ګډ شي.',
      'یک مدّ حذف شد؛ در یائی ضمه به کسره بدل شد تا یاء واو نشود و واوی با '
          'یائی مشتبه نگردد.',
      'حُذِفَ أَحَدُ الْمَدَّيْنِ، وَقُلِبَتِ الضَّمَّةُ كَسْرَةً فِي '
          'الْيَائِيِّ لِئَلَّا تَنْقَلِبَ الْيَاءُ وَاوًا فَيَلْتَبِسَ '
          'الْوَاوِيُّ بِالْيَائِيِّ.',
      'One of the two long vowels drops; in a yāʾ root the ḍamma becomes kasra '
          'so the yāʾ will not turn into wāw and blur the two root types.',
    ),
    source: 'شذا العرف · page1_0151',
  ),
  RuleId.idghamMudaaf: RuleInfo(
    id: RuleId.idghamMudaaf,
    arabicName: 'الْإِدْغَامُ فِي الْمُضَاعَفِ',
    taleel: L4(
      'دوه مثلان سره یوځای شول، اول یې ساکن شو او په دویم کې مدغم شو.',
      'دو مثل جمع شدند، اوّلی ساکن شد و در دومی ادغام گشت.',
      'اجْتَمَعَ الْمِثْلَانِ فَسُكِّنَ الْأَوَّلُ وَأُدْغِمَ فِي الثَّانِي.',
      'Two identical letters met: the first was made silent and merged into '
          'the second.',
    ),
    source: 'شذا العرف · page1_0156',
  ),
  RuleId.fakkIdgham: RuleInfo(
    id: RuleId.fakkIdgham,
    arabicName: 'فَكُّ الْإِدْغَامِ',
    taleel: L4(
      'ادغام مات شو، ځکه چې متحرک ضمیر رفع ورسره ونښت او لام یې ساکن کړ.',
      'ادغام فک شد، زیرا ضمیر رفع متحرک متصل شد و لام را ساکن کرد.',
      'وَجَبَ فَكُّ الْإِدْغَامِ لِاتِّصَالِ ضَمِيرِ الرَّفْعِ '
          'الْمُتَحَرِّكِ، فَسَكَنَتِ اللَّامُ.',
      'The merge is undone: an overt subject pronoun attaches and forces the '
          'final root letter into sukūn.',
    ),
    source: 'شذا العرف · page1_0049',
  ),
  RuleId.ijtimaHamzatayn: RuleInfo(
    id: RuleId.ijtimaHamzatayn,
    arabicName: 'اجْتِمَاعُ الْهَمْزَتَيْنِ',
    taleel: L4(
      'دوه همزې د کلمې په سر کې راټولې شوې، نو دویمه یې د لومړۍ د حرکت له '
          'جنسه مدّه شوه.',
      'دو همزه در آغاز کلمه جمع شدند، پس دومی مدّی از جنس حرکت اوّلی گشت.',
      'اجْتَمَعَتْ هَمْزَتَانِ فِي أَوَّلِ الْكَلِمَةِ وَسَكَنَتِ '
          'الثَّانِيَةُ، فَأُبْدِلَتْ مَدًّا مِنْ جِنْسِ حَرَكَةِ الْأُولَى.',
      'Two hamzas met at the head of the word and the second was silent, so it '
          'became a long vowel matching the first one’s vowel.',
    ),
    source: 'شذا العرف · page1_0049',
  ),
  RuleId.hadhfHamzatAmr: RuleInfo(
    id: RuleId.hadhfHamzatAmr,
    arabicName: 'حَذْفُ هَمْزَةِ أَخَذَ وَأَكَلَ',
    taleel: L4(
      'د أخذ او أكل همزه په امر کې مطلقاً غورځي.',
      'همزهٔ أخذ و أكل در امر مطلقاً می‌افتد.',
      'تُحْذَفُ هَمْزَةُ أَخَذَ وَأَكَلَ فِي الْأَمْرِ مُطْلَقًا.',
      'The hamza of ʾakhadha and ʾakala drops in the imperative without '
          'qualification.',
    ),
    source: 'شذا العرف · page1_0049',
  ),
  RuleId.ilalMasdarIfal: RuleInfo(
    id: RuleId.ilalMasdarIfal,
    arabicName: 'إِعْلَالُ مَصْدَرِ الْإِفْعَالِ',
    taleel: L4(
      'حرکت ونقل شو، حرف علت الف شو، بیا دوه الفونه سره ولګېدل نو دویم '
          'حذف او د عوض تاء راغله.',
      'حرکت نقل شد، حرف علت الف گشت، سپس دو الف برخوردند پس دومی حذف و تاء '
          'عوض آمد.',
      'نُقِلَتِ الْحَرَكَةُ وَقُلِبَ حَرْفُ الْعِلَّةِ أَلِفًا، ثُمَّ '
          'حُذِفَتْ إِحْدَى الْأَلِفَيْنِ لِالْتِقَاءِ السَّاكِنَيْنِ '
          'وَعُوِّضَ عَنْهَا التَّاءُ.',
      'The vowel shifts, the weak letter becomes alif, then one of the two '
          'alifs drops where they meet and a tāʾ stands in for it.',
    ),
    source: 'شذا العرف · page1_0151',
  ),
  RuleId.qalbAlifLilharaka: RuleInfo(
    id: RuleId.qalbAlifLilharaka,
    arabicName: 'قَلْبُ الْأَلِفِ لِمُنَاسَبَةِ الْحَرَكَةِ',
    taleel: L4(
      'الف هغه حرف ته واوښته چې له مخکینې حرکت سره مجانس دی.',
      'الف به حرفی بدل شد که با حرکت ما قبل مجانس است.',
      'قُلِبَتِ الْأَلِفُ حَرْفًا يُجَانِسُ حَرَكَةَ مَا قَبْلَهَا.',
      'The alif changed into the letter that matches the preceding vowel.',
    ),
    source: 'شذا العرف · page1_0143',
  ),
  RuleId.iltiqaSakinayn: RuleInfo(
    id: RuleId.iltiqaSakinayn,
    arabicName: 'الْتِقَاءُ السَّاكِنَيْنِ',
    taleel: L4(
      'دوه ساکنه سره ولګېدل، نو لومړی یې متحرک شو.',
      'دو ساکن برخوردند، پس اوّلی متحرک شد.',
      'الْتَقَى سَاكِنَانِ فَحُرِّكَ الْأَوَّلُ تَخَلُّصًا مِنْهُمَا.',
      'Two sukūns met, so the first was given a vowel to break them apart.',
    ),
    source: 'شذا العرف · page1_0163',
  ),
};

RuleInfo ruleOf(RuleId id) => ruleTable[id]!;

/// One recorded transformation: what the word looked like, what it became,
/// and under which rule. The chain of these *is* the app's answer to «ولې؟».
class IlalStep {
  const IlalStep({
    required this.before,
    required this.after,
    required this.rule,
    this.note,
  });

  final String before;
  final String after;
  final RuleId rule;

  /// Optional extra clause for this particular application, e.g. naming the
  /// letter involved.
  final L4? note;

  RuleInfo get info => ruleOf(rule);
}
