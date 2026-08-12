/// The four languages the app speaks. Kept inside `sarf/` because the rule
/// explanations — which are domain content, not UI chrome — are translated
/// alongside the rules themselves.
library;

enum Lang { ps, fa, ar, en }

extension LangInfo on Lang {
  String get code => name;

  /// Endonym, shown in the language picker.
  String get nativeName => switch (this) {
        Lang.ps => 'پښتو',
        Lang.fa => 'فارسی',
        Lang.ar => 'العربية',
        Lang.en => 'English',
      };

  bool get isRtl => this != Lang.en;
}

/// A string that exists in all four languages. Domain text (rule names,
/// taʿlīl, ṣīgha meanings) is carried in these rather than in the UI's
/// string table, so a rule and its explanation never drift apart.
class L4 {
  const L4(this.ps, this.fa, this.ar, this.en);

  final String ps;
  final String fa;
  final String ar;
  final String en;

  String call(Lang l) => switch (l) {
        Lang.ps => ps,
        Lang.fa => fa,
        Lang.ar => ar,
        Lang.en => en,
      };
}
