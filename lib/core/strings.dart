/// UI strings in the four languages the app speaks.
///
/// Domain text — rule names, taʿlīl, section headings — lives with the domain
/// (`sarf/rules.dart`, `sarf/tasrif.dart`) so a rule and its explanation can
/// never drift apart. What is here is only the chrome.
library;

import '../sarf/lang.dart';

class S {
  const S._(this.lang, this._m);

  final Lang lang;
  final Map<String, String> _m;

  static S of(Lang l) => S._(l, _tables[l]!);

  String _(String k) => _m[k] ?? _tables[Lang.en]![k] ?? k;

  // ── app + navigation ──
  String get appName => _('appName');
  String get tagline => _('tagline');
  String get author => _('author');
  String get navHome => _('navHome');
  String get navSettings => _('navSettings');
  String get navAbout => _('navAbout');

  // ── home ──
  String get enterWord => _('enterWord');
  String get enterWordHint => _('enterWordHint');
  String get process => _('process');
  String get examples => _('examples');
  String get recent => _('recent');
  String get clearRecent => _('clearRecent');
  String get notRecognised => _('notRecognised');
  String get notRecognisedBody => _('notRecognisedBody');
  String get howItWorks => _('howItWorks');
  String get howItWorksBody => _('howItWorksBody');
  String get sourcesTitle => _('sourcesTitle');
  String get sourcesBody => _('sourcesBody');

  // ── word info ──
  String get identity => _('identity');
  String get root => _('root');
  String get wazn => _('wazn');
  String get bab => _('bab');
  String get sixKinds => _('sixKinds');
  String get sevenKinds => _('sevenKinds');
  String get twelveKinds => _('twelveKinds');
  String get ziyada => _('ziyada');
  String get masdar => _('masdar');
  String get meaning => _('meaning');
  String get otherReadings => _('otherReadings');
  String get sarfSaghir => _('sarfSaghir');
  String get sarfSaghirSub => _('sarfSaghirSub');
  String get sarfKabir => _('sarfKabir');
  String get sarfKabirSub => _('sarfKabirSub');
  String get mushtaqqat => _('mushtaqqat');
  String get openTable => _('openTable');

  // ── tables ──
  String get number => _('number');
  String get word => _('word');
  String get sigha => _('sigha');
  String get pronoun => _('pronoun');
  String get gridView => _('gridView');
  String get listView => _('listView');
  String get hasIlal => _('hasIlal');
  String get noIlal => _('noIlal');
  String get sighaCount => _('sighaCount');

  // ── i'lal detail ──
  String get derivation => _('derivation');
  String get original => _('original');
  String get result => _('result');
  String get rule => _('rule');
  String get why => _('why');
  String get source => _('source');
  String get noIlalBody => _('noIlalBody');
  String get steps => _('steps');

  // ── provenance ──
  String get samai => _('samai');
  String get qiyasi => _('qiyasi');
  String get muwallad => _('muwallad');
  String get samaiNote => _('samaiNote');
  String get muwalladNote => _('muwalladNote');

  // ── settings ──
  String get settings => _('settings');
  String get language => _('language');
  String get languageSub => _('languageSub');
  String get appearance => _('appearance');
  String get light => _('light');
  String get dark => _('dark');
  String get system => _('system');
  String get typography => _('typography');
  String get showTashkeel => _('showTashkeel');
  String get showTashkeelSub => _('showTashkeelSub');
  String get arabicNumerals => _('arabicNumerals');
  String get arabicNumeralsSub => _('arabicNumeralsSub');
  String get textSize => _('textSize');

  // ── about ──
  String get about => _('about');
  String get aboutBody => _('aboutBody');
  String get version => _('version');
  String get sources => _('sources');
  String get privacy => _('privacy');
  String get privacyBody => _('privacyBody');
  String get rateApp => _('rateApp');
  String get rateAppSub => _('rateAppSub');
  String get reportBug => _('reportBug');
  String get reportBugSub => _('reportBugSub');
  String get share => _('share');
  String get licences => _('licences');

  // ── misc ──
  String get close => _('close');
  String get copy => _('copy');
  String get copied => _('copied');
  String get exitTitle => _('exitTitle');
  String get exitMsg => _('exitMsg');
  String get exit => _('exit');
  String get cancel => _('cancel');
}

const Map<Lang, Map<String, String>> _tables = {
  // ═══════════════════════════════════════════════════════════ پښتو ══════
  Lang.ps: {
    'appName': 'تصريف',
    'tagline': 'الصَّرْفُ أُمُّ الْعُلُومِ وَالنَّحْوُ أَبُوهَا',
    'author': 'الیاس عمر',
    'navHome': 'کور',
    'navSettings': 'تنظیمات',
    'navAbout': 'په اړه',
    'enterWord': 'کلمه ولیکئ',
    'enterWordHint': 'لکه: ضرب · دحرج · اکتسب · قال',
    'process': 'پروسس',
    'examples': 'بېلګې',
    'recent': 'وروستي',
    'clearRecent': 'پاکول',
    'notRecognised': 'کلمه ونه پېژندل شوه',
    'notRecognisedBody':
        'دا کلمه له هېڅ پېژندل شوي وزن سره سمون نه خوري. هڅه وکړئ چې د '
            'ماضي معلوم بڼه ولیکئ — لکه «ضرب» نه «یضرب».',
    'howItWorks': 'دا څنګه کار کوي',
    'howItWorksBody':
        'کلمه لومړی خپل وزن او ماده ته ماتیږي، بیا یې د شذا العرف او إرشاد '
            'الصرف د قواعدو له مخې اعلال جوړیږي. هره صیغه خپل تعلیل ورسره لري.',
    'sourcesTitle': 'له کتابونو څخه',
    'sourcesBody':
        'شذا العرف في فن الصرف · إرشاد الصرف (فارسي اصل او عربي تعریب)',
    'identity': 'پېژندنه',
    'root': 'ماده',
    'wazn': 'وزن',
    'bab': 'باب',
    'sixKinds': 'په شپږو اقسامو کې',
    'sevenKinds': 'په اوو اقسامو کې',
    'twelveKinds': 'مشتق',
    'ziyada': 'زیادت',
    'masdar': 'مصدر',
    'meaning': 'معنی',
    'otherReadings': 'نور احتمالات',
    'sarfSaghir': 'صرف صغیر',
    'sarfSaghirSub': 'د باب لنډیز په یوه کرښه',
    'sarfKabir': 'صرف کبیر',
    'sarfKabirSub': 'ټول ګردانونه، صیغه په صیغه',
    'mushtaqqat': 'مشتقات',
    'openTable': 'جدول پرانیزئ',
    'number': 'شمېره',
    'word': 'کلمه',
    'sigha': 'صیغه',
    'pronoun': 'ضمیر',
    'gridView': 'ګریډ',
    'listView': 'لیست',
    'hasIlal': 'اعلال',
    'noIlal': 'بې اعلاله',
    'sighaCount': 'صیغې',
    'derivation': 'اشتقاق',
    'original': 'اصل',
    'result': 'نتیجه',
    'rule': 'قاعده',
    'why': 'تعلیل',
    'source': 'مرجع',
    'noIlalBody': 'په دې صیغه کې هېڅ اعلال نه دی شوی — اصل او نتیجه یې یو دي.',
    'steps': 'ګامونه',
    'samai': 'سماعي',
    'qiyasi': 'قیاسي',
    'muwallad': 'مولَّد',
    'samaiNote': 'له کتابه اخیستل شوی.',
    'muwalladNote':
        'دا اټکل دی — باب سماعي دی او دا ماده په ډاټابیس کې نشته، نو د '
            'ضوابطو له مخې وړاندیز شوې.',
    'settings': 'تنظیمات',
    'language': 'ژبه',
    'languageSub': 'د پروګرام او د تعلیلاتو ژبه',
    'appearance': 'بڼه',
    'light': 'روښانه',
    'dark': 'تیاره',
    'system': 'سیستم',
    'typography': 'متن',
    'showTashkeel': 'حرکات ښکاره کړه',
    'showTashkeelSub': 'د امتحان لپاره یې پټولی شئ',
    'arabicNumerals': 'عربي ارقام',
    'arabicNumeralsSub': '۱۲۳ د 123 پر ځای',
    'textSize': 'د متن کچه',
    'about': 'په اړه',
    'aboutBody':
        'تصريف د علم صرف د زده کړې لپاره جوړ شوی — د یوې کلمې په لیکلو سره '
            'یې باب، قسم، صرف صغیر او بشپړ صرف کبیر ښیي، او د هرې صیغې اعلال '
            'له خپلې قاعدې او تعلیل سره وړاندې کوي.',
    'version': 'نسخه',
    'sources': 'سرچینې',
    'privacy': 'د محرمیت تګلاره',
    'privacyBody':
        'دا اپلیکېشن هېڅ ډاټا نه راټولوي او انټرنټ ته اړتیا نلري. هرڅه '
            'ستاسو پر وسیله پروسس کیږي.',
    'rateApp': 'نظر او ستوري',
    'rateAppSub': 'په پلې سټور کې مو ملاتړ وکړئ',
    'reportBug': 'د ستونزې راپور',
    'reportBugSub': 'که کوم ګردان یا اعلال غلط وي، خبر مو کړئ',
    'share': 'شریکول',
    'licences': 'جوازونه',
    'close': 'بندول',
    'copy': 'کاپي',
    'copied': 'کاپي شو',
    'exitTitle': 'وتل؟',
    'exitMsg': 'غواړئ له اپلیکېشنه ووځئ؟',
    'exit': 'وتل',
    'cancel': 'لغوه',
  },
  // ═══════════════════════════════════════════════════════════ فارسی ══════
  Lang.fa: {
    'appName': 'تصريف',
    'tagline': 'الصَّرْفُ أُمُّ الْعُلُومِ وَالنَّحْوُ أَبُوهَا',
    'author': 'الیاس عمر',
    'navHome': 'خانه',
    'navSettings': 'تنظیمات',
    'navAbout': 'درباره',
    'enterWord': 'کلمه را بنویسید',
    'enterWordHint': 'مانند: ضرب · دحرج · اکتسب · قال',
    'process': 'پردازش',
    'examples': 'نمونه‌ها',
    'recent': 'اخیر',
    'clearRecent': 'پاک کردن',
    'notRecognised': 'کلمه شناخته نشد',
    'notRecognisedBody':
        'این کلمه با هیچ وزن شناخته‌شده‌ای مطابقت ندارد. صورت ماضی معلوم را '
            'بنویسید — مثلاً «ضرب» نه «یضرب».',
    'howItWorks': 'چگونه کار می‌کند',
    'howItWorksBody':
        'کلمه نخست به وزن و مادّهٔ خود تحلیل می‌شود، سپس بر پایهٔ قواعد شذا '
            'العرف و إرشاد الصرف اعلال آن ساخته می‌شود. هر صیغه تعلیل خود را دارد.',
    'sourcesTitle': 'از کتاب‌ها',
    'sourcesBody': 'شذا العرف في فن الصرف · إرشاد الصرف (اصل فارسی و تعریب عربی)',
    'identity': 'شناسه',
    'root': 'مادّه',
    'wazn': 'وزن',
    'bab': 'باب',
    'sixKinds': 'در شش قسم',
    'sevenKinds': 'در هفت قسم',
    'twelveKinds': 'مشتق',
    'ziyada': 'زیادت',
    'masdar': 'مصدر',
    'meaning': 'معنا',
    'otherReadings': 'احتمالات دیگر',
    'sarfSaghir': 'صرف صغیر',
    'sarfSaghirSub': 'خلاصهٔ باب در یک سطر',
    'sarfKabir': 'صرف کبیر',
    'sarfKabirSub': 'همهٔ گردان‌ها، صیغه به صیغه',
    'mushtaqqat': 'مشتقات',
    'openTable': 'گشودن جدول',
    'number': 'شماره',
    'word': 'کلمه',
    'sigha': 'صیغه',
    'pronoun': 'ضمیر',
    'gridView': 'شبکه',
    'listView': 'فهرست',
    'hasIlal': 'اعلال',
    'noIlal': 'بدون اعلال',
    'sighaCount': 'صیغه',
    'derivation': 'اشتقاق',
    'original': 'اصل',
    'result': 'نتیجه',
    'rule': 'قاعده',
    'why': 'تعلیل',
    'source': 'مرجع',
    'noIlalBody': 'در این صیغه اعلالی رخ نداده — اصل و نتیجه یکی است.',
    'steps': 'گام‌ها',
    'samai': 'سماعی',
    'qiyasi': 'قیاسی',
    'muwallad': 'مولَّد',
    'samaiNote': 'برگرفته از کتاب.',
    'muwalladNote':
        'این حدس است — باب سماعی است و این مادّه در پایگاه داده نیست، پس بر '
            'پایهٔ ضوابط پیشنهاد شده.',
    'settings': 'تنظیمات',
    'language': 'زبان',
    'languageSub': 'زبان برنامه و تعلیلات',
    'appearance': 'ظاهر',
    'light': 'روشن',
    'dark': 'تیره',
    'system': 'سیستم',
    'typography': 'متن',
    'showTashkeel': 'نمایش حرکات',
    'showTashkeelSub': 'برای آزمون می‌توانید پنهان کنید',
    'arabicNumerals': 'ارقام عربی',
    'arabicNumeralsSub': '۱۲۳ به‌جای 123',
    'textSize': 'اندازهٔ متن',
    'about': 'درباره',
    'aboutBody':
        'تصريف برای آموزش علم صرف ساخته شده — با نوشتن یک کلمه، باب و قسم و '
            'صرف صغیر و صرف کبیر کامل آن را نشان می‌دهد، و اعلال هر صیغه را با '
            'قاعده و تعلیلش عرضه می‌کند.',
    'version': 'نسخه',
    'sources': 'منابع',
    'privacy': 'سیاست حریم خصوصی',
    'privacyBody':
        'این برنامه هیچ داده‌ای جمع نمی‌کند و به اینترنت نیاز ندارد. همه‌چیز '
            'روی دستگاه شما پردازش می‌شود.',
    'rateApp': 'امتیاز و نظر',
    'rateAppSub': 'در پلی استور از ما پشتیبانی کنید',
    'reportBug': 'گزارش اشکال',
    'reportBugSub': 'اگر گردان یا اعلالی نادرست بود، خبر دهید',
    'share': 'هم‌رسانی',
    'licences': 'مجوزها',
    'close': 'بستن',
    'copy': 'رونوشت',
    'copied': 'رونوشت شد',
    'exitTitle': 'خروج؟',
    'exitMsg': 'می‌خواهید از برنامه خارج شوید؟',
    'exit': 'خروج',
    'cancel': 'انصراف',
  },
  // ═══════════════════════════════════════════════════════════ العربية ═══
  Lang.ar: {
    'appName': 'تصريف',
    'tagline': 'الصَّرْفُ أُمُّ الْعُلُومِ وَالنَّحْوُ أَبُوهَا',
    'author': 'إلياس عمر',
    'navHome': 'الرئيسة',
    'navSettings': 'الإعدادات',
    'navAbout': 'عن التطبيق',
    'enterWord': 'اكتب الكلمة',
    'enterWordHint': 'مثل: ضرب · دحرج · اكتسب · قال',
    'process': 'حلِّل',
    'examples': 'أمثلة',
    'recent': 'الأخيرة',
    'clearRecent': 'مسح',
    'notRecognised': 'لم تُعرف الكلمة',
    'notRecognisedBody':
        'لا تطابق هذه الكلمة وزنًا معروفًا. جرِّب صيغة الماضي المعلوم — '
            '«ضرب» لا «يضرب».',
    'howItWorks': 'كيف يعمل',
    'howItWorksBody':
        'تُردُّ الكلمة أولًا إلى وزنها ومادتها، ثم يُجرى عليها الإعلال على '
            'قواعد شذا العرف وإرشاد الصرف. ولكل صيغة تعليلها.',
    'sourcesTitle': 'من الكتب',
    'sourcesBody': 'شذا العرف في فن الصرف · إرشاد الصرف (الأصل الفارسي والتعريب)',
    'identity': 'التعريف',
    'root': 'المادة',
    'wazn': 'الوزن',
    'bab': 'الباب',
    'sixKinds': 'في الأقسام الستة',
    'sevenKinds': 'في الأقسام السبعة',
    'twelveKinds': 'المشتق',
    'ziyada': 'الزيادة',
    'masdar': 'المصدر',
    'meaning': 'المعنى',
    'otherReadings': 'قراءات أخرى',
    'sarfSaghir': 'الصرف الصغير',
    'sarfSaghirSub': 'خلاصة الباب في سطر',
    'sarfKabir': 'الصرف الكبير',
    'sarfKabirSub': 'جميع التصاريف، صيغةً صيغةً',
    'mushtaqqat': 'المشتقات',
    'openTable': 'افتح الجدول',
    'number': 'الرقم',
    'word': 'الكلمة',
    'sigha': 'الصيغة',
    'pronoun': 'الضمير',
    'gridView': 'شبكة',
    'listView': 'قائمة',
    'hasIlal': 'إعلال',
    'noIlal': 'بلا إعلال',
    'sighaCount': 'صيغة',
    'derivation': 'الاشتقاق',
    'original': 'الأصل',
    'result': 'النتيجة',
    'rule': 'القاعدة',
    'why': 'التعليل',
    'source': 'المرجع',
    'noIlalBody': 'لم يقع في هذه الصيغة إعلال — أصلها ونتيجتها سواء.',
    'steps': 'الخطوات',
    'samai': 'سماعي',
    'qiyasi': 'قياسي',
    'muwallad': 'مولَّد',
    'samaiNote': 'مأخوذ من الكتاب.',
    'muwalladNote':
        'هذا تقدير — الباب سماعي وهذه المادة ليست في القاعدة، فاقتُرحت على '
            'الضوابط.',
    'settings': 'الإعدادات',
    'language': 'اللغة',
    'languageSub': 'لغة التطبيق والتعليلات',
    'appearance': 'المظهر',
    'light': 'فاتح',
    'dark': 'داكن',
    'system': 'النظام',
    'typography': 'النص',
    'showTashkeel': 'إظهار الحركات',
    'showTashkeelSub': 'يمكن إخفاؤها للاختبار',
    'arabicNumerals': 'الأرقام العربية',
    'arabicNumeralsSub': '۱۲۳ بدل 123',
    'textSize': 'حجم النص',
    'about': 'عن التطبيق',
    'aboutBody':
        'تصريف وُضِع لتعليم علم الصرف — تكتب كلمة واحدة فيعرض بابها وقسمها '
            'وصرفها الصغير والكبير كاملًا، ويقدِّم إعلال كل صيغة بقاعدته '
            'وتعليله.',
    'version': 'الإصدار',
    'sources': 'المصادر',
    'privacy': 'سياسة الخصوصية',
    'privacyBody':
        'لا يجمع هذا التطبيق أي بيانات ولا يحتاج إلى الإنترنت. كل شيء يُعالَج '
            'على جهازك.',
    'rateApp': 'التقييم',
    'rateAppSub': 'ادعمنا في المتجر',
    'reportBug': 'الإبلاغ عن خطأ',
    'reportBugSub': 'إن وجدت تصريفًا أو إعلالًا خاطئًا فأخبرنا',
    'share': 'مشاركة',
    'licences': 'التراخيص',
    'close': 'إغلاق',
    'copy': 'نسخ',
    'copied': 'نُسخ',
    'exitTitle': 'خروج؟',
    'exitMsg': 'أتريد الخروج من التطبيق؟',
    'exit': 'خروج',
    'cancel': 'إلغاء',
  },
  // ═══════════════════════════════════════════════════════════ English ═══
  Lang.en: {
    'appName': 'Taṣrīf',
    'tagline': 'الصَّرْفُ أُمُّ الْعُلُومِ وَالنَّحْوُ أَبُوهَا',
    'author': 'Elyas Omar',
    'navHome': 'Home',
    'navSettings': 'Settings',
    'navAbout': 'About',
    'enterWord': 'Enter a word',
    'enterWordHint': 'e.g. ضرب · دحرج · اكتسب · قال',
    'process': 'Analyse',
    'examples': 'Examples',
    'recent': 'Recent',
    'clearRecent': 'Clear',
    'notRecognised': 'Word not recognised',
    'notRecognisedBody':
        'This does not match any known pattern. Try the plain past-tense form '
            '— ضرب rather than يضرب.',
    'howItWorks': 'How this works',
    'howItWorksBody':
        'The word is first broken down into its pattern and root, then the '
            'i‘lāl is derived using the rules of Shadhā al-ʿArf and Irshād '
            'al-Ṣarf. Every form carries its own reasoning.',
    'sourcesTitle': 'From the books',
    'sourcesBody':
        'Shadhā al-ʿArf fī Fann al-Ṣarf · Irshād al-Ṣarf (Persian original and '
            'Arabic rendering)',
    'identity': 'Identity',
    'root': 'Root',
    'wazn': 'Pattern',
    'bab': 'Bāb',
    'sixKinds': 'Of the six classes',
    'sevenKinds': 'Of the seven classes',
    'twelveKinds': 'Derived form',
    'ziyada': 'Augmentation',
    'masdar': 'Verbal noun',
    'meaning': 'Sense',
    'otherReadings': 'Other readings',
    'sarfSaghir': 'Ṣarf ṣaghīr',
    'sarfSaghirSub': 'The whole bāb in one line',
    'sarfKabir': 'Ṣarf kabīr',
    'sarfKabirSub': 'Every table, form by form',
    'mushtaqqat': 'Derived nouns',
    'openTable': 'Open table',
    'number': 'No.',
    'word': 'Form',
    'sigha': 'Ṣīgha',
    'pronoun': 'Pronoun',
    'gridView': 'Grid',
    'listView': 'List',
    'hasIlal': 'i‘lāl',
    'noIlal': 'no i‘lāl',
    'sighaCount': 'forms',
    'derivation': 'Derivation',
    'original': 'Underlying',
    'result': 'Result',
    'rule': 'Rule',
    'why': 'Reason',
    'source': 'Source',
    'noIlalBody':
        'Nothing was altered in this form — the underlying shape and the '
            'result are the same.',
    'steps': 'Steps',
    'samai': 'samāʿī',
    'qiyasi': 'qiyāsī',
    'muwallad': 'generated',
    'samaiNote': 'Taken from the books.',
    'muwalladNote':
        'This is an estimate — the bāb is samāʿī and this root is not in the '
            'lexicon, so it was inferred from the general indicators.',
    'settings': 'Settings',
    'language': 'Language',
    'languageSub': 'Interface and explanations',
    'appearance': 'Appearance',
    'light': 'Light',
    'dark': 'Dark',
    'system': 'System',
    'typography': 'Text',
    'showTashkeel': 'Show vowel marks',
    'showTashkeelSub': 'Hide them to test yourself',
    'arabicNumerals': 'Arabic-Indic digits',
    'arabicNumeralsSub': '۱۲۳ instead of 123',
    'textSize': 'Text size',
    'about': 'About',
    'aboutBody':
        'Taṣrīf was built for studying Arabic morphology. Type one word and it '
            'gives you its bāb and class, its ṣarf ṣaghīr and its full ṣarf '
            'kabīr — and for every form, the i‘lāl with the rule and reasoning '
            'behind it.',
    'version': 'Version',
    'sources': 'Sources',
    'privacy': 'Privacy policy',
    'privacyBody':
        'This app collects nothing and needs no internet connection. '
            'Everything is worked out on your device.',
    'rateApp': 'Rate the app',
    'rateAppSub': 'Support us on the store',
    'reportBug': 'Report a problem',
    'reportBugSub': 'If a form or an i‘lāl is wrong, tell us',
    'share': 'Share',
    'licences': 'Licences',
    'close': 'Close',
    'copy': 'Copy',
    'copied': 'Copied',
    'exitTitle': 'Exit?',
    'exitMsg': 'Leave the app?',
    'exit': 'Exit',
    'cancel': 'Cancel',
  },
};
