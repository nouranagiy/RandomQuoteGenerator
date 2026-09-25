import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quoteflow/core/utils/auth_error_handler.dart';
import 'package:quoteflow/features/auth/data/auth_repository.dart';
import 'package:quoteflow/features/auth/data/user_profile_repository.dart';
import 'package:quoteflow/features/auth/domain/user_profile_model.dart';

class AuthProvider extends ChangeNotifier {
  final Completer<void> _firstAuthStateCompleter = Completer<void>();

  late final AuthRepository _authRepo;
  late final UserProfileRepository _profileRepo;
  StreamSubscription<User?>? _authSubscription;

  User? _firebaseUser;
  UserProfile? _userProfile;
  AuthErrorCode? _failure;
  bool _isLoading = true;
  bool _isBusy = false;
  bool _initialized = false;
  bool _hasReceivedAuthState = false;
  bool _disposed = false;
  int _authStateRevision = 0;

  User? get firebaseUser => _firebaseUser;
  UserProfile? get userProfile => _userProfile;
  bool get isLoading => loadingOverride ?? _isLoading;
  bool get isBusy => _isBusy;
  bool get isAuthenticated => _resolvedAuthenticated;
  AuthErrorCode? get failure => _failure;
  String? get errorMessage => _failure?.firebaseCode;
  Future<void> get firstAuthState => _firstAuthStateCompleter.future;

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

  Future<void> initialize() {
    if (!_initialized && !_disposed) {
      _initialized = true;
      _authRepo = AuthRepository.instance;
      _profileRepo = UserProfileRepository.instance;
      _authSubscription = _authRepo.authStateChanges.listen(
        _onAuthStateChanged,
        onError: _onAuthStateError,
      );
    }
    return firstAuthState;
  }

  Future<void> _onAuthStateChanged(User? user) async {
    final revision = ++_authStateRevision;
    _firebaseUser = user;
    _userProfile = null;
    _isLoading = user != null;
    _profileRepo.clearCache();
    if (!_isBusy) _failure = null;

    if (!_hasReceivedAuthState) {
      _hasReceivedAuthState = true;
      _completeFirstAuthState();
    }
    _notify();

    if (user == null) return;

    final profile = await _loadUserProfile(user);
    if (!_isCurrentAuthState(user.uid, revision)) return;

    _userProfile = profile;
    _isLoading = false;
    _notify();
  }

  void _onAuthStateError(Object error, StackTrace _) {
    _failure = _failureFrom(error);
    _isLoading = false;
    _completeFirstAuthState();
    _notify();
  }

  Future<UserProfile> _loadUserProfile(User user) async {
    UserProfile? profile;
    try {
      profile = await _profileRepo.getProfile(user.uid);
    } catch (_) {
      profile = null;
    }
    return profile ??
        UserProfile(
          uid: user.uid,
          name: user.displayName ?? '',
          email: user.email ?? '',
          createdAt: DateTime.now(),
        );
  }

  bool _isCurrentAuthState(String uid, int revision) {
    return !_disposed &&
        revision == _authStateRevision &&
        _firebaseUser?.uid == uid;
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    if (!_beginOperation()) return false;
    try {
      await _authRepo.signUp(name: name, email: email, password: password);
      return true;
    } catch (error) {
      _failure = _failureFrom(error);
      return false;
    } finally {
      _endOperation();
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    if (!_beginOperation()) return false;
    try {
      await _authRepo.signIn(email: email, password: password);
      return true;
    } catch (error) {
      _failure = _failureFrom(error);
      return false;
    } finally {
      _endOperation();
    }
  }

  Future<void> signOut() async {
    if (!_beginOperation()) return;
    final uid = _firebaseUser?.uid;
    try {
      await _authRepo.signOut();
      _authStateRevision++;
      _firebaseUser = null;
      _userProfile = null;
      _isLoading = false;
      _profileRepo.clearCache(uid);
      _notify();
    } catch (error) {
      _failure = _failureFrom(error);
    } finally {
      _endOperation();
    }
  }

  bool _beginOperation() {
    if (_disposed) return false;
    if (!_initialized) {
      _failure = AuthErrorCode.notInitialized;
      _notify();
      return false;
    }
    if (_isBusy) return false;

    _failure = null;
    _isBusy = true;
    _notify();
    return true;
  }

  void _endOperation() {
    if (_disposed) return;
    _isBusy = false;
    _notify();
  }

  AuthErrorCode _failureFrom(Object error) {
    if (error is AuthException) return error.code;
    if (error is FirebaseAuthException) {
      return AuthErrorHandler.fromException(error);
    }
    return AuthErrorCode.unknown;
  }

  void clearError() {
    if (_failure == null) return;
    _failure = null;
    _notify();
  }

  void _completeFirstAuthState() {
    if (!_firstAuthStateCompleter.isCompleted) {
      _firstAuthStateCompleter.complete();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _completeFirstAuthState();
    final subscription = _authSubscription;
    _authSubscription = null;
    if (subscription != null) subscription.cancel().ignore();
    super.dispose();
  }
}
