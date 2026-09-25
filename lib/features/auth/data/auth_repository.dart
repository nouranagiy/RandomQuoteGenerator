import 'package:firebase_auth/firebase_auth.dart';
import 'package:quoteflow/core/utils/auth_error_handler.dart';
import 'package:quoteflow/features/auth/data/user_profile_repository.dart';

class AuthRepository {
  static final AuthRepository instance = AuthRepository._();
  AuthRepository._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserProfileRepository _profileRepo = UserProfileRepository.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    late final UserCredential credential;
    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthException(AuthErrorHandler.fromException(error), cause: error);
    } catch (error) {
      throw AuthException(AuthErrorCode.unknown, cause: error);
    }

    final user = credential.user;
    if (user == null) {
      throw const AuthException(AuthErrorCode.unknown);
    }

    try {
      await user.updateDisplayName(name);
      await _profileRepo.createProfile(uid: user.uid, name: name, email: email);
      return credential;
    } catch (error) {
      final cleanedUp = await _rollbackSignUp(user);
      if (!cleanedUp) {
        throw AuthException(AuthErrorCode.signUpCleanupFailed, cause: error);
      }
      throw AuthException(AuthErrorCode.signUpSetupFailed, cause: error);
    }
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthException(AuthErrorHandler.fromException(error), cause: error);
    } catch (error) {
      throw AuthException(AuthErrorCode.unknown, cause: error);
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (error) {
      throw AuthException(AuthErrorHandler.fromException(error), cause: error);
    } catch (error) {
      throw AuthException(AuthErrorCode.signOutFailed, cause: error);
    }
  }

  Future<bool> _rollbackSignUp(User user) async {
    var succeeded = true;
    try {
      await _profileRepo.deleteProfile(user.uid);
    } catch (_) {
      succeeded = false;
    }
    try {
      await user.delete();
    } catch (_) {
      succeeded = false;
    }
    return succeeded;
  }
}

class AuthException implements Exception {
  const AuthException(this.code, {this.cause});

  final AuthErrorCode code;
  final Object? cause;

  @override
  String toString() => 'AuthException(${code.firebaseCode})';
}
