import 'package:quoteflow/core/localization/l10n.dart';
import 'package:quoteflow/core/utils/auth_error_handler.dart';

class L10nEn extends L10n {
  @override
  String get appTitle => 'QuoteFlow';
  @override
  String get inspireYourDay => 'A quieter space for better thoughts.';
  @override
  String get saved => 'Saved';
  @override
  String get login => 'Log In';
  @override
  String get signUp => 'Sign Up';
  @override
  String get email => 'Email';
  @override
  String get password => 'Password';
  @override
  String get name => 'Name';
  @override
  String get confirmPassword => 'Confirm password';
  @override
  String get noAccount => "Don't have an account?";
  @override
  String get hasAccount => 'Already have an account?';
  @override
  String get logout => 'Log Out';
  @override
  String get logoutConfirmation => 'Are you sure you want to log out?';
  @override
  String get cancel => 'Cancel';
  @override
  String get confirm => 'Confirm';
  @override
  String get settings => 'Settings';
  @override
  String get settingsSubtitle => 'Shape QuoteFlow around the way you read.';
  @override
  String get language => 'Language';
  @override
  String get languageSubtitle => 'Choose the language used throughout the app.';
  @override
  String get theme => 'Appearance';
  @override
  String get appearanceSubtitle =>
      'Use your device theme or choose a mood that feels right.';
  @override
  String get darkMode => 'Dark mode';
  @override
  String get lightMode => 'Light mode';
  @override
  String get systemDefault => 'System default';
  @override
  String get english => 'English';
  @override
  String get arabic => 'Arabic';
  @override
  String get favorites => 'Favorites';
  @override
  String get favoritesSubtitle => 'Your saved lines, all in one place.';
  @override
  String get noFavorites => 'No favorites yet';
  @override
  String get noFavoritesDescription =>
      'Save the quotes that stay with you and find them here.';
  @override
  String favoritesCount(int count) =>
      '$count ${count == 1 ? 'quote' : 'quotes'} saved';
  @override
  String get newQuote => 'New quote';
  @override
  String get copyQuote => 'Copy quote';
  @override
  String get quoteCopied => 'Quote copied to clipboard';
  @override
  String get copyToClipboard => 'Copy to clipboard';
  @override
  String get error => 'Error';
  @override
  String get addToFavorites => 'Add to favorites';
  @override
  String get removeFromFavorites => 'Remove from favorites';
  @override
  String get next => 'Next';
  @override
  String get skip => 'Skip';
  @override
  String get done => 'Done';
  @override
  String get onboardingTitle1 => 'Find your next perspective';
  @override
  String get onboardingDesc1 =>
      'Explore timeless ideas selected to bring clarity to ordinary moments.';
  @override
  String get onboardingTitle2 => 'Keep what resonates';
  @override
  String get onboardingDesc2 =>
      'Save meaningful lines and build a personal library for any day.';
  @override
  String get onboardingTitle3 => 'Carry inspiration forward';
  @override
  String get onboardingDesc3 =>
      'Copy a thought with one tap and share a little momentum with someone else.';
  @override
  String get profile => 'Profile';
  @override
  String get about => 'About';
  @override
  String get aboutSubtitle => 'A small, thoughtful quote companion.';
  @override
  String get version => 'Version';
  @override
  String get removeFavorite => 'Remove favorite';
  @override
  String get removeFavoriteTitle => 'Remove this favorite?';
  @override
  String removeFavoriteConfirmation(String quote) =>
      'This quote will be removed from your collection:\n\n“$quote”';
  @override
  String get signInToSaveFavorites =>
      'Sign in to save this quote to your favorites.';
  @override
  String get failedToSaveFavorite =>
      'Could not update favorites. Please try again.';
  @override
  String get favoritesLoadError =>
      'Your favorites could not be loaded. Please try again.';
  @override
  String get signOut => 'Sign out';
  @override
  String get signOutFailed => 'Sign out failed. Please try again.';
  @override
  String get signUpSubtitle => 'Create your account and start collecting.';
  @override
  String get loginSubtitle => 'Welcome back. Sign in to continue.';
  @override
  String get nameHint => 'Enter your full name';
  @override
  String get emailHint => 'Enter your email';
  @override
  String get passwordHint => 'Enter your password';
  @override
  String get confirmPasswordHint => 'Confirm your password';
  @override
  String get showPassword => 'Show password';
  @override
  String get hidePassword => 'Hide password';
  @override
  String get passwordRequired => 'Password is required';
  @override
  String get emailRequired => 'Email is required';
  @override
  String get nameRequired => 'Name is required';
  @override
  String get invalidEmail => 'Enter a valid email address';
  @override
  String get passwordMinLength => 'Password must be at least 6 characters';
  @override
  String get passwordsDoNotMatch => 'Passwords do not match';
  @override
  String get unexpectedError => 'Something went wrong. Please try again.';
  @override
  String get preferenceSaveError =>
      'That preference could not be saved on this device.';
  @override
  String get startupError => 'QuoteFlow could not start';
  @override
  String get startupErrorDescription =>
      'Check your connection and restart the app to try again.';
  @override
  String get guest => 'Guest';
  @override
  String get loading => 'Loading…';
  @override
  String get retry => 'Try again';
  @override
  String greeting(String name) => 'Welcome, $name';
  @override
  String get dailyInspiration => 'Daily inspiration';

  static const _quoteBodies = {
    'q1': 'The only way to do great work is to love what you do.',
    'q2': 'Success is not final, failure is not fatal.',
    'q3': 'Believe you can and you are halfway there.',
    'q4': 'It always seems impossible until it is done.',
    'q5': 'The future depends on what you do today.',
    'q6': "Don\u2019t watch the clock; do what it does. Keep going.",
    'q7': 'Everything you can imagine is real.',
    'q8': 'Start where you are. Use what you have. Do what you can.',
    'q9': 'Dream big and dare to fail.',
    'q10':
        'Great things are done by a series of small things brought together.',
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
  String authError(AuthErrorCode code) {
    return switch (code) {
      AuthErrorCode.emailAlreadyInUse =>
        'This email is already registered. Sign in instead.',
      AuthErrorCode.invalidEmail => 'Enter a valid email address.',
      AuthErrorCode.userNotFound => 'No account was found for this email.',
      AuthErrorCode.wrongPassword => 'The password is incorrect.',
      AuthErrorCode.weakPassword => 'Choose a stronger password.',
      AuthErrorCode.networkRequestFailed =>
        'Check your internet connection and try again.',
      AuthErrorCode.tooManyRequests => 'Too many attempts. Try again later.',
      AuthErrorCode.operationNotAllowed =>
        'This sign-in method is not available.',
      AuthErrorCode.userDisabled => 'This account has been disabled.',
      AuthErrorCode.invalidCredential => 'The email or password is incorrect.',
      AuthErrorCode.requiresRecentLogin => 'Sign in again to continue.',
      AuthErrorCode.accountExistsWithDifferentCredential =>
        'An account already exists using another sign-in method.',
      AuthErrorCode.signUpSetupFailed =>
        'Your account could not be fully created. No account was saved.',
      AuthErrorCode.signUpCleanupFailed =>
        'Account setup was incomplete. Contact support before trying again.',
      AuthErrorCode.signOutFailed => 'Sign out failed. Please try again.',
      AuthErrorCode.notInitialized => 'The app is still starting. Try again.',
      AuthErrorCode.unknown => 'Something went wrong. Please try again.',
    };
  }
}
