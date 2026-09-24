// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'FitTrack';

  @override
  String welcome(String name) {
    return 'Welcome, $name 👋';
  }

  @override
  String get welcomeFallback => 'Welcome 👋';

  @override
  String get profileLoadError => 'Couldn\'t load your profile.';

  @override
  String get retry => 'Retry';

  @override
  String get login => 'Login';

  @override
  String get signUp => 'Sign Up';

  @override
  String get logout => 'Logout';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get name => 'Name';

  @override
  String get fullName => 'Full Name';

  @override
  String get loginSubtitle => 'Sign in to continue';

  @override
  String get signUpSubtitle => 'Create your account';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get hasAccount => 'Already have an account?';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get continueWith => 'Or continue with';

  @override
  String get emailHint => 'Enter your email';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get confirmPasswordHint => 'Confirm your password';

  @override
  String get nameHint => 'Enter your name';

  @override
  String get createAccount => 'Create Account';

  @override
  String get signIn => 'Sign In';

  @override
  String get signingIn => 'Signing in...';

  @override
  String get creatingAccount => 'Creating account...';

  @override
  String get signOut => 'Sign Out';

  @override
  String get signOutConfirm => 'Are you sure you want to sign out?';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get passwordResetSent =>
      'Password reset email sent. Check your inbox.';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get delete => 'Delete';

  @override
  String get save => 'Save';

  @override
  String get today => 'Today';

  @override
  String get keepMoving => 'Keep moving and reach your goals!';

  @override
  String get steps => 'Steps';

  @override
  String get calories => 'Calories';

  @override
  String get workout => 'Workout';

  @override
  String get activities => 'Activities';

  @override
  String goal(String value) {
    return 'Goal: $value';
  }

  @override
  String get kcal => 'kcal';

  @override
  String get minutes => 'Minutes';

  @override
  String get todayLabel => 'Today';

  @override
  String get dailyProgress => 'Daily Progress';

  @override
  String get activityDetection => 'Activity Detection';

  @override
  String get detectingActivity => 'Detecting activity...';

  @override
  String get estimatedFromDevice => 'Estimated from device movement';

  @override
  String get stepsTitle => 'Steps';

  @override
  String get caloriesTitle => 'Calories';

  @override
  String get stepCounterUnavailable =>
      'Step counter unavailable on this device.';

  @override
  String get workoutTime => 'Workout Time';

  @override
  String get min => 'min';

  @override
  String get addActivity => 'Add Activity';

  @override
  String get weeklyProgress => 'Weekly Progress';

  @override
  String get last7Days => 'Last 7 Days';

  @override
  String get trackConsistent => 'Track your activity and stay consistent.';

  @override
  String get workoutTimeTitle => 'Workout Time';

  @override
  String get dailySteps => 'Daily Steps';

  @override
  String get dailySummary => 'Daily Summary';

  @override
  String get activityHistory => 'Activity History';

  @override
  String get noActivities => 'No Activities Yet';

  @override
  String get noActivitiesDesc =>
      'Start tracking your activities and they will appear here.';

  @override
  String get addActivityTitle => 'Add Activity';

  @override
  String get logYourActivity => 'Log Your Activity';

  @override
  String get addWorkoutDetails =>
      'Add your workout details to track your progress.';

  @override
  String get automaticTracking => 'Automatic Tracking';

  @override
  String get automaticTrackingDesc =>
      'Track your activity automatically using your device sensors.';

  @override
  String get exerciseType => 'Exercise Type';

  @override
  String get workoutDuration => 'Workout Duration';

  @override
  String get caloriesBurned => 'Calories Burned';

  @override
  String get stepsLabel => 'Steps';

  @override
  String get duration => 'Duration';

  @override
  String get editActivity => 'Edit Activity';

  @override
  String get updateActivity => 'Update Activity';

  @override
  String get changeDetails =>
      'Change your activity details and save the updates.';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get saveActivity => 'Save Activity';

  @override
  String get saveActivityError => 'Could not save your activity';

  @override
  String get deleteActivity => 'Delete Activity';

  @override
  String get deleteActivityConfirm =>
      'Are you sure you want to delete this activity?';

  @override
  String get edit => 'Edit';

  @override
  String get walking => 'Walking';

  @override
  String get running => 'Running';

  @override
  String get cycling => 'Cycling';

  @override
  String get gym => 'Gym';

  @override
  String get swimming => 'Swimming';

  @override
  String get yoga => 'Yoga';

  @override
  String get still => 'Still';

  @override
  String get other => 'Other';

  @override
  String get durationHint => 'e.g. 30';

  @override
  String get caloriesHint => 'e.g. 250';

  @override
  String get stepsHint => 'e.g. 3000';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get systemDefault => 'System Default';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get profile => 'Profile';

  @override
  String get errorEmailInUse => 'This email is already in use.';

  @override
  String get errorInvalidEmail => 'Invalid email address.';

  @override
  String get errorWrongPassword => 'Wrong password.';

  @override
  String get errorUserNotFound => 'No account found with this email.';

  @override
  String get errorWeakPassword => 'Password is too weak.';

  @override
  String get errorNetwork => 'Network error. Please check your connection.';

  @override
  String get errorGeneric => 'An error occurred. Please try again.';

  @override
  String get errorNameRequired => 'Please enter your name.';

  @override
  String get errorEmailRequired => 'Please enter your email.';

  @override
  String get errorPasswordRequired => 'Please enter your password.';

  @override
  String get errorPasswordMismatch => 'Passwords do not match.';

  @override
  String get errorInvalidNumber => 'Please enter a valid number.';

  @override
  String get errorFieldRequired => 'This field is required.';

  @override
  String get loading => 'Loading...';

  @override
  String get signedInAs => 'Signed in as';

  @override
  String get mon => 'Mon';

  @override
  String get tue => 'Tue';

  @override
  String get wed => 'Wed';

  @override
  String get thu => 'Thu';

  @override
  String get fri => 'Fri';

  @override
  String get sat => 'Sat';

  @override
  String get sun => 'Sun';

  @override
  String get skip => 'Skip';

  @override
  String get next => 'Next';

  @override
  String get abtCalories =>
      'Track calories burned and stay on budget with your fitness goals.';

  @override
  String get abtProgress => 'See your daily and weekly progress at a glance.';

  @override
  String get appTagline => 'Track your fitness journey';
}
