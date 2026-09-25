import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:quoteflow/features/favorites/data/favorites_repository.dart';
import 'package:quoteflow/models/quote.dart';
import 'package:quoteflow/shared/providers/auth_provider.dart';

enum FavoritesFailure { load, add, remove }

class FavoritesProvider extends ChangeNotifier {
  FavoritesRepository? _repository;
  FavoritesRepository get _firestoreRepository {
    return _repository ??= FavoritesRepository.instance;
  }

  AuthProvider? _auth;
  final List<Quote> _quotes = [];
  final Set<String> _favoriteTexts = {};
  Future<void> _operationTail = Future<void>.value();
  String? _uid;
  FavoritesFailure? _failure;
  bool _isLoading = false;
  bool _disposed = false;
  int _stateRevision = 0;

  List<Quote> get quotes => List.unmodifiable(_quotes);
  bool get isLoading => _isLoading;
  FavoritesFailure? get failure => _failure;
  String? get errorMessage => _failure?.name;
  String? get uid => _uid;
  bool get hasUser => _uid != null;

  bool isFavorite(String text) => _favoriteTexts.contains(text);

  void bindTo(AuthProvider auth) {
    if (_disposed || identical(_auth, auth)) return;
    _auth?.removeListener(_handleAuthChanged);
    _auth = auth;
    auth.addListener(_handleAuthChanged);
    _handleAuthChanged();
  }

  void _handleAuthChanged() {
    final uid = _auth?.firebaseUser?.uid;
    if (_disposed || uid == _uid) return;

    _stateRevision++;
    _uid = uid;
    _quotes.clear();
    _favoriteTexts.clear();
    _failure = null;
    _isLoading = uid != null;
    _notify();

    if (uid != null) unawaited(loadFavorites(uid));
  }

  Future<void> loadFavorites(String uid) async {
    final revision = _stateRevision;
    if (!_isCurrent(uid, revision)) return;

    await _withOperationLock(() async {
      if (!_isCurrent(uid, revision)) return;
      _isLoading = true;
      _failure = null;
      _notify();

      try {
        final favorites = await _firestoreRepository.getFavorites(uid);
        if (!_isCurrent(uid, revision)) return;
        _quotes
          ..clear()
          ..addAll(favorites);
        _favoriteTexts
          ..clear()
          ..addAll(favorites.map((quote) => quote.text));
        _isLoading = false;
        _notify();
      } catch (_) {
        if (!_isCurrent(uid, revision)) return;
        _isLoading = false;
        _failure = FavoritesFailure.load;
        _notify();
      }
    });
  }

  Future<bool?> toggle(Quote quote) {
    final uid = _uid;
    final revision = _stateRevision;
    if (uid == null) return Future<bool?>.value(null);

    return _withOperationLock(() async {
      if (!_isCurrent(uid, revision)) return null;
      if (_favoriteTexts.contains(quote.text)) {
        return _removeFavorite(uid, revision, quote.text);
      }
      return _addFavorite(uid, revision, quote);
    });
  }

  Future<bool> add(Quote quote) {
    final uid = _uid;
    final revision = _stateRevision;
    if (uid == null) return Future<bool>.value(false);

    return _withOperationLock(() => _addFavorite(uid, revision, quote));
  }

  Future<bool> remove(String quoteText) {
    final uid = _uid;
    final revision = _stateRevision;
    if (uid == null) return Future<bool>.value(false);

    return _withOperationLock(() => _removeFavorite(uid, revision, quoteText));
  }

  Future<bool> _addFavorite(String uid, int revision, Quote quote) async {
    if (!_isCurrent(uid, revision)) return false;

    final hadFavorite = _favoriteTexts.contains(quote.text);
    _failure = null;
    if (!hadFavorite) {
      _favoriteTexts.add(quote.text);
      _quotes.insert(0, quote);
    }
    _notify();

    try {
      await _firestoreRepository.addFavorite(uid, quote);
      return true;
    } catch (_) {
      if (_isCurrent(uid, revision)) {
        if (!hadFavorite) {
          _favoriteTexts.remove(quote.text);
          _quotes.removeWhere((favorite) => favorite.text == quote.text);
        }
        _failure = FavoritesFailure.add;
        _notify();
      }
      return false;
    }
  }

  Future<bool> _removeFavorite(
    String uid,
    int revision,
    String quoteText,
  ) async {
    if (!_isCurrent(uid, revision)) return false;

    final removedIndex = _quotes.indexWhere(
      (favorite) => favorite.text == quoteText,
    );
    final removedQuote = removedIndex == -1 ? null : _quotes[removedIndex];
    final hadFavorite =
        removedQuote != null || _favoriteTexts.contains(quoteText);
    _failure = null;
    _favoriteTexts.remove(quoteText);
    _quotes.removeWhere((favorite) => favorite.text == quoteText);
    _notify();

    try {
      await _firestoreRepository.removeFavorite(uid, quoteText);
      return true;
    } catch (_) {
      if (_isCurrent(uid, revision)) {
        if (hadFavorite) {
          _favoriteTexts.add(quoteText);
          final alreadyRestored = _quotes.any(
            (favorite) => favorite.text == quoteText,
          );
          if (removedQuote != null && !alreadyRestored) {
            final insertionIndex = removedIndex < _quotes.length
                ? removedIndex
                : _quotes.length;
            _quotes.insert(insertionIndex, removedQuote);
          }
        }
        _failure = FavoritesFailure.remove;
        _notify();
      }
      return false;
    }
  }

  Future<T> _withOperationLock<T>(Future<T> Function() operation) async {
    final previousOperation = _operationTail;
    final release = Completer<void>();
    _operationTail = release.future;
    await previousOperation;
    try {
      return await operation();
    } finally {
      release.complete();
    }
  }

  bool _isCurrent(String uid, int revision) {
    return !_disposed && _uid == uid && _stateRevision == revision;
  }

  void clearError() {
    if (_failure == null) return;
    _failure = null;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _auth?.removeListener(_handleAuthChanged);
    _auth = null;
    super.dispose();
  }
}
