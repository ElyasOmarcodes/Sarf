/// The engine is checked against forms the books actually print, so a
/// regression shows up as a disagreement with شذا العرف or إرشاد الصرف
/// rather than as a failing assertion nobody can adjudicate.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:tasrif/sarf/analyzer.dart';
import 'package:tasrif/sarf/awzan.dart';
import 'package:tasrif/sarf/conjugator.dart';
import 'package:tasrif/sarf/lexicon.dart';
import 'package:tasrif/sarf/models.dart';
import 'package:tasrif/sarf/tasrif.dart';


/// Combining marks can be written in either order. Unicode's canonical class
/// actually sorts fatḥa *before* shadda, while every Arabic keyboard, book and
/// reader puts shadda first — which is what the engine emits. This reorders
/// both sides so an assertion compares letters and vowels, not keystrokes.
String canon(String s) {
  const vowels = 'ًٌٍَُِْٰ';
  const shadda = 'ّ';
  final out = StringBuffer();
  final marks = <String>[];
  void flush() {
    if (marks.isEmpty) return;
    marks.sort((a, b) {
      int rank(String c) => c == shadda ? 0 : 1;
      return rank(a).compareTo(rank(b));
    });
    out.writeAll(marks);
    marks.clear();
  }

  for (final c in s.split('')) {
    if (vowels.contains(c) || c == shadda) {
      marks.add(c);
    } else {
      flush();
      out.write(c);
    }
  }
  flush();
  return out.toString();
}

/// Every assertion in this file goes through here, so both sides are
/// canonicalised before they are compared. Anything that is not Arabic text
/// (a Matcher, an enum, a bool) passes through untouched.
void expectAr(dynamic actual, dynamic expected, {String? reason}) {
  dynamic norm(dynamic v) {
    if (v is String) return canon(v);
    if (v is Iterable<String>) return v.map(canon).toList();
    return v;
  }

  expect(norm(actual), norm(expected), reason: reason);
}

VerbSpec spec(String root, {String? babId, String wazn = 'mujarrad3'}) {
  final r = root.split('');
  final type = classify(r);
  return VerbSpec(
    root: r,
    wazn: waznById(wazn)!,
    type: type,
    bab: babId == null ? guessBab(r, type).bab : babById(babId),
  );
}

List<String> madi(VerbSpec s, [Voice v = Voice.maalum]) =>
    Sigha.values.map((g) => buildMadi(s, g, v).text).toList();

List<String> mudari(VerbSpec s, [Voice v = Voice.maalum]) =>
    Sigha.values.map((g) => buildMudari(s, g, v).text).toList();

List<String> amr(VerbSpec s) =>
    hadirSighas.map((g) => buildAmr(s, g).text).toList();

void main() {
  group('السالم — ضَرَبَ يَضْرِبُ (الباب الأول)', () {
    final s = spec('ضرب', babId: 'darb');

    test('الماضي المعلوم: أربع عشرة صيغة', () {
      expectAr(madi(s), [
        'ضَرَبَ', 'ضَرَبَا', 'ضَرَبُوا', 'ضَرَبَتْ', 'ضَرَبَتَا', 'ضَرَبْنَ',
        'ضَرَبْتَ', 'ضَرَبْتُمَا', 'ضَرَبْتُمْ', 'ضَرَبْتِ', 'ضَرَبْتُمَا',
        'ضَرَبْتُنَّ', 'ضَرَبْتُ', 'ضَرَبْنَا',
      ]);
    });

    test('المضارع المعلوم', () {
      expectAr(mudari(s), [
        'يَضْرِبُ', 'يَضْرِبَانِ', 'يَضْرِبُونَ', 'تَضْرِبُ', 'تَضْرِبَانِ',
        'يَضْرِبْنَ', 'تَضْرِبُ', 'تَضْرِبَانِ', 'تَضْرِبُونَ', 'تَضْرِبِينَ',
        'تَضْرِبَانِ', 'تَضْرِبْنَ', 'أَضْرِبُ', 'نَضْرِبُ',
      ]);
    });

    test('المجهول', () {
      expectAr(madi(s, Voice.majhul).first, 'ضُرِبَ');
      expectAr(buildMudari(s, Sigha.wahidMudhakkarGhaib, Voice.majhul).text,
          'يُضْرَبُ');
    });

    test('الجزم والنصب والأمر', () {
      expectAr(
        buildMudari(s, Sigha.wahidMudhakkarGhaib, Voice.maalum,
                mood: Mood.majzum)
            .text,
        'يَضْرِبْ',
      );
      expectAr(
        buildMudari(s, Sigha.wahidMudhakkarGhaib, Voice.maalum,
                mood: Mood.mansub)
            .text,
        'يَضْرِبَ',
      );
      expectAr(amr(s), ['اِضْرِبْ', 'اِضْرِبَا', 'اِضْرِبُوا', 'اِضْرِبِي', 'اِضْرِبَا', 'اِضْرِبْنَ']);
    });

    test('همزة الوصل تُضم إذا كان عين المضارع مضمومًا', () {
      // «وضمُّها في أمر الثلاثي المضموم العين أصالة» — شذا العرف page1_0127
      expectAr(amr(spec('نصر', babId: 'nasr')).first, 'اُنْصُرْ');
      expectAr(amr(spec('فتح', babId: 'fath')).first, 'اِفْتَحْ');
    });
  });

  group('الأجوف — قاعدة قال وباع', () {
    final qala = spec('قول', babId: 'nasr');
    final baa = spec('بيع', babId: 'darb');
    final khafa = spec('خوف', babId: 'sami');

    test('الماضي: تسلم العين متحركة اللام وتُحذف ساكنَتَها', () {
      expectAr(madi(qala).take(6).toList(), ['قَالَ', 'قَالَا', 'قَالُوا', 'قَالَتْ', 'قَالَتَا', 'قُلْنَ']);
      expectAr(madi(baa).take(6).toList(), ['بَاعَ', 'بَاعَا', 'بَاعُوا', 'بَاعَتْ', 'بَاعَتَا', 'بِعْنَ']);
    });

    test('قاعدة قُلْنَ طُلْنَ: تُضم الفاء بعد حذف الواو غير المكسورة', () {
      expectAr(buildMadi(qala, Sigha.wahidMutakallim, Voice.maalum).text, 'قُلْتُ');
      expectAr(buildMadi(spec('طول', babId: 'karam'), Sigha.wahidMutakallim,
              Voice.maalum)
          .text,
          'طُلْتُ');
    });

    test('قاعدة خِفْنَ بِعْنَ: تُكسر الفاء بعد الياء والواو المكسورة', () {
      expectAr(buildMadi(baa, Sigha.wahidMutakallim, Voice.maalum).text, 'بِعْتُ');
      expectAr(buildMadi(khafa, Sigha.wahidMutakallim, Voice.maalum).text,
          'خِفْتُ');
    });

    test('المضارع: الإعلال بالنقل', () {
      expectAr(mudari(qala).first, 'يَقُولُ');
      expectAr(mudari(baa).first, 'يَبِيعُ');
      expectAr(mudari(khafa).first, 'يَخَافُ');
    });

    test('الجزم يحذف العين، والأمر مثله', () {
      expectAr(
        buildMudari(qala, Sigha.wahidMudhakkarGhaib, Voice.maalum,
                mood: Mood.majzum)
            .text,
        'يَقُلْ',
      );
      expectAr(amr(qala).first, 'قُلْ');
      expectAr(amr(baa).first, 'بِعْ');
      expectAr(amr(khafa).first, 'خَفْ');
    });

    test('المجهول: قِيلَ وبِيعَ', () {
      expectAr(madi(qala, Voice.majhul).first, 'قِيلَ');
      expectAr(madi(baa, Voice.majhul).first, 'بِيعَ');
      expectAr(buildMudari(qala, Sigha.wahidMudhakkarGhaib, Voice.majhul).text,
          'يُقَالُ');
    });

    test('سلسلة الإعلال مسجَّلة وليست مفترضة', () {
      final f = buildMadi(qala, Sigha.wahidMudhakkarGhaib, Voice.maalum);
      expectAr(f.underlying, 'قَوَلَ');
      expectAr(f.steps, isNotEmpty);
      expectAr(f.steps.first.rule.name, 'qalbWawYaAlifan');
    });
  });

  group('الناقص', () {
    final ghaza = spec('غزو', babId: 'nasr');
    final rama = spec('رمي', babId: 'darb');
    final saa = spec('سعي', babId: 'fath');
    final radiya = spec('رضي', babId: 'sami');

    test('الماضي: قلب اللام ألفًا، طويلة في الواوي ومقصورة في اليائي', () {
      expectAr(madi(ghaza).first, 'غَزَا');
      expectAr(madi(rama).first, 'رَمَى');
      expectAr(madi(saa).first, 'سَعَى');
      // رَضِيَ: ما قبل اللام مكسور، فلا قلب.
      expectAr(madi(radiya).first, 'رَضِيَ');
    });

    test('واو الجماعة تحذف اللام', () {
      expectAr(madi(ghaza)[2], 'غَزَوْا');
      expectAr(madi(rama)[2], 'رَمَوْا');
      expectAr(madi(radiya)[2], 'رَضُوا');
    });

    test('تاء التأنيث تحذف الألف مطلقًا', () {
      expectAr(madi(ghaza)[3], 'غَزَتْ');
      expectAr(madi(rama)[3], 'رَمَتْ');
    });

    test('الإسناد إلى الضمير البارز يرد اللام إلى أصلها', () {
      expectAr(buildMadi(ghaza, Sigha.wahidMutakallim, Voice.maalum).text,
          'غَزَوْتُ');
      expectAr(buildMadi(rama, Sigha.wahidMutakallim, Voice.maalum).text,
          'رَمَيْتُ');
    });

    test('المضارع', () {
      expectAr(mudari(ghaza).first, 'يَغْزُو');
      expectAr(mudari(rama).first, 'يَرْمِي');
      expectAr(mudari(saa).first, 'يَسْعَى');
      expectAr(mudari(ghaza)[2], 'يَغْزُونَ');
      expectAr(mudari(rama)[2], 'يَرْمُونَ');
      expectAr(mudari(saa)[2], 'يَسْعَوْنَ');
    });

    test('قاعدة لم يَدْعُ: يُحذف حرف العلة عند الجزم وفي الأمر', () {
      expectAr(
        buildMudari(ghaza, Sigha.wahidMudhakkarGhaib, Voice.maalum,
                mood: Mood.majzum)
            .text,
        'يَغْزُ',
      );
      expectAr(amr(ghaza).first, 'اُغْزُ');
      expectAr(amr(rama).first, 'اِرْمِ');
      expectAr(amr(saa).first, 'اِسْعَ');
    });
  });

  group('المثال', () {
    final waada = spec('وعد', babId: 'darb');

    test('الماضي يسلم', () => expectAr(madi(waada).first, 'وَعَدَ'));

    test('تُحذف الفاء من المضارع على يَفْعِلُ ومن الأمر', () {
      expectAr(mudari(waada).first, 'يَعِدُ');
      expectAr(amr(waada).first, 'عِدْ');
    });

    test('المجهول يبقي الواو', () {
      expectAr(buildMudari(waada, Sigha.wahidMudhakkarGhaib, Voice.majhul).text,
          'يُوعَدُ');
    });
  });

  group('المضاعف', () {
    final madda = spec('مدد', babId: 'nasr');

    test('الإدغام حيث تحركت اللام، والفكّ عند ضمير الرفع المتحرك', () {
      expectAr(madi(madda).take(6).toList(), ['مَدَّ', 'مَدَّا', 'مَدُّوا', 'مَدَّتْ', 'مَدَّتَا', 'مَدَدْنَ']);
      expectAr(buildMadi(madda, Sigha.wahidMutakallim, Voice.maalum).text,
          'مَدَدْتُ');
    });

    test('المضارع يدغم، ونون النسوة تفكّ', () {
      expectAr(mudari(madda).first, 'يَمُدُّ');
      expectAr(mudari(madda)[5], 'يَمْدُدْنَ');
    });
  });

  group('المهموز', () {
    final akhadha = spec('ءخذ', babId: 'nasr');

    test('أَخَذَ يَأْخُذُ', () {
      expectAr(madi(akhadha).first, 'أَخَذَ');
      expectAr(mudari(akhadha).first, 'يَأْخُذُ');
    });

    test('اجتماع الهمزتين: أَأْخُذُ ← آخُذُ', () {
      expectAr(mudari(akhadha)[12], 'آخُذُ');
    });

    test('تُحذف همزة أخذ وأكل في الأمر', () {
      expectAr(amr(akhadha).first, 'خُذْ');
    });
  });

  group('المزيد فيه', () {
    test('الإفعال: تُحذف الهمزة من المضارع', () {
      final s = spec('كرم', wazn: 'ifal');
      expectAr(madi(s).first, 'أَكْرَمَ');
      expectAr(mudari(s).first, 'يُكْرِمُ');
      expectAr(mudari(s)[12], 'أُكْرِمُ');
      expectAr(madi(s, Voice.majhul).first, 'أُكْرِمَ');
      expectAr(amr(s).first, 'أَكْرِمْ');
    });

    test('التفعيل', () {
      final s = spec('علم', wazn: 'tafil');
      expectAr(madi(s).first, 'عَلَّمَ');
      expectAr(mudari(s).first, 'يُعَلِّمُ');
      expectAr(madi(s, Voice.majhul).first, 'عُلِّمَ');
    });

    test('الافتعال', () {
      final s = spec('كسب', wazn: 'iftial');
      expectAr(madi(s).first, 'اِكْتَسَبَ');
      expectAr(mudari(s).first, 'يَكْتَسِبُ');
    });

    test('فاء الافتعال: اتَّعَدَ واصْطَبَرَ وازْدَجَرَ', () {
      expectAr(madi(spec('وعد', wazn: 'iftial')).first, 'اِتَّعَدَ');
      expectAr(madi(spec('صبر', wazn: 'iftial')).first, 'اِصْطَبَرَ');
      expectAr(madi(spec('زجر', wazn: 'iftial')).first, 'اِزْدَجَرَ');
    });

    test('الاستفعال', () {
      final s = spec('خرج', wazn: 'istifal');
      expectAr(madi(s).first, 'اِسْتَخْرَجَ');
      expectAr(mudari(s).first, 'يَسْتَخْرِجُ');
    });

    test('الرباعي: دَحْرَجَ يُدَحْرِجُ', () {
      final s = VerbSpec(
        root: 'دحرج'.split(''),
        wazn: waznById('falala')!,
        type: SahihMutal.salim,
      );
      expectAr(madi(s).first, 'دَحْرَجَ');
      expectAr(mudari(s).first, 'يُدَحْرِجُ');
      expectAr(madi(s, Voice.majhul).first, 'دُحْرِجَ');
    });
  });

  group('نون التوكيد', () {
    final s = spec('نصر', babId: 'nasr');

    test('الثقيلة مع المفرد تفتح آخره', () {
      expectAr(
        buildMudari(s, Sigha.wahidMudhakkarGhaib, Voice.maalum,
                tawkid: Tawkid.thaqila)
            .text,
        'يَنْصُرَنَّ',
      );
    });

    test('واو الجماعة تُحذف ويبقى الضم دليلًا عليها', () {
      expectAr(
        buildMudari(s, Sigha.jamMudhakkarMukhatab, Voice.maalum,
                tawkid: Tawkid.thaqila)
            .text,
        'تَنْصُرُنَّ',
      );
    });

    test('الخفيفة لا تلحق ألفًا ولا نون نسوة', () {
      // شذا العرف page1_0047، وجداول إرشاد الصرف تُطبّقه: ۶ ← ۳ و ۸ ← ۵
      expectAr(Sigha.tathniyaMudhakkarGhaib.acceptsNunKhafifa, isFalse);
      expectAr(Sigha.jamMuannathGhaiba.acceptsNunKhafifa, isFalse);
      expectAr(Sigha.wahidMudhakkarGhaib.acceptsNunKhafifa, isTrue);
      expectAr(hadirSighas.where((g) => g.acceptsNunKhafifa).length, 3);
      expectAr(ghaibSighas.where((g) => g.acceptsNunKhafifa).length, 5);
    });
  });

  group('التحليل', () {
    test('يتعرف على المجرد والمزيد والمشتق', () {
      expectAr(analyze('ضرب').best.rootText, 'ض ر ب');
      expectAr(analyze('دحرج').best.wazn.id, 'falala');
      expectAr(analyze('اكتسب').best.wazn.id, 'iftial');
      expectAr(analyze('استخرج').best.wazn.id, 'istifal');
      expectAr(analyze('مكتسب').best.derived, DerivedKind.ismFail);
      expectAr(analyze('مضروب').best.derived, DerivedKind.ismMaful);
    });

    test('يرد الألف إلى أصلها في الأجوف والناقص', () {
      final q = analyze('قال').best;
      expectAr(q.rootText, 'ق و ل');
      expectAr(q.type, SahihMutal.ajwaf);
      expectAr(analyze('رمى').best.type, SahihMutal.naqis);
    });

    test('يفكّ الشدة: مدّ ← م د د', () {
      final m = analyze('مدّ').best;
      expectAr(m.rootText, 'م د د');
      expectAr(m.type, SahihMutal.mudaaf);
    });

    test('الأقسام السبعة', () {
      expectAr(classify('وعد'.split('')), SahihMutal.mithal);
      expectAr(classify('قول'.split('')), SahihMutal.ajwaf);
      expectAr(classify('غزو'.split('')), SahihMutal.naqis);
      expectAr(classify('مدد'.split('')), SahihMutal.mudaaf);
      expectAr(classify('ءخذ'.split('')), SahihMutal.mahmuzFa);
      expectAr(classify('سءل'.split('')), SahihMutal.mahmuzAyn);
      expectAr(classify('قرء'.split('')), SahihMutal.mahmuzLam);
      expectAr(classify('وقي'.split('')), SahihMutal.lafifMafruq);
      expectAr(classify('طوي'.split('')), SahihMutal.lafifMaqrun);
      expectAr(classify('نصر'.split('')), SahihMutal.salim);
    });

    test('الباب سماعي: ما في المعجم سماعي وما سواه مولَّد', () {
      expectAr(analyze('ضرب').best.babProvenance, Provenance.samai);
      expectAr(analyze('شغب').best.babProvenance, Provenance.muwallad);
    });
  });

  group('الجداول', () {
    final s = spec('ضرب', babId: 'darb');

    test('لكل قسم عدد صيغه الصحيح', () {
      final secs = sectionsFor(s);
      Map<String, int> counts = {
        for (final x in secs) x.id: x.build(s).length,
      };
      expectAr(counts['madi_maalum'], 14);
      expectAr(counts['amr_hadir'], 6);
      expectAr(counts['amr_ghaib'], 8);
      expectAr(counts['amr_hadir_khafifa'], 3);
      expectAr(counts['nahy_ghaib_khafifa'], 5);
      // The declared count and the built count must agree.
      for (final x in secs) {
        expectAr(x.build(s).length, x.sighas, reason: x.id);
      }
    });

    test('الصرف الصغير يبدأ بالمصدر وينتهي بالمشتقات', () {
      final line = canon(sarfSaghirLine(s));
      expectAr(line, contains(canon('ضَرْبٌ')));
      expectAr(line, contains(canon('ضَرَبَ')));
      expectAr(line, contains(canon('يَضْرِبُ')));
      expectAr(line, contains(canon('ضَارِبٌ')));
      expectAr(line, contains(canon('مَضْرُوبٌ')));
      expectAr(line, contains(canon('اِضْرِبْ')));
    });

    test('المشتقات: اسم الآلة على ثلاث درجات', () {
      final m = mushtaqqatFor(s).where((x) => x.kind == DerivedKind.ismAala);
      expectAr(m.length, 3);
      expectAr(m.map((x) => x.text), contains(canon('مِضْرَبٌ')));
      expectAr(m.map((x) => x.text), contains(canon('مِضْرَابٌ')));
    });

    test('ظرف الأجوف يُعَلُّ بالنقل: مَقْوَل ← مَقَال', () {
      // «الاسم المشبه للفعل المضارع وزنًا» — شذا العرف page1_0151
      final z = mushtaqqatFor(spec('قول', babId: 'nasr'))
          .firstWhere((x) => x.kind == DerivedKind.ismZarf);
      expectAr(z.text, 'مَقَالٌ');
      // مِفْعَل keeps its wāw: its kasra stops it resembling the muḍāriʿ.
      final a = mushtaqqatFor(spec('قول', babId: 'nasr'))
          .firstWhere((x) => x.arabicName.contains('الصُّغْرَى'));
      expectAr(a.text, 'مِقْوَلٌ');
    });

    test('اسم الفاعل من الأجوف تُقلب عينه همزة', () {
      final q = mushtaqqatFor(spec('قول', babId: 'nasr'))
          .firstWhere((x) => x.kind == DerivedKind.ismFail);
      expectAr(q.text, 'قَائِلٌ');
    });
  });

  group('لا يتعطل على أي مدخل', () {
    test('كل جذر من المعجم يبني كل جداوله', () {
      for (final key in lexicon.keys) {
        final a = analyze(key);
        expectAr(a.isEmpty, isFalse, reason: key);
        final sp = a.best.spec;
        for (final sec in sectionsFor(sp)) {
          final forms = sec.build(sp);
          expectAr(forms.length, sec.sighas, reason: '$key / ${sec.id}');
          for (final f in forms) {
            expectAr(f.text.trim(), isNotEmpty, reason: '$key / ${sec.id}');
          }
        }
        expectAr(sarfSaghir(sp), isNotEmpty, reason: key);
        expectAr(mushtaqqatFor(sp), isNotEmpty, reason: key);
      }
    });

    test('كل وزن مزيد يبني جداوله لجذر سالم', () {
      for (final w in allVerbAwzan) {
        final root = switch (w.rootLength) {
          4 => 'دحرج'.split(''),
          5 => 'جحمرش'.split(''),
          _ => 'ضرب'.split(''),
        };
        final sp = VerbSpec(root: root, wazn: w, type: SahihMutal.salim);
        for (final sec in sectionsFor(sp)) {
          for (final f in sec.build(sp)) {
            expectAr(f.text.trim(), isNotEmpty, reason: '${w.id} / ${sec.id}');
          }
        }
      }
    });

    test('المدخلات الفارغة والغريبة تُرَدُّ ولا تُقرأ جذورًا', () {
      for (final junk in ['', '   ', 'hello', '؟؟؟', '؟؟؟؟', '1234', 'ا', 'اا']) {
        expectAr(analyze(junk).isEmpty, isTrue, reason: junk);
      }
    });
  });
}
