import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

class AppHeader extends StatelessWidget {
  final List<Widget> actions;

  const AppHeader({super.key, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.translate_rounded,
              size: 20,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            l.appName,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const Spacer(),
          ...actions,
        ],
      ),
    );
  }
}
