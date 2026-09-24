import 'package:flutter/material.dart';

class QuizAnswerOption extends StatelessWidget {
  final String option;
  final bool isCorrect;
  final bool isSelected;
  final bool revealed;
  final VoidCallback onTap;

  const QuizAnswerOption({
    super.key,
    required this.option,
    required this.isCorrect,
    required this.isSelected,
    required this.revealed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Color? backgroundColor;
    Color borderColor = colorScheme.outlineVariant;
    IconData? statusIcon;
    Color? iconColor;

    if (revealed) {
      if (isCorrect) {
        backgroundColor = Colors.green.withValues(alpha: 0.12);
        borderColor = Colors.green;
        statusIcon = Icons.check_circle_rounded;
        iconColor = Colors.green;
      } else if (isSelected) {
        backgroundColor = Colors.red.withValues(alpha: 0.12);
        borderColor = Colors.red;
        statusIcon = Icons.cancel_rounded;
        iconColor = Colors.red;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: revealed ? null : onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  option,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              if (statusIcon != null) Icon(statusIcon, color: iconColor),
            ],
          ),
        ),
      ),
    );
  }
}
