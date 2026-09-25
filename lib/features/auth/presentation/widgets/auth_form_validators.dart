class AuthFormValidators {
  const AuthFormValidators._();

  static final RegExp _emailPattern = RegExp(
    r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
  );

  static String? requiredValue(String? value, {required String message}) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  static String? email(
    String? value, {
    required String requiredMessage,
    required String invalidMessage,
  }) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) return requiredMessage;
    if (!_emailPattern.hasMatch(normalized)) return invalidMessage;
    return null;
  }

  static String? password(
    String? value, {
    required String requiredMessage,
    String? minLengthMessage,
    int? minLength,
  }) {
    if (value == null || value.isEmpty) return requiredMessage;
    if (minLength != null &&
        minLengthMessage != null &&
        value.length < minLength) {
      return minLengthMessage;
    }
    return null;
  }

  static String? passwordsMatch(
    String? value, {
    required String password,
    required String requiredMessage,
    required String mismatchMessage,
  }) {
    if (value == null || value.isEmpty) return requiredMessage;
    if (value != password) return mismatchMessage;
    return null;
  }
}
