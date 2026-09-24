import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_confirm_dialog.dart';
import '../../../core/widgets/section_header.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../vocabulary/data/language_storage.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);
    final themeController = ThemeControllerScope.of(context);
    final localeController = LocaleControllerScope.of(context);
    final auth = AuthControllerScope.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SectionHeader(title: l.account),
          AppCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                    child: Text(
                      (auth.displayName.isNotEmpty ? auth.displayName[0] : '?')
                          .toUpperCase(),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          auth.displayName.isNotEmpty
                              ? auth.displayName
                              : l.appName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          auth.displayEmail,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          SectionHeader(title: l.appearance),
          AppCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: Text(l.theme),
                  subtitle: Text(_themeLabel(themeController.themeMode, l)),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      _ThemeChip(
                        label: l.lightMode,
                        icon: Icons.light_mode_rounded,
                        selected: themeController.themeMode == ThemeMode.light,
                        onTap: () =>
                            themeController.setThemeMode(ThemeMode.light),
                      ),
                      const SizedBox(width: 8),
                      _ThemeChip(
                        label: l.darkMode,
                        icon: Icons.dark_mode_rounded,
                        selected: themeController.themeMode == ThemeMode.dark,
                        onTap: () =>
                            themeController.setThemeMode(ThemeMode.dark),
                      ),
                      const SizedBox(width: 8),
                      _ThemeChip(
                        label: l.systemDefault,
                        icon: Icons.settings_suggest_rounded,
                        selected: themeController.themeMode == ThemeMode.system,
                        onTap: () =>
                            themeController.setThemeMode(ThemeMode.system),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 0),

                ListTile(
                  leading: const Icon(Icons.language_rounded),
                  title: Text(l.language),
                  subtitle: Text(
                    localeController.locale.languageCode == 'ar'
                        ? l.arabic
                        : l.english,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: Text(l.english),
                          selected:
                              localeController.locale.languageCode == 'en',
                          onSelected: (_) =>
                              localeController.setLocale(const Locale('en')),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: Text(l.arabic),
                          selected:
                              localeController.locale.languageCode == 'ar',
                          onSelected: (_) =>
                              localeController.setLocale(const Locale('ar')),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          SectionHeader(title: l.data),
          AppCard(
            child: ListTile(
              leading: Icon(
                Icons.restart_alt_rounded,
                color: colorScheme.error,
              ),
              title: Text(l.resetAppData),
              subtitle: Text(l.resetAppDataDesc),
              onTap: () => _showResetDialog(context),
            ),
          ),

          const SizedBox(height: 16),
          AppCard(
            child: ListTile(
              leading: Icon(Icons.logout_rounded, color: colorScheme.error),
              title: Text(l.logout),
              subtitle: Text(l.logoutMessage),
              onTap: () => _showLogoutDialog(context),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _themeLabel(ThemeMode mode, AppLocalizations l) {
    return switch (mode) {
      ThemeMode.light => l.lightMode,
      ThemeMode.dark => l.darkMode,
      ThemeMode.system => l.systemDefault,
    };
  }

  void _showResetDialog(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final confirmed = await showConfirmDialog(
      context,
      title: l.resetAppData,
      message: l.resetAppDataMessage,
      confirmLabel: l.reset,
    );
    if (confirmed != true) return;
    await LanguageStorage().resetAllData();
    await LanguageStorage().initializeDefaultWords();
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l.dataResetSuccess)));
  }

  void _showLogoutDialog(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final confirmed = await showConfirmDialog(
      context,
      title: l.logoutConfirm,
      message: l.logoutMessage,
      confirmLabel: l.logout,
    );
    if (confirmed != true || !context.mounted) return;
    await AuthControllerScope.of(context).signOut();
    if (!context.mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
  }
}

class _ThemeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ChoiceChip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 4),
            Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
          ],
        ),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
