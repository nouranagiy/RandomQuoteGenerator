import 'package:flutter/material.dart';
import 'package:quoteflow/core/theme/app_theme.dart';
import 'package:quoteflow/shared/widgets/app_logo.dart';

class AppAuthForm extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? footer;
  final GlobalKey<FormState>? formKey;
  final ScrollController? scrollController;
  final ScrollPhysics? physics;
  final bool scrollable;
  final bool safeArea;
  final EdgeInsetsGeometry? padding;
  final double logoSize;
  final Widget? logo;

  const AppAuthForm({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.footer,
    this.formKey,
    this.scrollController,
    this.physics,
    this.scrollable = true,
    this.safeArea = true,
    this.padding,
    this.logoSize = AppSizes.logoLg,
    this.logo,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(child: logo ?? AppLogo(size: logoSize)),
        const SizedBox(height: AppSpacing.xl),
        Text(
          title,
          style: Theme.of(context).textTheme.displaySmall,
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: AppSpacing.xl),
        Form(key: formKey, child: child),
        if (footer != null) ...[const SizedBox(height: AppSpacing.lg), footer!],
      ],
    );
    final constrained = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: AppSizes.formMaxWidth),
      child: content,
    );
    final padded = Padding(
      padding:
          padding ??
          const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
      child: constrained,
    );
    final body = scrollable
        ? SingleChildScrollView(
            controller: scrollController,
            physics: physics,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Center(child: padded),
          )
        : Center(child: padded);

    return safeArea ? SafeArea(child: body) : body;
  }
}
