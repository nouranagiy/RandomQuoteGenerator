import 'package:flutter/material.dart';
import 'package:quoteflow/core/theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final double? width;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = isOutlined ? colorScheme.primary : colorScheme.onPrimary;
    final content = AnimatedSwitcher(
      duration: AppMotion.fast,
      switchInCurve: AppMotion.standardCurve,
      switchOutCurve: AppMotion.standardCurve,
      child: isLoading
          ? SizedBox.square(
              key: const ValueKey(true),
              dimension: AppSizes.iconMd,
              child: CircularProgressIndicator(color: foreground),
            )
          : Row(
              key: const ValueKey(false),
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: AppSizes.iconMd),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Text(label),
              ],
            ),
    );

    final button = isOutlined
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            child: content,
          )
        : FilledButton(onPressed: isLoading ? null : onPressed, child: content);

    if (width == null) return button;
    return SizedBox(width: width, child: button);
  }
}
