import 'package:flutter/material.dart';

class AppIconTile extends StatelessWidget {
  final IconData icon;
  final double size;
  final double? iconSize;
  final bool circle;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? iconColor;

  const AppIconTile({
    super.key,
    required this.icon,
    this.size = 48,
    this.iconSize,
    this.circle = false,
    this.borderRadius = 14,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = backgroundColor ?? colorScheme.primaryContainer;
    final foreground = iconColor ?? colorScheme.primary;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : BorderRadius.circular(borderRadius),
      ),
      child: Icon(icon, size: iconSize ?? size * 0.55, color: foreground),
    );
  }
}
