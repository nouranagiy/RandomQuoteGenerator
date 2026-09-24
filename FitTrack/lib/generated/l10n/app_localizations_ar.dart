// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'FitTrack';

  @override
  String welcome(String name) {
    return 'مرحباً، $name 👋';
  }

  @override
  String get welcomeFallback => 'مرحباً 👋';

  @override
  String get profileLoadError => 'تعذر تحميل ملفك الشخصي.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get login => 'تسجيل الدخول';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get password => 'كلمة المرور';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get name => 'الاسم';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get loginSubtitle => 'سجّل الدخول للمتابعة';

  @override
  String get signUpSubtitle => 'أنشئ حسابك';

  @override
  String get noAccount => 'ليس لديك حساب؟';

  @override
  String get hasAccount => 'لديك حساب بالفعل؟';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get continueWith => 'أو تابع بـ';

  @override
  String get emailHint => 'أدخل بريدك الإلكتروني';

  @override
  String get passwordHint => 'أدخل كلمة المرور';

  @override
  String get confirmPasswordHint => 'أكد كلمة المرور';

  @override
  String get nameHint => 'أدخل اسمك';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get signingIn => 'جارٍ تسجيل الدخول...';

  @override
  String get creatingAccount => 'جارٍ إنشاء الحساب...';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get signOutConfirm => 'هل أنت متأكد من تسجيل الخروج؟';

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String get passwordResetSent =>
      'تم إرسال رابط إعادة تعيين كلمة المرور. تحقق من بريدك.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get confirm => 'تأكيد';

  @override
  String get delete => 'حذف';

  @override
  String get save => 'حفظ';

  @override
  String get today => 'اليوم';

  @override
  String get keepMoving => 'استمر في الحركة وحقق أهدافك!';

  @override
  String get steps => 'الخطوات';

  @override
  String get calories => 'السعرات';

  @override
  String get workout => 'التمرين';

  @override
  String get activities => 'الأنشطة';

  @override
  String goal(String value) {
    return 'الهدف: $value';
  }

  @override
  String get kcal => 'سعرة';

  @override
  String get minutes => 'دقائق';

  @override
  String get todayLabel => 'اليوم';

  @override
  String get dailyProgress => 'التقدم اليومي';

  @override
  String get activityDetection => 'كشف النشاط';

  @override
  String get detectingActivity => 'جارٍ كشف النشاط...';

  @override
  String get estimatedFromDevice => 'تقدير من حركة الجهاز';

  @override
  String get stepsTitle => 'الخطوات';

  @override
  String get caloriesTitle => 'السعرات';

  @override
  String get stepCounterUnavailable => 'عداد الخطوات غير متاح على هذا الجهاز.';

  @override
  String get workoutTime => 'وقت التمرين';

  @override
  String get min => 'دقيقة';

  @override
  String get addActivity => 'إضافة نشاط';

  @override
  String get weeklyProgress => 'التقدم الأسبوعي';

  @override
  String get last7Days => 'آخر 7 أيام';

  @override
  String get trackConsistent => 'تتبع نشاطك وكن بشكل مستمر.';

  @override
  String get workoutTimeTitle => 'وقت التمرين';

  @override
  String get dailySteps => 'الخطوات اليومية';

  @override
  String get dailySummary => 'الملخص اليومي';

  @override
  String get activityHistory => 'سجل الأنشطة';

  @override
  String get noActivities => 'لا توجد أنشطة بعد';

  @override
  String get noActivitiesDesc => 'ابدأ بتتبع أنشاطك وسيظهر هنا.';

  @override
  String get addActivityTitle => 'إضافة نشاط';

  @override
  String get logYourActivity => 'سجّل نشاطك';

  @override
  String get addWorkoutDetails => 'أضف تفاصيل تمرينك لتتبع تقدمك.';

  @override
  String get automaticTracking => 'التتبع التلقائي';

  @override
  String get automaticTrackingDesc =>
      'تتبع نشاطك تلقائياً باستخدام مستشعرات جهازك.';

  @override
  String get exerciseType => 'نوع التمرين';

  @override
  String get workoutDuration => 'مدة التمرين';

  @override
  String get caloriesBurned => 'السعرات المحروقة';

  @override
  String get stepsLabel => 'الخطوات';

  @override
  String get duration => 'المدة';

  @override
  String get editActivity => 'تعديل النشاط';

  @override
  String get updateActivity => 'تحديث النشاط';

  @override
  String get changeDetails => 'غيّر تفاصيل نشاطك واحفظ التحديثات.';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get saveActivity => 'حفظ النشاط';

  @override
  String get saveActivityError => 'تعذر حفظ نشاطك';

  @override
  String get deleteActivity => 'حذف النشاط';

  @override
  String get deleteActivityConfirm => 'هل أنت متأكد من حذف هذا النشاط؟';

  @override
  String get edit => 'تعديل';

  @override
  String get walking => 'مشي';

  @override
  String get running => 'ركض';

  @override
  String get cycling => 'دراجة';

  @override
  String get gym => 'صالة رياضية';

  @override
  String get swimming => 'سباحة';

  @override
  String get yoga => 'يوغا';

  @override
  String get still => 'ثابت';

  @override
  String get other => 'أخرى';

  @override
  String get durationHint => 'مثال: 30';

  @override
  String get caloriesHint => 'مثال: 250';

  @override
  String get stepsHint => 'مثال: 3000';

  @override
  String get lightMode => 'الوضع الفاتح';

  @override
  String get darkMode => 'الوضع الداكن';

  @override
  String get systemDefault => 'الإعداد الافتراضي للنظام';

  @override
  String get settings => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get theme => 'المظهر';

  @override
  String get english => 'الإنجليزية';

  @override
  String get arabic => 'العربية';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get errorEmailInUse => 'هذا البريد الإلكتروني مستخدم بالفعل.';

  @override
  String get errorInvalidEmail => 'عنوان البريد الإلكتروني غير صالح.';

  @override
  String get errorWrongPassword => 'كلمة المرور خاطئة.';

  @override
  String get errorUserNotFound =>
      'لم يتم العثور على حساب بهذا البريد الإلكتروني.';

  @override
  String get errorWeakPassword => 'كلمة المرور ضعيفة جداً.';

  @override
  String get errorNetwork => 'خطأ في الشبكة. تحقق من اتصالك.';

  @override
  String get errorGeneric => 'حدث خطأ. حاول مرة أخرى.';

  @override
  String get errorNameRequired => 'الرجاء إدخال اسمك.';

  @override
  String get errorEmailRequired => 'الرجاء إدخال بريدك الإلكتروني.';

  @override
  String get errorPasswordRequired => 'الرجاء إدخال كلمة المرور.';

  @override
  String get errorPasswordMismatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get errorInvalidNumber => 'الرجاء إدخال رقم صحيح.';

  @override
  String get errorFieldRequired => 'هذا الحقل مطلوب.';

  @override
  String get loading => 'جارٍ التحميل...';

  @override
  String get signedInAs => 'تم تسجيل الدخول بحساب';

  @override
  String get mon => 'الإثنين';

  @override
  String get tue => 'الثلاثاء';

  @override
  String get wed => 'الأربعاء';

  @override
  String get thu => 'الخميس';

  @override
  String get fri => 'الجمعة';

  @override
  String get sat => 'السبت';

  @override
  String get sun => 'الأحد';

  @override
  String get skip => 'تخطي';

  @override
  String get next => 'التالي';

  @override
  String get abtCalories => 'تتبع السعرات المحروقة والتزم بأهداف لياقتك.';

  @override
  String get abtProgress => 'شاهد تقدمك اليومي والأسبوعي في نظرة واحدة.';

  @override
  String get appTagline => 'تتبع رحلة لياقتك';
}
