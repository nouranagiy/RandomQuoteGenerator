import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final DateTime createdAt;

  const UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.createdAt,
  });

  factory UserProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final storedUid = data?['uid'];
    final storedName = data?['name'];
    final storedEmail = data?['email'];
    return UserProfile(
      uid: doc.id.isNotEmpty
          ? doc.id
          : storedUid is String
          ? storedUid
          : '',
      name: storedName is String ? storedName : '',
      email: storedEmail is String ? storedEmail : '',
      createdAt: _parseCreatedAt(data?['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

DateTime _parseCreatedAt(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
  }
  if (value is String) {
    return DateTime.tryParse(value) ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
  }
  return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
}
