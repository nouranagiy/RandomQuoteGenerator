import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';

class OnboardingStore {
  OnboardingStore(this._isCompleted);

  bool _isCompleted;

  bool get isCompleted => _isCompleted;

  static Future<OnboardingStore> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return OnboardingStore(
        prefs.getBool(AppConstants.onboardingCompleted) ?? false,
      );
    } catch (_) {
      return OnboardingStore(false);
    }
  }

  Future<bool> complete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = await prefs.setBool(AppConstants.onboardingCompleted, true);
      if (saved) _isCompleted = true;
      return saved;
    } catch (_) {
      return false;
    }
  }
}

class OnboardingScope extends InheritedWidget {
  const OnboardingScope({super.key, required this.store, required super.child});

  final OnboardingStore store;

  static OnboardingStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<OnboardingScope>();
    assert(scope != null, 'No OnboardingScope found in context');
    return scope!.store;
  }

  @override
  bool updateShouldNotify(OnboardingScope oldWidget) =>
      store.isCompleted != oldWidget.store.isCompleted;
}
