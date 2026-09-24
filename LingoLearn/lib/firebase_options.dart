import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return android;
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDh5e3WdOWohfnggNBNwWsATCbBYCtGY9Q',
    appId: '1:73123567388:android:a4f8c7a34223a8ebe40cd9',
    messagingSenderId: '73123567388',
    projectId: 'lingolearn-9cc40',
    storageBucket: 'lingolearn-9cc40.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBnakkfMuMeVx-57jk7oQzUUia6opxZTbM',
    appId: '1:73123567388:ios:00ac0e57565559e2e40cd9',
    messagingSenderId: '73123567388',
    projectId: 'lingolearn-9cc40',
    storageBucket: 'lingolearn-9cc40.firebasestorage.app',
    iosBundleId: 'com.example.lingolearn',
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
