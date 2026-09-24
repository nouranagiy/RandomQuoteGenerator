import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await credential.user?.updateDisplayName(name);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'User is not authenticated',
      );
    }

    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'name': name,
      'email': user.email ?? email,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return credential;
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserProfile?> getUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (!doc.exists) return null;

    return UserProfile.fromDocument(doc);
  }

  String getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'emailAlreadyInUse';
      case 'invalid-email':
        return 'invalidEmail';
      case 'wrong-password':
        return 'wrongPassword';
      case 'user-not-found':
        return 'userNotFound';
      case 'weak-password':
        return 'weakPassword';
      case 'network-request-failed':
        return 'networkError';
      default:
        return 'genericError';
    }
  }
}
