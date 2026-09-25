import 'package:flutter/material.dart';
import 'package:quoteflow/core/theme/app_theme.dart';
import 'package:quoteflow/features/onboarding/presentation/onboarding_visual_panel.dart';

class OnboardingPageContent extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final OnboardingVisualAccent accent;

  const OnboardingPageContent({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= AppBreakpoints.compact;
        final copy = _OnboardingCopy(
          title: title,
          description: description,
          centered: !isWide,
        );
        final visual = OnboardingVisualPanel(
          title: title,
          icon: icon,
          accent: accent,
        );

        if (isWide) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: copy),
                const SizedBox(width: AppSpacing.xxl),
                Expanded(child: visual),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              visual,
              const SizedBox(height: AppSpacing.xl),
              copy,
            ],
          ),
        );
      },
    );
  }
}

class _OnboardingCopy extends StatelessWidget {
  final String title;
  final String description;
  final bool centered;

  const _OnboardingCopy({
    required this.title,
    required this.description,
    required this.centered,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final textAlign = centered ? TextAlign.center : TextAlign.start;
    return Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(
            title,
            textAlign: textAlign,
            style: textTheme.headlineMedium,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          description,
          textAlign: textAlign,
          style: textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
