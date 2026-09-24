import 'package:flutter/material.dart';

import '../core/localization/app_localizations.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showLogo;
  final bool centerTitle;

  const AppHeader({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.showLogo = true,
    this.centerTitle = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final logoAndName = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primary, colorScheme.tertiary],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.auto_stories,
            color: colorScheme.onPrimary,
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          loc.appName,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );

    return AppBar(
      leading: leading,
      title: showLogo ? logoAndName : Text(title ?? loc.appName),
      centerTitle: centerTitle,
      actions: actions,
    );
  }
}
