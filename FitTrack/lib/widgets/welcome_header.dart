import 'package:flutter/material.dart';
import '../generated/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../features/profile/data/profile_provider.dart';
import '../core/constants/app_constants.dart';

class WelcomeHeader extends StatelessWidget {
  final bool showGreeting;

  const WelcomeHeader({super.key, this.showGreeting = true});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final profile = context.watch<ProfileProvider>();

    if (profile.isLoading) {
      return const SizedBox(
        height: 48,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: SizedBox(
            width: 140,
            height: 16,
            child: LinearProgressIndicator(minHeight: 2),
          ),
        ),
      );
    }

    if (profile.hasError) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.welcomeFallback,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.profileLoadError,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => context.read<ProfileProvider>().refreshProfile(),
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ],
      );
    }

    final name = profile.displayName;
    final welcomeText = name.isNotEmpty
        ? l10n.welcome(name)
        : l10n.welcomeFallback;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          welcomeText,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
        if (showGreeting) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.keepMoving,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}
