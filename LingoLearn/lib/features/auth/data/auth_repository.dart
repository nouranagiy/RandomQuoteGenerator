import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/utils/auth_error_handler.dart';
import 'user_profile_repository.dart';

class AuthException implements Exception {
  final String messageKey;
  AuthException(this.messageKey);

  @override
  String toString() => messageKey;
}

class AuthRepository {
  static final AuthRepository instance = AuthRepository._();
  AuthRepository._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserProfileRepository _profileRepo = UserProfileRepository.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        await _profileRepo.createProfile(
          uid: credential.user!.uid,
          name: name,
          email: email,
        );
        await credential.user!.updateDisplayName(name);
      }
      return credential;
    } on FirebaseAuthException catch (e) {
      throw AuthException(AuthErrorHandler.messageKeyFromException(e));
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
    } on FirebaseAuthException catch (e) {
      throw AuthException(AuthErrorHandler.messageKeyFromException(e));
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
