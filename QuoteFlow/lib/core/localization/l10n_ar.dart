import 'package:quoteflow/core/localization/l10n.dart';
import 'package:quoteflow/core/utils/auth_error_handler.dart';

class L10nAr extends L10n {
  @override
  String get appTitle => 'كووت فلو';
  @override
  String get inspireYourDay => 'مساحة هادئة لأفكار أفضل.';
  @override
  String greeting(String name) => 'مرحباً، $name';
  @override
  String get dailyInspiration => 'إلهام اليوم';

  static const _quoteBodies = {
    'q1': 'الطريقة الوحيدة لعمل عمل عظيم هي أن تحبه.',
    'q2': 'النجاح ليس نهائيًا، والفشل ليس مميتًا.',
    'q3': 'آمن بأنك تستطيع وأنت في منتصف الطريق.',
    'q4': 'يبدو الأمر مستحيلاً حتى يتم إنجازه.',
    'q5': 'المستقبل يعتمد على ما تفعله اليوم.',
    'q6': 'لا تنظر إلى الساعة؛ افعل ما تفعله. استمر.',
    'q7': 'كل ما تتخيله حقيقي.',
    'q8': 'ابدأ من حيث أنت. استخدم ما لديك. افعل ما تستطيع.',
    'q9': 'حلم كبير وتجرأ على الفشل.',
    'q10': 'العظيمة تُنجز بسلسلة من الأشياء الصغيرة مجتمعة.',
  };

  static const _quoteAuthors = {
    'q1': 'Steve Jobs',
    'q2': 'Winston Churchill',
    'q3': 'Theodore Roosevelt',
    'q4': 'Nelson Mandela',
    'q5': 'Mahatma Gandhi',
    'q6': 'Sam Levenson',
    'q7': 'Pablo Picasso',
    'q8': 'Arthur Ashe',
    'q9': 'Norman Vaughan',
    'q10': 'Vincent van Gogh',
  };

  @override
  String quoteAttribution(String author) => '— $author';

  @override
  String quoteBody(String id) => _quoteBodies[id] ?? '';

  @override
  String quoteAuthor(String id) => _quoteAuthors[id] ?? 'Unknown';
  @override
  String get saved => 'محفوظ';
  @override
  String get login => 'تسجيل الدخول';
  @override
  String get signUp => 'إنشاء حساب';
  @override
  String get email => 'البريد الإلكتروني';
  @override
  String get password => 'كلمة المرور';
  @override
  String get name => 'الاسم';
  @override
  String get confirmPassword => 'تأكيد كلمة المرور';
  @override
  String get noAccount => 'ليس لديك حساب؟';
  @override
  String get hasAccount => 'لديك حساب بالفعل؟';
  @override
  String get logout => 'تسجيل الخروج';
  @override
  String get logoutConfirmation => 'هل تريد تسجيل الخروج؟';
  @override
  String get cancel => 'إلغاء';
  @override
  String get confirm => 'تأكيد';
  @override
  String get settings => 'الإعدادات';
  @override
  String get settingsSubtitle => 'اجعل كووت فلو أقرب إلى طريقتك في القراءة.';
  @override
  String get language => 'اللغة';
  @override
  String get languageSubtitle => 'اختر اللغة المستخدمة في جميع شاشات التطبيق.';
  @override
  String get theme => 'المظهر';
  @override
  String get appearanceSubtitle =>
      'اتّبع إعداد جهازك أو اختر الأجواء المناسبة لك.';
  @override
  String get darkMode => 'الوضع الداكن';
  @override
  String get lightMode => 'الوضع الفاتح';
  @override
  String get systemDefault => 'إعداد النظام';
  @override
  String get english => 'الإنجليزية';
  @override
  String get arabic => 'العربية';
  @override
  String get favorites => 'المفضلة';
  @override
  String get favoritesSubtitle => 'اقتباساتك المحفوظة في مكان واحد.';
  @override
  String get noFavorites => 'لا توجد مفضلات بعد';
  @override
  String get noFavoritesDescription =>
      'احفظ الاقتباسات التي تهمك وارجع إليها في أي وقت.';
  @override
  String favoritesCount(int count) =>
      'تم حفظ $count ${count == 1 ? 'اقتباس' : 'اقتباسات'}';
  @override
  String get newQuote => 'اقتباس جديد';
  @override
  String get copyQuote => 'نسخ الاقتباس';
  @override
  String get quoteCopied => 'تم نسخ الاقتباس';
  @override
  String get copyToClipboard => 'نسخ إلى الحافظة';
  @override
  String get error => 'خطأ';
  @override
  String get addToFavorites => 'إضافة إلى المفضلة';
  @override
  String get removeFromFavorites => 'إزالة من المفضلة';
  @override
  String get next => 'التالي';
  @override
  String get skip => 'تخطي';
  @override
  String get done => 'تم';
  @override
  String get onboardingTitle1 => 'اكتشف منظوراً جديداً';
  @override
  String get onboardingDesc1 =>
      'استكشف أفكاراً خالدة تمنح وضوحاً أكثر للحظات اليومية.';
  @override
  String get onboardingTitle2 => 'احتفظ بما يلهمك';
  @override
  String get onboardingDesc2 =>
      'احفظ الأقوال المؤثرة وابنِ مجموعة شخصية ترجع إليها كلما احتجت.';
  @override
  String get onboardingTitle3 => 'شارك الإلهام';
  @override
  String get onboardingDesc3 =>
      'انسخ فكرة بضغطة واحدة وشارك طاقتها الإيجابية مع شخص آخر.';
  @override
  String get profile => 'الملف الشخصي';
  @override
  String get about => 'حول التطبيق';
  @override
  String get aboutSubtitle => 'رفيق بسيط للاقتباسات الهادئة.';
  @override
  String get version => 'الإصدار';
  @override
  String get removeFavorite => 'إزالة من المفضلة';
  @override
  String get removeFavoriteTitle => 'إزالة هذا الاقتباس؟';
  @override
  String removeFavoriteConfirmation(String quote) =>
      'سيُزال هذا الاقتباس من مجموعتك:\n\n“$quote”';
  @override
  String get signInToSaveFavorites =>
      'سجّل الدخول لحفظ هذا الاقتباس في مفضلتك.';
  @override
  String get failedToSaveFavorite => 'تعذّر تحديث المفضلة. حاول مرة أخرى.';
  @override
  String get favoritesLoadError => 'تعذّر تحميل المفضلة. حاول مرة أخرى.';
  @override
  String get signOut => 'تسجيل الخروج';
  @override
  String get signOutFailed => 'تعذّر تسجيل الخروج. حاول مرة أخرى.';
  @override
  String get signUpSubtitle => 'أنشئ حسابك وابدأ مجموعتك الخاصة.';
  @override
  String get loginSubtitle => 'مرحباً بعودتك. سجّل الدخول للمتابعة.';
  @override
  String get nameHint => 'أدخل اسمك الكامل';
  @override
  String get emailHint => 'أدخل بريدك الإلكتروني';
  @override
  String get passwordHint => 'أدخل كلمة المرور';
  @override
  String get confirmPasswordHint => 'أكد كلمة المرور';
  @override
  String get showPassword => 'إظهار كلمة المرور';
  @override
  String get hidePassword => 'إخفاء كلمة المرور';
  @override
  String get passwordRequired => 'كلمة المرور مطلوبة';
  @override
  String get emailRequired => 'البريد الإلكتروني مطلوب';
  @override
  String get nameRequired => 'الاسم مطلوب';
  @override
  String get invalidEmail => 'أدخل بريداً إلكترونياً صالحاً';
  @override
  String get passwordMinLength => 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';
  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين';
  @override
  String get unexpectedError => 'حدث خطأ ما. حاول مرة أخرى.';
  @override
  String get preferenceSaveError => 'تعذّر حفظ هذا الإعداد على هذا الجهاز.';
  @override
  String get startupError => 'تعذّر تشغيل كووت فلو';
  @override
  String get startupErrorDescription =>
      'تحقق من اتصالك ثم أعد تشغيل التطبيق للمحاولة مرة أخرى.';
  @override
  String get guest => 'ضيف';
  @override
  String get loading => 'جاري التحميل…';
  @override
  String get retry => 'حاول مرة أخرى';
  @override
  String authError(AuthErrorCode code) {
    return switch (code) {
      AuthErrorCode.emailAlreadyInUse =>
        'هذا البريد مسجل بالفعل. سجّل الدخول بدلاً من ذلك.',
      AuthErrorCode.invalidEmail => 'أدخل بريداً إلكترونياً صالحاً.',
      AuthErrorCode.userNotFound => 'لا يوجد حساب بهذا البريد الإلكتروني.',
      AuthErrorCode.wrongPassword => 'كلمة المرور غير صحيحة.',
      AuthErrorCode.weakPassword => 'اختر كلمة مرور أقوى.',
      AuthErrorCode.networkRequestFailed =>
        'تحقق من اتصالك بالإنترنت وحاول مرة أخرى.',
      AuthErrorCode.tooManyRequests => 'محاولات كثيرة. حاول لاحقاً.',
      AuthErrorCode.operationNotAllowed => 'طريقة تسجيل الدخول هذه غير متاحة.',
      AuthErrorCode.userDisabled => 'تم تعطيل هذا الحساب.',
      AuthErrorCode.invalidCredential =>
        'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
      AuthErrorCode.requiresRecentLogin => 'سجّل الدخول مرة أخرى للمتابعة.',
      AuthErrorCode.accountExistsWithDifferentCredential =>
        'يوجد حساب مسجل بطريقة دخول أخرى.',
      AuthErrorCode.signUpSetupFailed =>
        'تعذّر إنشاء الحساب بالكامل. لم يتم حفظ أي حساب.',
      AuthErrorCode.signUpCleanupFailed =>
        'اكتمل إعداد الحساب جزئياً. تواصل مع الدعم قبل المحاولة مجدداً.',
      AuthErrorCode.signOutFailed => 'تعذّر تسجيل الخروج. حاول مرة أخرى.',
      AuthErrorCode.notInitialized =>
        'لا يزال التطبيق قيد التشغيل. حاول مجدداً.',
      AuthErrorCode.unknown => 'حدث خطأ ما. حاول مرة أخرى.',
    };
  }
}
