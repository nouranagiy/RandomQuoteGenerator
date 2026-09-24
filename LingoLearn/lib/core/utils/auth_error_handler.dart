import 'package:firebase_auth/firebase_auth.dart';

class AuthErrorHandler {
  AuthErrorHandler._();

  static String messageKey(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'emailAlreadyExists';
      case 'invalid-email':
        return 'invalidEmail';
      case 'user-not-found':
        return 'userNotFound';
      case 'wrong-password':
        return 'wrongPassword';
      case 'weak-password':
        return 'weakPassword';
      case 'network-request-failed':
        return 'networkError';
      case 'too-many-requests':
        return 'tooManyRequests';
      case 'operation-not-allowed':
        return 'operationNotAllowed';
      case 'user-disabled':
        return 'userDisabled';
      case 'invalid-credential':
        return 'invalidCredentials';
      case 'requires-recent-login':
        return 'requiresRecentLogin';
      default:
        return 'unknownError';
    }
  }

  static String messageKeyFromException(FirebaseAuthException e) {
    return messageKey(e.code);
  }
}
