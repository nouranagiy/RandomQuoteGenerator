import 'package:flutter/material.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/onboarding_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/activity/presentation/add_activity_screen.dart';
import '../../features/activity/presentation/edit_activity_screen.dart';
import '../../features/activity/presentation/activity_history_screen.dart';
import '../../features/activity/presentation/weekly_progress_screen.dart';
import '../../features/home/presentation/settings_screen.dart';
import '../../models/fitness_entry.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String home = '/home';
  static const String addActivity = '/add-activity';
  static const String editActivity = '/edit-activity';
  static const String activityHistory = '/activity-history';
  static const String weeklyProgress = '/weekly-progress';
  static const String settingsPage = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signUp:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case addActivity:
        return MaterialPageRoute(builder: (_) => const AddActivityScreen());
      case editActivity:
        final entry = settings.arguments as FitnessEntry;
        return MaterialPageRoute(
          builder: (_) => EditActivityScreen(entry: entry),
        );
      case activityHistory:
        return MaterialPageRoute(builder: (_) => const ActivityHistoryScreen());
      case weeklyProgress:
        return MaterialPageRoute(builder: (_) => const WeeklyProgressScreen());
      case settingsPage:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route not found: ${settings.name}')),
          ),
        );
    }
  }
}
