import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quoteflow/core/constants/app_constants.dart';
import 'package:quoteflow/features/auth/domain/user_profile_model.dart';

class UserProfileRepository {
  static final UserProfileRepository instance = UserProfileRepository._();
  UserProfileRepository._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // In-memory cache keyed by UID so repeat reads inside a session don't hit
  // the network again.
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
    // Update the cache immediately so the UI reflects the freshly created
    // profile without a redundant read.
    _cache[uid] = profile;
  }

  Future<UserProfile?> getProfile(String uid, {bool forceRefresh = false}) async {
    if (!forceRefresh && _cache[uid] != null) {
      return _cache[uid];
    }
    final doc = await _firestore
        .collection(AppConstants.firestoreUsersCollection)
        .doc(uid)
        .get(const GetOptions(source: Source.serverAndCache));
    if (doc.exists) {
      final profile = UserProfile.fromFirestore(doc);
      _cache[uid] = profile;
      return profile;
    }
    return null;
  }

  void clearCache() => _cache.clear();
}
