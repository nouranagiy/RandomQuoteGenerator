import 'package:flutter/material.dart';
import 'package:quoteflow/core/localization/app_localizations.dart';
import 'package:quoteflow/core/theme/app_theme.dart';
import 'package:quoteflow/shared/widgets/app_logo.dart';
import 'package:quoteflow/shared/widgets/app_page.dart';
import 'package:quoteflow/shared/widgets/app_status_banner.dart';
import 'package:quoteflow/shared/widgets/app_surface.dart';
import 'package:quoteflow/shared/widgets/custom_button.dart';

class StartupErrorView extends StatelessWidget {
  final VoidCallback? onRetry;

  const StartupErrorView({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: AppPage(
        width: AppPageWidth.form,
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Center(
          child: AppSurface(
            level: AppSurfaceLevel.elevated,
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppLogo(size: AppSizes.logoLg),
                const SizedBox(height: AppSpacing.xl),
                AppStatusBanner(
                  type: AppStatusBannerType.error,
                  title: l10n.startupError,
                  message: l10n.startupErrorDescription,
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: AppSpacing.lg),
                  CustomButton(
                    label: l10n.retry,
                    icon: Icons.refresh_rounded,
                    onPressed: onRetry,
                    width: double.infinity,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
