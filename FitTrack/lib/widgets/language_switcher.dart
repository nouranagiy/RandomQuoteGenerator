import 'package:flutter/material.dart';
import '../generated/l10n/app_localizations.dart';

class LanguageSwitcher extends StatelessWidget {
  final Locale currentLocale;
  final ValueChanged<Locale> onChanged;

  const LanguageSwitcher({
    super.key,
    required this.currentLocale,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SegmentedButton<Locale>(
      segments: [
        ButtonSegment(
          value: const Locale('en'),
          label: Text(l10n.english),
        ),
        ButtonSegment(
          value: const Locale('ar'),
          label: Text(l10n.arabic),
        ),
      ],
      selected: {currentLocale},
      onSelectionChanged: (selected) {
        if (selected.isNotEmpty) {
          onChanged(selected.first);
        }
      },
    );
  }
}
