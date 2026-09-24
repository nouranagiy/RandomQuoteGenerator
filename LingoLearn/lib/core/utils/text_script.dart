class TextScriptDetector {
  TextScriptDetector._();

  static final RegExp _arabicScript = RegExp(r'[\u0600-\u06FF]');
  static final RegExp _whitespace = RegExp(r'\s');

  static bool isArabic(String text) {
    final arabicChars = _arabicScript.allMatches(text).length;
    final nonSpaceChars = text.replaceAll(_whitespace, '').length;
    if (nonSpaceChars == 0) return false;
    return arabicChars / nonSpaceChars > 0.5;
  }

  static String languagePrefix(String text) => isArabic(text) ? 'ar' : 'en';
}
