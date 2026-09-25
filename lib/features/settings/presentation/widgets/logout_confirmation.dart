import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quoteflow/core/localization/app_localizations.dart';
import 'package:quoteflow/core/theme/app_theme.dart';

class SettingsLogoutAction extends StatelessWidget {
  final bool isBusy;
  final Future<void> Function() onConfirmed;

  const SettingsLogoutAction({
    super.key,
    required this.isBusy,
    required this.onConfirmed,
  });

  Future<void> _showConfirmation(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => LogoutConfirmationDialog(onConfirmed: onConfirmed),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return OutlinedButton.icon(
      onPressed: isBusy ? null : () => unawaited(_showConfirmation(context)),
      icon: isBusy
          ? SizedBox.square(
              dimension: AppSizes.iconMd,
              child: CircularProgressIndicator(color: colorScheme.error),
            )
          : Icon(
              Icons.logout_rounded,
              size: AppSizes.iconMd,
              color: colorScheme.error,
            ),
      label: Text(
        l10n.signOut,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: colorScheme.error),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.error,
        side: BorderSide(
          color: colorScheme.error.withValues(alpha: AppOpacity.strong),
        ),
        minimumSize: const Size.fromHeight(AppSizes.touchTarget),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      ),
    );
  }
}

class LogoutConfirmationDialog extends StatefulWidget {
  final Future<void> Function() onConfirmed;

  const LogoutConfirmationDialog({super.key, required this.onConfirmed});

  @override
  State<LogoutConfirmationDialog> createState() =>
      _LogoutConfirmationDialogState();
}

class _LogoutConfirmationDialogState extends State<LogoutConfirmationDialog> {
  bool _isConfirming = false;

  void _confirm() {
    if (_isConfirming) return;
    setState(() => _isConfirming = true);
    unawaited(widget.onConfirmed());
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text(l10n.logout),
      content: Text(l10n.logoutConfirmation),
      actions: [
        TextButton(
          onPressed: _isConfirming ? null : () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: _isConfirming ? null : _confirm,
          style: TextButton.styleFrom(foregroundColor: colorScheme.error),
          child: Text(
            l10n.confirm,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: colorScheme.error),
          ),
        ),
      ],
    );
  }
}
