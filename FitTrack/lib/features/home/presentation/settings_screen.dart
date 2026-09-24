import 'package:flutter/material.dart';
import '../../../generated/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/localization/locale_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/theme_mode_manager.dart';
import '../../profile/data/profile_provider.dart';
import '../../../widgets/language_switcher.dart';
import '../../../widgets/theme_switcher.dart';
import '../../../widgets/confirmation_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final localeProvider = context.watch<LocaleProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final themeManager = context.watch<ThemeModeManager>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          if (profileProvider.user != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      profileProvider.displayName.isNotEmpty
                          ? profileProvider.displayName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profileProvider.displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          profileProvider.user!.email,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
          Text(
            l10n.language,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          LanguageSwitcher(
            currentLocale: localeProvider.locale,
            onChanged: (locale) => localeProvider.setLocale(locale),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            l10n.theme,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ThemeSwitcher(
            currentMode: themeManager.mode,
            onChanged: themeManager.setMode,
          ),
          const SizedBox(height: AppSpacing.huge),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirmed = await ConfirmationDialog.show(
                  context: context,
                  title: l10n.signOut,
                  content: l10n.signOutConfirm,
                  confirmLabel: l10n.confirm,
                  cancelLabel: l10n.cancel,
                  onConfirm: () {},
                );
                if (confirmed == true && context.mounted) {
                  profileProvider.clearProfile();
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRouter.login,
                      (_) => false,
                    );
                  }
                }
              },
              icon: const Icon(Icons.logout, size: 20),
              label: Text(l10n.signOut),
            ),
          ),
        ],
      ),
    );
  }
}
