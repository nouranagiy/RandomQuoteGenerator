import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quoteflow/shared/providers/theme_provider.dart';
import 'package:quoteflow/shared/providers/locale_provider.dart';
import 'package:quoteflow/shared/providers/auth_provider.dart';
import 'package:quoteflow/core/localization/app_localizations.dart';
import 'package:quoteflow/shared/widgets/section_header.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SectionHeader(title: l10n.profile),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                    child: Text(
                      (authProvider.displayName.isNotEmpty
                              ? authProvider.displayName[0]
                              : '?')
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
                          authProvider.displayName.isNotEmpty
                              ? authProvider.displayName
                              : l10n.guest,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          authProvider.displayEmail,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          SectionHeader(title: l10n.theme),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                _buildThemeOption(
                  context,
                  title: l10n.systemDefault,
                  icon: Icons.brightness_auto_outlined,
                  isSelected: themeProvider.mode == ThemeModeOption.system,
                  onTap: () => themeProvider.setMode(ThemeModeOption.system),
                ),
                Divider(height: 1, indent: 16, endIndent: 16, color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                _buildThemeOption(
                  context,
                  title: l10n.lightMode,
                  icon: Icons.light_mode_outlined,
                  isSelected: themeProvider.mode == ThemeModeOption.light,
                  onTap: () => themeProvider.setMode(ThemeModeOption.light),
                ),
                Divider(height: 1, indent: 16, endIndent: 16, color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                _buildThemeOption(
                  context,
                  title: l10n.darkMode,
                  icon: Icons.dark_mode_outlined,
                  isSelected: themeProvider.mode == ThemeModeOption.dark,
                  onTap: () => themeProvider.setMode(ThemeModeOption.dark),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SectionHeader(title: l10n.language),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                _buildLanguageOption(
                  context,
                  title: l10n.english,
                  isSelected: localeProvider.locale.languageCode == 'en',
                  onTap: () => localeProvider.setLocale(const Locale('en')),
                ),
                Divider(height: 1, indent: 16, endIndent: 16, color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                _buildLanguageOption(
                  context,
                  title: l10n.arabic,
                  isSelected: localeProvider.locale.languageCode == 'ar',
                  onTap: () => localeProvider.setLocale(const Locale('ar')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SectionHeader(title: l10n.about),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(l10n.version, style: Theme.of(context).textTheme.bodyMedium),
                  Text('1.0.0', style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(context),
              icon: Icon(Icons.logout_rounded, size: 18, color: colorScheme.error),
              label: Text(
                l10n.signOut,
                style: TextStyle(color: colorScheme.error),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: colorScheme.error.withValues(alpha: 0.3)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, size: 22, color: isSelected ? colorScheme.primary : null),
      title: Text(title, style: TextStyle(
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        color: isSelected ? colorScheme.primary : null,
      )),
      trailing: isSelected
          ? Icon(Icons.check_rounded, size: 20, color: colorScheme.primary)
          : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      title: Text(title, style: TextStyle(
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        color: isSelected ? colorScheme.primary : null,
      )),
      trailing: isSelected
          ? Icon(Icons.check_rounded, size: 20, color: colorScheme.primary)
          : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.logout),
        content: Text(l10n.logoutConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthProvider>().signOut();
            },
            child: Text(
              l10n.confirm,
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}
