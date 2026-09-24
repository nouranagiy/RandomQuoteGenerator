import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;
  late final Map<String, String> _strings;

  AppLocalizations(this.locale) {
    _strings = locale.languageCode == 'ar' ? _arStrings : _enStrings;
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String get(String key) => _strings[key] ?? key;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [Locale('en'), Locale('ar')];

  String get appName => get('appName');
  String get tagline => get('tagline');
  String get welcome => get('welcome');
  String get login => get('login');
  String get signUp => get('signUp');
  String get logout => get('logout');
  String get email => get('email');
  String get password => get('password');
  String get name => get('name');
  String get confirmPassword => get('confirmPassword');
  String get loginTitle => get('loginTitle');
  String get loginSubtitle => get('loginSubtitle');
  String get signUpTitle => get('signUpTitle');
  String get signUpSubtitle => get('signUpSubtitle');
  String get noAccount => get('noAccount');
  String get hasAccount => get('hasAccount');
  String get quizMode => get('quizMode');
  String get addFlashcard => get('addFlashcard');
  String get editFlashcard => get('editFlashcard');
  String get edit => get('edit');
  String get deleteFlashcard => get('deleteFlashcard');
  String get deleteConfirmation => get('deleteConfirmation');
  String get cancel => get('cancel');
  String get delete => get('delete');
  String get save => get('save');
  String get question => get('question');
  String get answer => get('answer');
  String get category => get('category');
  String get previous => get('previous');
  String get next => get('next');
  String get card => get('card');
  String get cards => get('cards');
  String get createNewFlashcard => get('createNewFlashcard');
  String get updateFlashcard => get('updateFlashcard');
  String get enterQuestion => get('enterQuestion');
  String get enterAnswer => get('enterAnswer');
  String get questionRequired => get('questionRequired');
  String get answerRequired => get('answerRequired');
  String get nameRequired => get('nameRequired');
  String get emailRequired => get('emailRequired');
  String get passwordRequired => get('passwordRequired');
  String get passwordTooShort => get('passwordTooShort');
  String get passwordsDoNotMatch => get('passwordsDoNotMatch');
  String get invalidEmail => get('invalidEmail');
  String get networkError => get('networkError');
  String get genericError => get('genericError');
  String get loading => get('loading');
  String get showAnswer => get('showAnswer');
  String get questionLabel => get('questionLabel');
  String get answerLabel => get('answerLabel');
  String get noFlashcardsYet => get('noFlashcardsYet');
  String get noFlashcardsDescription => get('noFlashcardsDescription');
  String get addFirstFlashcard => get('addFirstFlashcard');
  String get noFlashcardsInCategory => get('noFlashcardsInCategory');
  String get tryAnotherCategory => get('tryAnotherCategory');
  String get quizCompleted => get('quizCompleted');
  String get correctOutOf => get('correctOutOf');
  String get tryAgain => get('tryAgain');
  String get backToFlashcards => get('backToFlashcards');
  String get correct => get('correct');
  String get wrongAnswer => get('wrongAnswer');
  String get finishQuiz => get('finishQuiz');
  String get nextQuestion => get('nextQuestion');
  String get settings => get('settings');
  String get language => get('language');
  String get theme => get('theme');
  String get lightMode => get('lightMode');
  String get darkMode => get('darkMode');
  String get systemDefault => get('systemDefault');
  String get english => get('english');
  String get arabic => get('arabic');
  String get onboarding1Title => get('onboarding1Title');
  String get onboarding1Desc => get('onboarding1Desc');
  String get onboarding2Title => get('onboarding2Title');
  String get onboarding2Desc => get('onboarding2Desc');
  String get onboarding3Title => get('onboarding3Title');
  String get onboarding3Desc => get('onboarding3Desc');
  String get getStarted => get('getStarted');
  String get skip => get('skip');
  String get next_ => get('next_');
  String get userDefaultFallback => get('userDefaultFallback');
  String get firestorePermissionDenied => get('firestorePermissionDenied');
  String get firestoreUnavailable => get('firestoreUnavailable');
  String get notFound => get('notFound');
  String get alreadyExists => get('alreadyExists');

  static const Map<String, String> _enStrings = {
    'appName': 'Flashcard Quiz',
    'tagline': 'Learn Without Limits',
    'welcome': 'Welcome',
    'login': 'Login',
    'signUp': 'Sign Up',
    'logout': 'Logout',
    'email': 'Email',
    'password': 'Password',
    'name': 'Name',
    'confirmPassword': 'Confirm Password',
    'loginTitle': 'Welcome Back',
    'loginSubtitle': 'Sign in to continue learning',
    'signUpTitle': 'Create Account',
    'signUpSubtitle': 'Start your learning journey',
    'noAccount': "Don't have an account?",
    'hasAccount': 'Already have an account?',
    'quizMode': 'Quiz Mode',
    'addFlashcard': 'Add Flashcard',
    'editFlashcard': 'Edit Flashcard',
    'edit': 'Edit',
    'deleteFlashcard': 'Delete Flashcard',
    'deleteConfirmation': 'Are you sure you want to delete this flashcard?',
    'cancel': 'Cancel',
    'delete': 'Delete',
    'save': 'Save',
    'question': 'Question',
    'answer': 'Answer',
    'category': 'Category',
    'previous': 'Previous',
    'next': 'Next',
    'card': 'Card',
    'cards': 'Cards',
    'createNewFlashcard': 'Create a new flashcard',
    'updateFlashcard': 'Update Flashcard',
    'enterQuestion': 'Enter the question',
    'enterAnswer': 'Enter the answer',
    'questionRequired': 'Please enter a question',
    'answerRequired': 'Please enter an answer',
    'nameRequired': 'Please enter your name',
    'emailRequired': 'Please enter your email',
    'passwordRequired': 'Please enter your password',
    'passwordTooShort': 'Password must be at least 6 characters',
    'passwordsDoNotMatch': 'Passwords do not match',
    'invalidEmail': 'Please enter a valid email',
    'emailAlreadyInUse': 'This email is already registered',
    'wrongPassword': 'Wrong password',
    'userNotFound': 'No account found with this email',
    'weakPassword': 'Password is too weak',
    'networkError': 'Network error. Please check your connection.',
    'genericError': 'Something went wrong. Please try again.',
    'loading': 'Loading...',
    'showAnswer': 'Show Answer',
    'questionLabel': 'QUESTION',
    'answerLabel': 'ANSWER',
    'noFlashcardsYet': 'No Flashcards Yet',
    'noFlashcardsDescription':
        'Create your first flashcard and start learning.',
    'addFirstFlashcard': 'Add Your First Flashcard',
    'noFlashcardsInCategory': 'No Flashcards in This Category',
    'tryAnotherCategory': 'Try another category or add a new flashcard.',
    'quizCompleted': 'Quiz Completed!',
    'correctOutOf': 'correct out of',
    'tryAgain': 'Try Again',
    'backToFlashcards': 'Back to Flashcards',
    'correct': 'Correct!',
    'wrongAnswer': 'Wrong answer',
    'finishQuiz': 'Finish Quiz',
    'nextQuestion': 'Next Question',
    'settings': 'Settings',
    'language': 'Language',
    'theme': 'Theme',
    'lightMode': 'Light Mode',
    'darkMode': 'Dark Mode',
    'systemDefault': 'System Default',
    'english': 'English',
    'arabic': 'Arabic',
    'onboarding1Title': 'Create Flashcards',
    'onboarding1Desc': 'Easily create and organize flashcards for any subject.',
    'onboarding2Title': 'Quiz Yourself',
    'onboarding2Desc': 'Test your knowledge with interactive quizzes.',
    'onboarding3Title': 'Track Progress',
    'onboarding3Desc': 'Monitor your learning progress and master any topic.',
    'getStarted': 'Get Started',
    'skip': 'Skip',
    'next_': 'Next',
    'userDefaultFallback': 'User',
    'firestorePermissionDenied':
        'You do not have permission to access this data.',
    'firestoreUnavailable':
        'Firebase service is temporarily unavailable. Please try again.',
    'notFound': 'The requested data was not found.',
    'alreadyExists': 'This item already exists.',
  };

  static const Map<String, String> _arStrings = {
    'appName': 'Flashcard Quiz',
    'tagline': 'تعلّم بلا حدود',
    'welcome': 'مرحباً',
    'login': 'تسجيل الدخول',
    'signUp': 'إنشاء حساب',
    'logout': 'تسجيل الخروج',
    'email': 'البريد الإلكتروني',
    'password': 'كلمة المرور',
    'name': 'الاسم',
    'confirmPassword': 'تأكيد كلمة المرور',
    'loginTitle': 'مرحباً بعودتك',
    'loginSubtitle': 'سجّل الدخول للمتابعة',
    'signUpTitle': 'إنشاء حساب',
    'signUpSubtitle': 'ابدأ رحلة التعلم',
    'noAccount': 'ليس لديك حساب؟',
    'hasAccount': 'لديك حساب بالفعل؟',
    'quizMode': 'وضع الاختبار',
    'addFlashcard': 'إضافة بطاقة',
    'editFlashcard': 'تعديل البطاقة',
    'edit': 'تعديل',
    'deleteFlashcard': 'حذف البطاقة',
    'deleteConfirmation': 'هل أنت متأكد من حذف هذه البطاقة؟',
    'cancel': 'إلغاء',
    'delete': 'حذف',
    'save': 'حفظ',
    'question': 'السؤال',
    'answer': 'الإجابة',
    'category': 'الفئة',
    'previous': 'السابق',
    'next': 'التالي',
    'card': 'بطاقة',
    'cards': 'بطاقات',
    'createNewFlashcard': 'إنشاء بطاقة جديدة',
    'updateFlashcard': 'تحديث البطاقة',
    'enterQuestion': 'أدخل السؤال',
    'enterAnswer': 'أدخل الإجابة',
    'questionRequired': 'يرجى إدخال السؤال',
    'answerRequired': 'يرجى إدخال الإجابة',
    'nameRequired': 'يرجى إدخال اسمك',
    'emailRequired': 'يرجى إدخال بريدك الإلكتروني',
    'passwordRequired': 'يرجى إدخال كلمة المرور',
    'passwordTooShort': 'يجب أن تكون كلمة المرور 6 أحرف على الأقل',
    'passwordsDoNotMatch': 'كلمتا المرور غير متطابقتين',
    'invalidEmail': 'يرجى إدخال بريد إلكتروني صالح',
    'emailAlreadyInUse': 'هذا البريد الإلكتروني مسجل بالفعل',
    'wrongPassword': 'كلمة المرور خاطئة',
    'userNotFound': 'لا يوجد حساب بهذا البريد الإلكتروني',
    'weakPassword': 'كلمة المرور ضعيفة جداً',
    'networkError': 'خطأ في الشبكة. يرجى التحقق من اتصالك.',
    'genericError': 'حدث خطأ. يرجى المحاولة مرة أخرى.',
    'loading': 'جاري التحميل...',
    'showAnswer': 'إظهار الإجابة',
    'questionLabel': 'السؤال',
    'answerLabel': 'الإجابة',
    'noFlashcardsYet': 'لا توجد بطاقات بعد',
    'noFlashcardsDescription': 'أنشئ أول بطاقة تعليمية وابدأ التعلم.',
    'addFirstFlashcard': 'أضف أول بطاقة تعليمية',
    'noFlashcardsInCategory': 'لا توجد بطاقات في هذه الفئة',
    'tryAnotherCategory': 'جرّب فئة أخرى أو أضف بطاقة جديدة.',
    'quizCompleted': 'اكتمل الاختبار!',
    'correctOutOf': 'صحيح من أصل',
    'tryAgain': 'حاول مرة أخرى',
    'backToFlashcards': 'العودة للبطاقات',
    'correct': 'صحيح!',
    'wrongAnswer': 'إجابة خاطئة',
    'finishQuiz': 'إنهاء الاختبار',
    'nextQuestion': 'السؤال التالي',
    'settings': 'الإعدادات',
    'language': 'اللغة',
    'theme': 'المظهر',
    'lightMode': 'الوضع الفاتح',
    'darkMode': 'الوضع الداكن',
    'systemDefault': 'الإعداد الافتراضي',
    'english': 'الإنجليزية',
    'arabic': 'العربية',
    'onboarding1Title': 'أنشئ البطاقات',
    'onboarding1Desc': 'أنشئ ونظّم البطاقات التعليمية لأي موضوع بسهولة.',
    'onboarding2Title': 'اختبر نفسك',
    'onboarding2Desc': 'اختبر معلوماتك باختبارات تفاعلية.',
    'onboarding3Title': 'تتبع التقدم',
    'onboarding3Desc': 'تابع تقدمك في التعلم وأتقن أي موضوع.',
    'getStarted': 'ابدأ الآن',
    'skip': 'تخطي',
    'next_': 'التالي',
    'userDefaultFallback': 'مستخدم',
    'firestorePermissionDenied': 'ليس لديك صلاحية للوصول إلى هذه البيانات.',
    'firestoreUnavailable':
        'خدمة Firebase غير متاحة حالياً. يرجى المحاولة لاحقاً.',
    'notFound': 'البيانات المطلوبة غير موجودة.',
    'alreadyExists': 'هذا العنصر موجود بالفعل.',
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) {
    return false;
  }
}
