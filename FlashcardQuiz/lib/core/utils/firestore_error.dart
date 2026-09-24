import 'package:firebase_core/firebase_core.dart';

import '../localization/app_localizations.dart';

/// Maps a Firestore/Firebase error to a localized user-friendly message.
String firestoreErrorMessage(AppLocalizations loc, Object error) {
  if (error is FirebaseException) {
    switch (error.code) {
      case 'permission-denied':
        return loc.firestorePermissionDenied;
      case 'unavailable':
        return loc.firestoreUnavailable;
      case 'network-request-failed':
        return loc.networkError;
      case 'not-found':
        return loc.notFound;
      case 'already-exists':
        return loc.alreadyExists;
      default:
        return error.message?.isNotEmpty == true
            ? error.message!
            : loc.genericError;
    }
  }

  if (error is StateError) {
    return loc.firestoreUnavailable;
  }

  return loc.genericError;
}
