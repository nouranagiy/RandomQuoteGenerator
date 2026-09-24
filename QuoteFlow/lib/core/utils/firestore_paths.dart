import 'package:quoteflow/core/constants/app_constants.dart';

class FirestorePaths {
  FirestorePaths._();

  static String userProfile(String uid) => '${AppConstants.firestoreUsersCollection}/$uid';
}
