import 'package:flutter/material.dart';
import 'package:quoteflow/core/localization/app_localizations.dart';
import 'package:quoteflow/shared/widgets/app_status_banner.dart';

class AuthErrorBanner extends StatelessWidget {
  final String message;
  final String? title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? action;

  const AuthErrorBanner({
    super.key,
    required this.message,
    this.title,
    this.actionLabel,
    this.onAction,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return AppStatusBanner(
      type: AppStatusBannerType.error,
      title: title ?? context.l10n.error,
      message: message,
      actionLabel: actionLabel,
      onAction: onAction,
      action: action,
    );
  }
}
