import 'package:flutter/material.dart';
import 'package:quoteflow/core/theme/app_theme.dart';

class AuthFooterLink extends StatelessWidget {
  final String prompt;
  final String actionLabel;
  final VoidCallback? onPressed;

  const AuthFooterLink({
    super.key,
    required this.prompt,
    required this.actionLabel,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.xxs,
      runSpacing: AppSpacing.xs,
      children: [
        Text(
          prompt,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(onPressed: onPressed, child: Text(actionLabel)),
      ],
    );
  }
}
