import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper that caches the [SharedPreferences] singleton so screens
/// don't call the async `getInstance()` repeatedly on every interaction.
class Prefs {
  Prefs._();

  static SharedPreferences? _instance;

  /// Returns the cached instance, initializing it on first use.
  static Future<SharedPreferences> get instance async =>
      _instance ??= await SharedPreferences.getInstance();

  /// Preloads the preferences before runApp so the first screen build is fast.
  static Future<void> preload() async {
    _instance ??= await SharedPreferences.getInstance();
  }

  @visibleForTesting
  static void resetForTesting() {
    _instance = null;
  }
}
