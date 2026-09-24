import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../profile/data/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// The authenticated user's UID, or null if not signed in.
  String? get currentUid => _auth.currentUser?.uid;

  /// Reads the profile document at `users/{uid}`.
  ///
  /// This is a DIRECT single-document read (`doc(uid).get()`), never a
  /// collection query, so it does not use `.where(...)` or `.orderBy(...)`.
  /// If [uid] is omitted, it is resolved from the signed-in user.
  Future<UserModel?> getProfile([String? uid]) async {
    uid ??= currentUid;
    if (uid == null) return null;

    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  /// Creates (or updates) the profile document at `users/{uid}` right after
  /// account creation. The password is never written to Firestore.
  Future<void> saveProfile(UserModel profile) async {
    await _firestore
        .collection('users')
        .doc(profile.uid)
        .set(profile.toMap(), SetOptions(merge: true));
  }

  Future<UserModel?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) throw Exception('Failed to create account');

    final profile = UserModel(
      uid: user.uid,
      name: name,
      email: email,
      createdAt: DateTime.now(),
    );

    // Create the profile at `users/{uid}` immediately after sign-up.
    // The password is managed only by Firebase Auth and never stored here.
    await saveProfile(profile);
    return profile;
  }

  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) throw Exception('Failed to sign in');

    return getProfile(user.uid);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }
}
