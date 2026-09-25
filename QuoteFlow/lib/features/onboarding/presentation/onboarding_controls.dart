import 'package:flutter/material.dart';
import 'package:quoteflow/core/theme/app_theme.dart';
import 'package:quoteflow/shared/widgets/app_logo.dart';
import 'package:quoteflow/shared/widgets/custom_button.dart';

class OnboardingHeader extends StatelessWidget {
  final String tagline;
  final String skipLabel;
  final VoidCallback? onSkip;

  const OnboardingHeader({
    super.key,
    required this.tagline,
    required this.skipLabel,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AppLogo(size: AppSizes.logoMd),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            tagline,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        TextButton(onPressed: onSkip, child: Text(skipLabel)),
      ],
    );
  }
}

class OnboardingFooter extends StatelessWidget {
  final List<String> pageLabels;
  final int currentPage;
  final String actionLabel;
  final IconData? doneIcon;
  final VoidCallback? onPressed;
  final bool isLoading;

  const OnboardingFooter({
    super.key,
    required this.pageLabels,
    required this.currentPage,
    required this.actionLabel,
    required this.onPressed,
    this.doneIcon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = currentPage >= pageLabels.length - 1;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(pageLabels.length, (index) {
            final selected = index == currentPage;
            return Semantics(
              container: true,
              selected: selected,
              label: pageLabels[index],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                child: AnimatedContainer(
                  duration: AppMotion.standard,
                  curve: AppMotion.standardCurve,
                  width: selected ? AppSpacing.md : AppSpacing.xs,
                  height: AppSpacing.xs,
                  decoration: BoxDecoration(
                    color: selected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: AppSpacing.lg),
        CustomButton(
          label: actionLabel,
          icon: isLast ? doneIcon : null,
          isLoading: isLoading,
          onPressed: isLoading ? null : onPressed,
          width: double.infinity,
        ),
      ],
    );
  }
}
