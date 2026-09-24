import 'package:flutter/foundation.dart';
import 'package:quoteflow/features/favorites/data/favorites_repository.dart';
import 'package:quoteflow/models/quote.dart';
import 'package:quoteflow/shared/providers/auth_provider.dart';

/// Holds the current user's favorites, backed by Firestore.
///
/// It binds to [AuthProvider] so favorites load automatically when the user
/// logs in / the app starts, and clear when the user signs out. The favorite
/// state is driven by Firestore (per authenticated UID), not by SharedPreferences.
class FavoritesProvider extends ChangeNotifier {
  // Resolved lazily on first Firestore use (after auth/Firebase is ready) to
  // avoid touching FirebaseFirestore.instance during startup.
  FavoritesRepository? _repo;
  FavoritesRepository get _firestoreRepo => _repo ??= FavoritesRepository.instance;

  AuthProvider? _auth;
  bool _bound = false;

  final List<Quote> _quotes = [];
  final Set<String> _favoriteTexts = {};
  String? _uid;
  bool _isLoading = false;
  String? _error;

  List<Quote> get quotes => List.unmodifiable(_quotes);
  bool get isLoading => _isLoading;
  String? get errorMessage => _error;
  String? get uid => _uid;
  bool get hasUser => _uid != null;

  bool isFavorite(String text) => _favoriteTexts.contains(text);

  /// Binds to auth state changes so favorites follow the signed-in user.
  void bindTo(AuthProvider auth) {
    if (_bound) return;
    _bound = true;
    _auth = auth;
    auth.addListener(_handleAuthChanged);
    _handleAuthChanged();
  }

  void _handleAuthChanged() {
    final uid = _auth?.firebaseUser?.uid;
    if (uid == _uid) return;
    _uid = uid;
    if (uid == null) {
      _quotes.clear();
      _favoriteTexts.clear();
      _error = null;
      _isLoading = false;
      notifyListeners();
    } else {
      loadFavorites(uid);
    }
  }

  /// Loads the user's favorites from Firestore.
  Future<void> loadFavorites(String uid) async {
    if (uid != _uid) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final favorites = await _firestoreRepo.getFavorites(uid);
      if (uid != _uid) return;
      _quotes
        ..clear()
        ..addAll(favorites);
      _favoriteTexts
        ..clear()
        ..addAll(favorites.map((q) => q.text));
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      if (uid != _uid) return;
      _isLoading = false;
      _error = 'Could not load favorites.';
      notifyListeners();
    }
  }

  /// Toggles a quote's favorite state. Returns true if it was a favorite
  /// after the toggle, or null on failure / when not authenticated.
  Future<bool?> toggle(Quote quote) async {
    if (_uid == null) return null;
    final isFav = _favoriteTexts.contains(quote.text);
    if (isFav) {
      return (await remove(quote.text)) ? false : null;
    }
    return (await add(quote)) ? true : null;
  }

  Future<bool> add(Quote quote) async {
    final uid = _uid;
    if (uid == null) return false;
    // Optimistic update.
    final hadIt = _favoriteTexts.contains(quote.text);
    if (!hadIt) {
      _favoriteTexts.add(quote.text);
      _quotes.insert(0, quote);
      notifyListeners();
    }
    try {
      await _firestoreRepo.addFavorite(uid, quote);
      return true;
    } catch (_) {
      if (!hadIt) {
        _favoriteTexts.remove(quote.text);
        _quotes.removeWhere((q) => q.text == quote.text);
        notifyListeners();
      }
      _error = 'Could not save favorite.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> remove(String quoteText) async {
    final uid = _uid;
    if (uid == null) return false;
    final hadIt = _favoriteTexts.contains(quoteText);
    if (hadIt) {
      _favoriteTexts.remove(quoteText);
      _quotes.removeWhere((q) => q.text == quoteText);
      notifyListeners();
    }
    try {
      await _firestoreRepo.removeFavorite(uid, quoteText);
      return true;
    } catch (_) {
      if (!hadIt) {
        _favoriteTexts.add(quoteText);
        notifyListeners();
      }
      _error = 'Could not remove favorite.';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _auth?.removeListener(_handleAuthChanged);
    _auth = null;
    super.dispose();
  }
}
