import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double? elevation;
  final BorderSide? border;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius = 16,
    this.elevation,
    this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      side: border ?? BorderSide(color: colorScheme.outlineVariant, width: 0.5),
    );

    final Widget inner = padding != null
        ? Padding(padding: padding!, child: child)
        : child;

    final card = Card(
      margin: EdgeInsets.zero,
      elevation: elevation ?? 0,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: inner,
    );

    if (onTap == null) return card;

    return InkWell(onTap: onTap, child: card);
  }
}
