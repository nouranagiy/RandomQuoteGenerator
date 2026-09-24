import 'package:flutter/material.dart';

import '../core/localization/app_localizations.dart';

class WelcomeHeader extends StatelessWidget {
  final String userName;
  final bool isLoading;

  const WelcomeHeader({
    super.key,
    required this.userName,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: isLoading
          ? Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsetsDirectional.only(end: 8),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                ),
                Text(
                  loc.loading,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            )
          : Text.rich(
              TextSpan(
                text: '${loc.welcome}, ',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
                children: [
                  TextSpan(
                    text: userName.isNotEmpty
                        ? userName
                        : loc.userDefaultFallback,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
