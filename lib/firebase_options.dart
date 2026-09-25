import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

/// Firebase configuration options.
///
/// To generate this file, run:
///   flutterfire configure
///
/// Or manually replace this file with your Firebase options.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // TODO: Replace these placeholder values with your actual Firebase config.
    // Run `flutterfire configure` to auto-generate this file.
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCjSSmeUvlQBGdItS7IGXggRftiTE0DlG8',
    appId: '1:431016300630:android:8e82266ed0cb0d996f6bf7',
    messagingSenderId: '431016300630',
    projectId: 'quoteflow-1f7f7',
    storageBucket: 'quoteflow-1f7f7.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyATYpQYTdhuJFnpu4MEJ5uEuqLVm8Byfak',
    appId: '1:431016300630:ios:58ea6bdc643433356f6bf7',
    messagingSenderId: '431016300630',
    projectId: 'quoteflow-1f7f7',
    storageBucket: 'quoteflow-1f7f7.firebasestorage.app',
    iosBundleId: 'com.example.quoteflow',
  );
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: 'YOUR_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
    authDomain: 'YOUR_AUTH_DOMAIN',
  );
}
