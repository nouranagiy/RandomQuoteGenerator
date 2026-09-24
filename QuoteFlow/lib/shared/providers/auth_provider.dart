import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quoteflow/features/auth/data/auth_repository.dart';
import 'package:quoteflow/features/auth/domain/user_profile_model.dart';
import 'package:quoteflow/features/auth/data/user_profile_repository.dart';

class AuthProvider extends ChangeNotifier {
  // Lazily resolved in [initialize] (after Firebase is ready). Constructing
  // AuthRepository/UserProfileRepository eagerly would touch
  // FirebaseAuth.instance/FirebaseFirestore.instance synchronously and crash
  // with [core/no-app] if Firebase hasn't initialized yet.
  late final AuthRepository _authRepo;
  late final UserProfileRepository _profileRepo;

  User? _firebaseUser;
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _isBusy = false;
  String? _errorMessage;
  StreamSubscription<User?>? _authSubscription;
  bool _initialized = false;

  User? get firebaseUser => _firebaseUser;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => loadingOverride ?? _isLoading;
  bool get isBusy => _isBusy;
  bool get isAuthenticated => _resolvedAuthenticated;
  String? get errorMessage => _errorMessage;
  String get displayName => _userProfile?.name.isEmpty == false
      ? _userProfile!.name
      : (_firebaseUser?.displayName ?? '');
  String get displayEmail => _userProfile?.email.isNotEmpty == true
      ? _userProfile!.email
      : (_firebaseUser?.email ?? '');

  /// Constructs a provider without touching Firebase. [initialize] must be
  /// called once Firebase is ready so the app can render its first frame
  /// immediately while auth/Firestore initialize in the background.
  AuthProvider();

  /// Test-only seam: overrides the real Firebase-driven auth state. Used by
  /// widget tests to simulate a signed-in/signed-out user without Firebase.
  /// A null value falls back to the Firebase-backed [_firebaseUser].
  @visibleForTesting
  bool? authenticatedOverride;
  @visibleForTesting
  bool? loadingOverride;

  bool get _resolvedAuthenticated =>
      authenticatedOverride ?? (_firebaseUser != null);

  /// Idempotently subscribes to Firebase Auth. Safe to call only after
  /// `Firebase.initializeApp()`. Never blocks startup.
  void initialize() {
    if (_initialized) return;
    _initialized = true;
    _authRepo = AuthRepository.instance;
    _profileRepo = UserProfileRepository.instance;
    _authSubscription = _authRepo.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _firebaseUser = user;
    if (user != null) {
      await _loadUserProfile(user.uid);
    } else {
      _userProfile = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadUserProfile(String uid) async {
    try {
      _userProfile ??= await _profileRepo.getProfile(uid);
      _userProfile ??= UserProfile(
        uid: uid,
        name: _firebaseUser?.displayName ?? '',
        email: _firebaseUser?.email ?? '',
        createdAt: DateTime.now(),
      );
    } catch (e) {
      // Fall back to the authentication-provided display name if Firestore
      // is unavailable, so the UI never blocks on a failed read.
      _userProfile ??= UserProfile(
        uid: uid,
        name: _firebaseUser?.displayName ?? '',
        email: _firebaseUser?.email ?? '',
        createdAt: DateTime.now(),
      );
    }
    notifyListeners();
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _errorMessage = null;
    _isBusy = true;
    notifyListeners();
    try {
      await _authRepo.signUp(name: name, email: email, password: password);
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _errorMessage = null;
    _isBusy = true;
    notifyListeners();
    try {
      await _authRepo.signIn(email: email, password: password);
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred. Please try again.';
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _errorMessage = null;
    await _authRepo.signOut();
    _userProfile = null;
    _firebaseUser = null;
    // Drop the cached profile so a different account can't read stale data.
    _profileRepo.clearCache();
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _authSubscription = null;
    _initialized = false;
    super.dispose();
  }
}
