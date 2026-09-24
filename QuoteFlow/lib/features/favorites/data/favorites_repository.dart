import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quoteflow/core/constants/app_constants.dart';
import 'package:quoteflow/models/quote.dart';

/// Firestore-backed repository for a user's favorite quotes.
///
/// Favorites are stored per authenticated user under
/// `users/{uid}/favorites/{quoteText}`. The document ID is the quote text, so
/// toggling a favorite on/off is naturally idempotent (no duplicate records).
class FavoritesRepository {
  static final FavoritesRepository instance = FavoritesRepository._();
  FavoritesRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String uid) =>
      _firestore.collection(AppConstants.firestoreUsersCollection).doc(uid).collection(
        AppConstants.firestoreFavoritesCollection,
      );

  Future<List<Quote>> getFavorites(String uid) async {
    final snapshot = await _collection(uid).get(
      const GetOptions(source: Source.serverAndCache),
    );
    final favorites = <Quote>[];
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final text = data['text'] as String?;
      final author = data['author'] as String?;
      if (text != null && text.isNotEmpty) {
        favorites.add(Quote(text: text, author: author ?? 'Unknown'));
      }
    }
    return favorites;
  }

  Future<void> addFavorite(String uid, Quote quote) async {
    await _collection(uid).doc(quote.text).set({
      'text': quote.text,
      'author': quote.author,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeFavorite(String uid, String quoteText) async {
    await _collection(uid).doc(quoteText).delete();
  }
}
