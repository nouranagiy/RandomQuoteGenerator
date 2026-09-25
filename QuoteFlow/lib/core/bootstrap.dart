import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:quoteflow/core/utils/prefs.dart';
import 'package:quoteflow/firebase_options.dart';
import 'package:quoteflow/shared/providers/auth_provider.dart';

Future<void> appBootstrap(AuthProvider authProvider) async {
  final firebase = Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Future.wait<Object?>([Prefs.preload(), firebase]);
  configureFirestore();
  await authProvider.initialize();
}

void configureFirestore() {
  try {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (_) {}
}
