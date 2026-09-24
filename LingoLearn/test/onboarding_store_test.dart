import 'package:flutter_test/flutter_test.dart';
import 'package:lingolearn/core/routing/app_router.dart';
import 'package:lingolearn/core/routing/splash_screen.dart';
import 'package:lingolearn/features/onboarding/data/onboarding_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OnboardingStore', () {
    test('defaults to not completed when nothing is persisted', () async {
      SharedPreferences.setMockInitialValues({});
      final store = await OnboardingStore.load();
      expect(store.isCompleted, isFalse);
    });

    test('persists completion so later loads see it', () async {
      SharedPreferences.setMockInitialValues({});
      final store = await OnboardingStore.load();
      final saved = await store.complete();
      expect(saved, isTrue, reason: 'a successful write must report success');
      expect(store.isCompleted, isTrue);

      final reloaded = await OnboardingStore.load();
      expect(reloaded.isCompleted, isTrue);
    });

    test('completing twice stays idempotent and true', () async {
      SharedPreferences.setMockInitialValues({});
      final store = await OnboardingStore.load();
      expect(await store.complete(), isTrue);
      expect(await store.complete(), isTrue);
      expect(store.isCompleted, isTrue);
    });
  });

  group('initialRouteFor', () {
    test('fresh unauthenticated launch goes to onboarding', () {
      expect(
        initialRouteFor(onboardingCompleted: false, isAuthenticated: false),
        AppRoutes.onboarding,
      );
    });

    test('returning unauthenticated users go to login', () {
      expect(
        initialRouteFor(onboardingCompleted: true, isAuthenticated: false),
        AppRoutes.login,
      );
    });

    test('authenticated users go straight home', () {
      expect(
        initialRouteFor(onboardingCompleted: false, isAuthenticated: true),
        AppRoutes.home,
      );
      expect(
        initialRouteFor(onboardingCompleted: true, isAuthenticated: true),
        AppRoutes.home,
      );
    });
  });
}
