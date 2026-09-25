import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quoteflow/core/localization/app_localizations.dart';
import 'package:quoteflow/core/utils/auth_error_handler.dart';
import 'package:quoteflow/core/theme/app_theme.dart';
import 'package:quoteflow/shared/providers/auth_provider.dart';
import 'package:quoteflow/shared/providers/locale_provider.dart';
import 'package:quoteflow/shared/providers/theme_provider.dart';
import 'package:quoteflow/shared/widgets/app_page.dart';
import 'package:quoteflow/shared/widgets/app_page_header.dart';
import 'package:quoteflow/shared/widgets/app_status_banner.dart';
import 'package:quoteflow/shared/widgets/section_header.dart';
import 'package:quoteflow/features/settings/presentation/widgets/about_card.dart';
import 'package:quoteflow/features/settings/presentation/widgets/appearance_language_cards.dart';
import 'package:quoteflow/features/settings/presentation/widgets/logout_confirmation.dart';
import 'package:quoteflow/features/settings/presentation/widgets/profile_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isSigningOut = false;
  AuthErrorCode? _signOutFailure;

  Future<void> _signOut() async {
    if (!mounted || _isSigningOut) return;
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isBusy) return;

    setState(() {
      _isSigningOut = true;
      _signOutFailure = null;
    });

    AuthErrorCode? failure;
    try {
      await authProvider.signOut();
      failure = authProvider.failure;
    } catch (_) {
      failure = AuthErrorCode.unknown;
    }

    if (!mounted) return;
    setState(() {
      _isSigningOut = false;
      _signOutFailure = failure;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final hasPersistenceFailure =
        themeProvider.hasPersistenceFailure ||
        localeProvider.hasPersistenceFailure;
    final signOutMessage = _signOutFailure == null
        ? null
        : _signOutFailure == AuthErrorCode.signOutFailed
        ? l10n.signOutFailed
        : l10n.authError(_signOutFailure!);

    return AppPage(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final useHorizontalPreferences =
              constraints.maxWidth >= AppBreakpoints.compact;
          final appearanceCard = SettingsAppearanceCard(
            selectedMode: themeProvider.mode,
            onModeChanged: (mode) => unawaited(themeProvider.setMode(mode)),
          );
          final languageCard = SettingsLanguageCard(
            selectedLanguageCode: localeProvider.locale.languageCode,
            onLanguageChanged: (languageCode) =>
                unawaited(localeProvider.setLocale(Locale(languageCode))),
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppPageHeader(
                title: l10n.settings,
                subtitle: l10n.settingsSubtitle,
              ),
              if (hasPersistenceFailure) ...[
                const SizedBox(height: AppSpacing.lg),
                AppStatusBanner(
                  type: AppStatusBannerType.warning,
                  message: l10n.preferenceSaveError,
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(title: l10n.profile),
              const SizedBox(height: AppSpacing.sm),
              SettingsProfileCard(
                displayName: authProvider.displayName,
                displayEmail: authProvider.displayEmail,
                guestName: l10n.guest,
              ),
              const SizedBox(height: AppSpacing.xl),
              if (useHorizontalPreferences)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: appearanceCard),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: languageCard),
                  ],
                )
              else ...[
                appearanceCard,
                const SizedBox(height: AppSpacing.md),
                languageCard,
              ],
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(title: l10n.about),
              const SizedBox(height: AppSpacing.sm),
              SettingsAboutCard(),
              const SizedBox(height: AppSpacing.xl),
              if (signOutMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                AppStatusBanner(
                  type: AppStatusBannerType.error,
                  title: l10n.error,
                  message: signOutMessage,
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              SettingsLogoutAction(
                isBusy: _isSigningOut || authProvider.isBusy,
                onConfirmed: _signOut,
              ),
            ],
          );
        },
      ),
    );
  }
}
