import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../auth/data/auth_service.dart';
import 'user_model.dart';

class ProfileProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = true;
  Object? _error;
  int _loadToken = 0;
  StreamSubscription<User?>? _authSubscription;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  Object? get error => _error;
  bool get hasError => _error != null;
  String get displayName => _user?.name ?? '';

  ProfileProvider() {
    _authSubscription = _authService.authStateChanges.listen((firebaseUser) {
      if (firebaseUser == null) {
        _user = null;
        _isLoading = false;
        _error = null;
        notifyListeners();
      } else {
        _loadProfile(firebaseUser.uid);
      }
    });
  }

  Future<void> _loadProfile(String uid) async {
    final token = ++_loadToken;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final profile = await _authService.getProfile(uid);
      if (token != _loadToken) return;
      _user = profile;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (token != _loadToken) return;
      _user = null;
      _error = e;
      final isPermission = e is FirebaseException && e.code == 'permission-denied';
      debugPrint(
        'Failed to load Firestore profile for uid=$uid'
        '${isPermission ? " (PERMISSION_DENIED: Firestore security rules are "
            "not allowing this read — publish users/{uid} rules in project "
            "fittrack-728fa)" : ""}: $e',
      );
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshProfile() async {
    // Resolve the currently authenticated user's UID and load their profile.
    final uid = _authService.currentUser?.uid;
    if (uid == null) {
      return;
    }
    await _loadProfile(uid);
  }

  void clearProfile() {
    _user = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
