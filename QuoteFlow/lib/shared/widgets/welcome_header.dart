import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quoteflow/core/localization/app_localizations.dart';
import 'package:quoteflow/shared/providers/auth_provider.dart';

/// Displays the current authenticated user's name from the in-memory
/// profile already loaded by [AuthProvider]. No extra Firestore reads.
class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final auth = context.watch<AuthProvider>();

    // While the profile is still being loaded, show a small inline loading
    // state instead of blocking the whole screen.
    if (auth.isLoading) {
      return Row(
        children: [
          Text(
            l10n.welcome,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      );
    }

    // Use the localized neutral fallback when the name/profile is unknown,
    // never a stale name from a previous account.
    final name = auth.displayName.isNotEmpty ? auth.displayName : l10n.guest;
    return _buildWelcome(context, name);
  }

  Widget _buildWelcome(BuildContext context, String name) {
    final l10n = context.l10n;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final welcomeText = isArabic ? '${l10n.welcome}، $name 👋' : '${l10n.welcome}, $name 👋';

    return Text(
      welcomeText,
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
