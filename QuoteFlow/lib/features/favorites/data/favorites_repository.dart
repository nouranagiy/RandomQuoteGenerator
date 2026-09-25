import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quoteflow/core/constants/app_constants.dart';
import 'package:quoteflow/models/quote.dart';

class FavoritesRepository {
  static final FavoritesRepository instance = FavoritesRepository._();
  FavoritesRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String uid) {
    return _firestore
        .collection(AppConstants.firestoreUsersCollection)
        .doc(uid)
        .collection(AppConstants.firestoreFavoritesCollection);
  }

  Future<List<Quote>> getFavorites(String uid) async {
    final snapshot = await _collection(
      uid,
    ).get(const GetOptions(source: Source.serverAndCache));
    final favorites = <_StoredFavorite>[];

    for (final document in snapshot.docs) {
      final data = document.data();
      final textValue = data['text'];
      if (textValue is! String || textValue.trim().isEmpty) continue;
      final text = textValue.trim();
      final authorValue = data['author'];
      final author = authorValue is String && authorValue.trim().isNotEmpty
          ? authorValue.trim()
          : 'Unknown';
      favorites.add(
        _StoredFavorite(
          quote: Quote(text: text, author: author),
          createdAt: _parseDateTime(data['createdAt']),
        ),
      );
    }

    favorites.sort((left, right) {
      final leftCreatedAt = left.createdAt;
      final rightCreatedAt = right.createdAt;
      if (leftCreatedAt == null && rightCreatedAt == null) {
        return left.quote.text.compareTo(right.quote.text);
      }
      if (leftCreatedAt == null) return 1;
      if (rightCreatedAt == null) return -1;
      final byDate = rightCreatedAt.compareTo(leftCreatedAt);
      return byDate != 0 ? byDate : left.quote.text.compareTo(right.quote.text);
    });

    final seenTexts = <String>{};
    return [
      for (final favorite in favorites)
        if (seenTexts.add(favorite.quote.text)) favorite.quote,
    ];
  }

  Future<void> addFavorite(String uid, Quote quote) async {
    final collection = _collection(uid);
    final documentId = _documentId(quote.text);
    final batch = _firestore.batch();
    batch.set(collection.doc(documentId), {
      'text': quote.text,
      'author': quote.author,
      'createdAt': FieldValue.serverTimestamp(),
    });
    _deleteLegacyDocument(batch, collection, quote.text, documentId);
    await batch.commit();
  }

  Future<void> removeFavorite(String uid, String quoteText) async {
    final collection = _collection(uid);
    final documentId = _documentId(quoteText);
    final batch = _firestore.batch();
    batch.delete(collection.doc(documentId));
    _deleteLegacyDocument(batch, collection, quoteText, documentId);
    await batch.commit();
  }

  void _deleteLegacyDocument(
    WriteBatch batch,
    CollectionReference<Map<String, dynamic>> collection,
    String quoteText,
    String documentId,
  ) {
    if (quoteText != documentId && _isValidDocumentId(quoteText)) {
      batch.delete(collection.doc(quoteText));
    }
  }

  String _documentId(String quoteText) {
    final encoded = base64Url
        .encode(utf8.encode(quoteText))
        .replaceAll('=', '');
    return 'quote_$encoded';
  }

  bool _isValidDocumentId(String value) {
    final encodedLength = utf8.encode(value).length;
    return value.isNotEmpty &&
        value != '.' &&
        value != '..' &&
        !value.contains('/') &&
        !RegExp(r'^__.*__$').hasMatch(value) &&
        encodedLength <= 1500;
  }

  DateTime? _parseDateTime(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
    }
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}

class _StoredFavorite {
  const _StoredFavorite({required this.quote, required this.createdAt});

  final Quote quote;
  final DateTime? createdAt;
}
