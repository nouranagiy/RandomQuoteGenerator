import 'package:flutter/material.dart';
import '../generated/l10n/app_localizations.dart';
import '../core/theme/app_theme.dart';

class ThemeSwitcher extends StatelessWidget {
  final ThemeMode currentMode;
  final ValueChanged<ThemeMode> onChanged;

  const ThemeSwitcher({
    super.key,
    required this.currentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SegmentedButton<ThemeMode>(
      segments: [
        ButtonSegment(
          value: ThemeMode.light,
          icon: const Icon(Icons.light_mode_outlined, size: 18),
          label: Text(l10n.lightMode),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          icon: const Icon(Icons.dark_mode_outlined, size: 18),
          label: Text(l10n.darkMode),
        ),
        ButtonSegment(
          value: ThemeMode.system,
          icon: const Icon(Icons.phone_android, size: 18),
          label: Text(l10n.systemDefault),
        ),
      ],
      selected: {currentMode},
      onSelectionChanged: (selected) {
        if (selected.isNotEmpty) {
          final mode = selected.first;
          AppTheme.saveThemeMode(mode);
          onChanged(mode);
        }
      },
      style: SegmentedButton.styleFrom(
        textStyle: theme.textTheme.labelSmall,
      ),
    );
  }
}
