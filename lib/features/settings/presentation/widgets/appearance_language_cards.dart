import 'package:flutter/material.dart';
import 'package:quoteflow/core/localization/app_localizations.dart';
import 'package:quoteflow/shared/providers/theme_provider.dart';
import 'package:quoteflow/shared/widgets/app_option_tile.dart';
import 'package:quoteflow/features/settings/presentation/widgets/settings_option_group.dart';

class SettingsAppearanceCard extends StatelessWidget {
  final ThemeModeOption selectedMode;
  final ValueChanged<ThemeModeOption> onModeChanged;

  const SettingsAppearanceCard({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SettingsOptionGroup(
      title: l10n.theme,
      description: l10n.appearanceSubtitle,
      icon: Icons.palette_outlined,
      options: [
        AppOptionTile(
          title: l10n.systemDefault,
          icon: Icons.brightness_auto_outlined,
          isSelected: selectedMode == ThemeModeOption.system,
          onTap: () => onModeChanged(ThemeModeOption.system),
        ),
        AppOptionTile(
          title: l10n.lightMode,
          icon: Icons.light_mode_outlined,
          isSelected: selectedMode == ThemeModeOption.light,
          onTap: () => onModeChanged(ThemeModeOption.light),
        ),
        AppOptionTile(
          title: l10n.darkMode,
          icon: Icons.dark_mode_outlined,
          isSelected: selectedMode == ThemeModeOption.dark,
          onTap: () => onModeChanged(ThemeModeOption.dark),
        ),
      ],
    );
  }
}

class SettingsLanguageCard extends StatelessWidget {
  final String selectedLanguageCode;
  final ValueChanged<String> onLanguageChanged;

  const SettingsLanguageCard({
    super.key,
    required this.selectedLanguageCode,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SettingsOptionGroup(
      title: l10n.language,
      description: l10n.languageSubtitle,
      icon: Icons.translate_rounded,
      options: [
        AppOptionTile(
          title: l10n.english,
          icon: Icons.language_rounded,
          isSelected: selectedLanguageCode == 'en',
          onTap: () => onLanguageChanged('en'),
        ),
        AppOptionTile(
          title: l10n.arabic,
          icon: Icons.format_textdirection_r_to_l_rounded,
          isSelected: selectedLanguageCode == 'ar',
          onTap: () => onLanguageChanged('ar'),
        ),
      ],
    );
  }
}
