import 'package:firebase_auth/firebase_auth.dart';

enum AuthErrorCode {
  emailAlreadyInUse('email-already-in-use'),
  invalidEmail('invalid-email'),
  userNotFound('user-not-found'),
  wrongPassword('wrong-password'),
  weakPassword('weak-password'),
  networkRequestFailed('network-request-failed'),
  tooManyRequests('too-many-requests'),
  operationNotAllowed('operation-not-allowed'),
  userDisabled('user-disabled'),
  invalidCredential('invalid-credential'),
  requiresRecentLogin('requires-recent-login'),
  accountExistsWithDifferentCredential(
    'account-exists-with-different-credential',
  ),
  signUpSetupFailed('sign-up-setup-failed'),
  signUpCleanupFailed('sign-up-cleanup-failed'),
  signOutFailed('sign-out-failed'),
  notInitialized('auth-not-initialized'),
  unknown('unknown');

  const AuthErrorCode(this.firebaseCode);

  final String firebaseCode;
}

class AuthErrorHandler {
  AuthErrorHandler._();

  static AuthErrorCode fromCode(String code) {
    for (final errorCode in AuthErrorCode.values) {
      if (errorCode.firebaseCode == code) return errorCode;
    }
    return AuthErrorCode.unknown;
  }

  static AuthErrorCode fromException(FirebaseAuthException exception) {
    return fromCode(exception.code);
  }
}
