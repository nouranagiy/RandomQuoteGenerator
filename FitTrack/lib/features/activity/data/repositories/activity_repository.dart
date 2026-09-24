import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../../../models/fitness_entry.dart';

/// Exception thrown when a Firestore operation fails (e.g. permission-denied),
/// with a human-readable [message] suitable for showing to the user.
class ActivityStorageException implements Exception {
  final String message;
  final String code;
  const ActivityStorageException(this.message, this.code);

  @override
  String toString() => message;
}

/// Data layer for user fitness activities.
///
/// Activities are stored per-user under:
///   `users/{uid}/activities/{activityId}`
///
/// Firestore is the single source of truth. No local-only persistence is used
/// for activities.
class ActivityRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ActivityRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// The collection referencing the current user's activities.
  CollectionReference<Map<String, dynamic>> _activitiesRef(String uid) =>
      _firestore.collection('users').doc(uid).collection('activities');

  String _requireUid() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw const ActivityStorageException(
        'You are not signed in.',
        'unauthenticated',
      );
    }
    return uid;
  }

  /// Adds a new activity to `users/{uid}/activities/{activityId}`.
  ///
  /// The Firestore-generated document id becomes the activity id. Returns the
  /// saved activity (including its new id).
  Future<FitnessEntry> addActivity(FitnessEntry activity) async {
    final uid = _requireUid();
    try {
      final ref = _activitiesRef(uid).doc();
      await ref.set({
        ...activity.toFirestore(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return FitnessEntry(
        id: ref.id,
        exerciseType: activity.exerciseType,
        duration: activity.duration,
        calories: activity.calories,
        steps: activity.steps,
        date: activity.date,
      );
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e);
    }
  }

  /// Updates an existing activity's document in place (no second doc created).
  Future<void> updateActivity(FitnessEntry activity) async {
    final uid = _requireUid();
    try {
      await _activitiesRef(uid).doc(activity.id).update(activity.toFirestore());
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e);
    }
  }

  /// Deletes an activity by id.
  Future<void> deleteActivity(String activityId) async {
    final uid = _requireUid();
    try {
      await _activitiesRef(uid).doc(activityId).delete();
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e);
    }
  }

  /// Loads all activities for the current user, newest first.
  Future<List<FitnessEntry>> getActivities() async {
    final uid = _requireUid();
    try {
      final snapshot = await _activitiesRef(uid)
          .orderBy('date', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => FitnessEntry.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw _mapFirebaseException(e);
    }
  }

  /// Streams activities for real-time updates (history auto-refreshes).
  Stream<List<FitnessEntry>> streamActivities() {
    final uid = _requireUid();
    return _activitiesRef(uid)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => FitnessEntry.fromFirestore(doc)).toList());
  }

  ActivityStorageException _mapFirebaseException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return ActivityStorageException(
          'You do not have permission to access this data.',
          e.code,
        );
      case 'unavailable':
      case 'network-request-failed':
        return ActivityStorageException(
          'Connection problem. Check your internet and try again.',
          e.code,
        );
      default:
        debugPrint('Activity Firestore error (${e.code}): $e');
        return ActivityStorageException(
          'Could not save your activity. Please try again.',
          e.code,
        );
    }
  }
}
