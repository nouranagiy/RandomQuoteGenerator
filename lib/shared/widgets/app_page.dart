import 'package:flutter/material.dart';
import 'package:quoteflow/core/theme/app_theme.dart';

enum AppPageWidth { standard, form, onboarding }

class AppPage extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final AppPageWidth width;
  final bool scrollable;
  final bool safeArea;
  final ScrollController? scrollController;
  final ScrollPhysics? physics;

  const AppPage({
    super.key,
    required this.child,
    this.padding,
    this.width = AppPageWidth.standard,
    this.scrollable = true,
    this.safeArea = true,
    this.scrollController,
    this.physics,
  });

  @override
  Widget build(BuildContext context) {
    final content = Center(
      child: Padding(
        padding:
            padding ??
            const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xl,
            ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: _maxWidth(width)),
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    );
    final page = safeArea ? SafeArea(child: content) : content;

    if (!scrollable) return page;
    return SingleChildScrollView(
      controller: scrollController,
      physics: physics,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: page,
    );
  }

  double _maxWidth(AppPageWidth value) {
    return switch (value) {
      AppPageWidth.standard => AppSizes.contentMaxWidth,
      AppPageWidth.form => AppSizes.formMaxWidth,
      AppPageWidth.onboarding => AppSizes.onboardingMaxWidth,
    };
  }
}
