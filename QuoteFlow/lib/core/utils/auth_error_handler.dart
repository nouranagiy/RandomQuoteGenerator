import 'package:firebase_auth/firebase_auth.dart';

class AuthErrorHandler {
  AuthErrorHandler._();

  static String getMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please use a different email or sign in.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
        return 'No account found with this email. Please sign up first.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'weak-password':
        return 'Password is too weak. Please use a stronger password.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This sign-in method is not enabled. Please contact support.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'invalid-credential':
        return 'Invalid email or password. Please try again.';
      case 'requires-recent-login':
        return 'Please sign in again to complete this action.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email using a different sign-in method.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  static String getMessageFromException(FirebaseAuthException e) {
    return getMessage(e.code);
  }
}
