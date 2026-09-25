import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quoteflow/core/constants/app_constants.dart';
import 'package:quoteflow/features/auth/domain/user_profile_model.dart';

class UserProfileRepository {
  static final UserProfileRepository instance = UserProfileRepository._();
  UserProfileRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, UserProfile> _cache = {};

  Future<void> createProfile({
    required String uid,
    required String name,
    required String email,
  }) async {
    final profile = UserProfile(
      uid: uid,
      name: name,
      email: email,
      createdAt: DateTime.now(),
    );
    await _firestore
        .collection(AppConstants.firestoreUsersCollection)
        .doc(uid)
        .set(profile.toMap());
    _cache[uid] = profile;
  }

  Future<UserProfile?> getProfile(String uid) async {
    final cached = _cache[uid];
    if (cached != null) return cached;

    final document = await _firestore
        .collection(AppConstants.firestoreUsersCollection)
        .doc(uid)
        .get(const GetOptions(source: Source.serverAndCache));
    if (!document.exists) {
      _cache.remove(uid);
      return null;
    }

    final profile = UserProfile.fromFirestore(document);
    _cache[uid] = profile;
    return profile;
  }

  Future<void> deleteProfile(String uid) async {
    try {
      await _firestore
          .collection(AppConstants.firestoreUsersCollection)
          .doc(uid)
          .delete();
    } finally {
      _cache.remove(uid);
    }
  }

  void clearCache([String? uid]) {
    if (uid == null) {
      _cache.clear();
    } else {
      _cache.remove(uid);
    }
  }
}
