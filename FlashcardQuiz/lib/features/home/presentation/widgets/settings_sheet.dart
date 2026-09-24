import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';

class SettingsSheet extends StatelessWidget {
  final VoidCallback onLogout;
  final ValueChanged<ThemeMode> onSetThemeMode;
  final ThemeMode currentThemeMode;
  final String languageCode;
  final ValueChanged<String> onLanguageChanged;

  const SettingsSheet({
    super.key,
    required this.onLogout,
    required this.onSetThemeMode,
    required this.currentThemeMode,
    required this.languageCode,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              loc.settings,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            _SectionTitle(label: loc.language),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'en', label: Text(loc.english)),
                ButtonSegment(value: 'ar', label: Text(loc.arabic)),
              ],
              selected: {languageCode},
              onSelectionChanged: (selected) {
                if (selected.isNotEmpty) {
                  onLanguageChanged(selected.first);
                }
              },
            ),
            const SizedBox(height: 24),
            _SectionTitle(label: loc.theme),
            const SizedBox(height: 8),
            SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: const Icon(Icons.brightness_auto_outlined, size: 18),
                  label: Text(loc.systemDefault),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: const Icon(Icons.light_mode_outlined, size: 18),
                  label: Text(loc.lightMode),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: const Icon(Icons.dark_mode_outlined, size: 18),
                  label: Text(loc.darkMode),
                ),
              ],
              selected: {currentThemeMode},
              onSelectionChanged: (selected) {
                if (selected.isNotEmpty) {
                  onSetThemeMode(selected.first);
                }
              },
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.logout, color: colorScheme.error),
              title: Text(
                loc.logout,
                style: TextStyle(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onLogout();
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;

  const _SectionTitle({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
