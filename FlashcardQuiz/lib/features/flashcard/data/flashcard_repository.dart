import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/flashcard.dart';

class FlashcardRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _userFlashcards {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw StateError('User is not authenticated');
    }
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('flashcards');
  }

  Stream<List<Flashcard>> watchFlashcards() {
    final query = _userFlashcards.orderBy('createdAt', descending: true);
    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => Flashcard.fromMap({...doc.data(), 'id': doc.id}))
          .toList(),
    );
  }

  Future<List<Flashcard>> getFlashcards() async {
    final query = await _userFlashcards.orderBy('createdAt').get();
    return query.docs
        .map((doc) => Flashcard.fromMap({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<Flashcard> createFlashcard(Flashcard flashcard) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final data = {
      ...flashcard.toMap(),
      'uid': uid,
      'createdAt': FieldValue.serverTimestamp(),
    };
    await _userFlashcards.doc(flashcard.id).set(data, SetOptions(merge: true));
    return flashcard;
  }

  Future<void> updateFlashcard(Flashcard flashcard) async {
    await _userFlashcards
        .doc(flashcard.id)
        .set(flashcard.toMap(), SetOptions(merge: true));
  }

  Future<void> updateFavorite(String flashcardId, bool isFavorite) async {
    await _userFlashcards.doc(flashcardId).update({'isFavorite': isFavorite});
  }

  Future<void> deleteFlashcard(String flashcardId) async {
    await _userFlashcards.doc(flashcardId).delete();
  }

  /// Migrates flashcards previously stored in local SharedPreferences into
  /// Firestore so they become persistent and survive app reinstalls.
  Future<void> importLocalFlashcards(List<Flashcard> localFlashcards) async {
    if (localFlashcards.isEmpty) return;

    final uid = FirebaseAuth.instance.currentUser;
    if (uid == null) return;

    final batch = _firestore.batch();
    var added = false;

    for (final flashcard in localFlashcards) {
      final docRef = _userFlashcards.doc(flashcard.id);
      final data = {
        ...flashcard.toMap(),
        'uid': uid.uid,
        'createdAt': FieldValue.serverTimestamp(),
      };
      batch.set(docRef, data, SetOptions(merge: true));
      added = true;
    }

    if (added) {
      await batch.commit();
    }
  }
}
