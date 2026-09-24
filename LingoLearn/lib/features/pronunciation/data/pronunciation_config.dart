class PronunciationConfig {
  const PronunciationConfig._();

  static const String tokenUrl = String.fromEnvironment(
    'LINGOLEARN_AZURE_TOKEN_URL',
  );

  static const String languageCode = String.fromEnvironment(
    'LINGOLEARN_AZURE_LANGUAGE',
    defaultValue: 'en-US',
  );

  static const Duration requestTimeout = Duration(seconds: 30);

  static const int minutesBeforeTokenExpiry = 9;

  static bool get isConfigured => tokenUrl.trim().isNotEmpty;
}
