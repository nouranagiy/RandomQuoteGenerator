import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String text;

  final IconData? icon;

  final VoidCallback? onPressed;

  final bool isLoading;

  final bool disabled;

  final AppButtonType type;

  final double? width;

  const AppButton({
    super.key,
    required this.text,
    this.icon,
    this.onPressed,
    this.isLoading = false,
    this.disabled = false,
    this.type = AppButtonType.filled,
    this.width,
  });

  bool get _isDisabled => disabled || isLoading || onPressed == null;

  @override
  Widget build(BuildContext context) {
    final onTap = _isDisabled ? null : onPressed;

    final content = isLoading
        ? const _LoadingIndicator()
        : (icon != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon),
                    const SizedBox(width: 8),
                    Flexible(child: Text(text)),
                  ],
                )
              : Text(text));

    return SizedBox(
      height: 52,
      width: width,
      child: switch (type) {
        AppButtonType.filled => FilledButton(onPressed: onTap, child: content),
        AppButtonType.outlined => OutlinedButton(
          onPressed: onTap,
          child: content,
        ),
        AppButtonType.elevated => ElevatedButton(
          onPressed: onTap,
          child: content,
        ),
      },
    );
  }
}

enum AppButtonType { filled, outlined, elevated }

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 22,
      height: 22,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: colorScheme.onPrimary,
      ),
    );
  }
}
