import 'package:flutter/material.dart';

class AppProgressBar extends StatelessWidget {
  final double value;
  final double minHeight;
  final double radius;

  const AppProgressBar({
    super.key,
    required this.value,
    this.minHeight = 8,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: LinearProgressIndicator(value: value, minHeight: minHeight),
    );
  }
}
