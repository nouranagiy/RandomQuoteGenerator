import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';

import '../data/auth_repository.dart';
import '../data/user_profile_repository.dart';
import '../domain/user_profile_model.dart';

class AuthController extends ChangeNotifier {
  late final AuthRepository _authRepo;
  late final UserProfileRepository _profileRepo;

  User? _firebaseUser;
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool _isBusy = false;
  String? _errorKey;
  StreamSubscription<User?>? _authSubscription;
  bool _initialized = false;

  User? get firebaseUser => _firebaseUser;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => loadingOverride ?? _isLoading;
  bool get isBusy => _isBusy;
  bool get isAuthenticated => _resolvedAuthenticated;
  String? get errorKey => _errorKey;
  String get displayName => _userProfile?.name.isEmpty == false
      ? _userProfile!.name
      : (_firebaseUser?.displayName ?? '');
  String get displayEmail => _userProfile?.email.isNotEmpty == true
      ? _userProfile!.email
      : (_firebaseUser?.email ?? '');

  @visibleForTesting
  bool? authenticatedOverride;
  @visibleForTesting
  bool? loadingOverride;

  bool get _resolvedAuthenticated =>
      authenticatedOverride ?? (_firebaseUser != null);

  AuthController();

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
    } catch (_) {
      _userProfile ??= UserProfile(
        uid: uid,
        name: _firebaseUser?.displayName ?? '',
        email: _firebaseUser?.email ?? '',
        createdAt: DateTime.now(),
      );
    }
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _errorKey = null;
    _isBusy = true;
    notifyListeners();
    try {
      await _authRepo.signUp(name: name, email: email, password: password);
      return true;
    } on AuthException catch (e) {
      _errorKey = e.messageKey;
      return false;
    } catch (_) {
      _errorKey = 'unknownError';
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    _errorKey = null;
    _isBusy = true;
    notifyListeners();
    try {
      await _authRepo.signIn(email: email, password: password);
      return true;
    } on AuthException catch (e) {
      _errorKey = e.messageKey;
      return false;
    } catch (_) {
      _errorKey = 'unknownError';
      return false;
    } finally {
      _isBusy = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _errorKey = null;
    await _authRepo.signOut();
    _userProfile = null;
    _firebaseUser = null;
    _profileRepo.clearCache();
    notifyListeners();
  }

  void clearError() {
    if (_errorKey == null) return;
    _errorKey = null;
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

class AuthControllerScope extends InheritedNotifier<AuthController> {
  const AuthControllerScope({
    super.key,
    required AuthController controller,
    required super.child,
  }) : super(notifier: controller);

  static AuthController of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AuthControllerScope>();
    return scope!.notifier!;
  }
}
