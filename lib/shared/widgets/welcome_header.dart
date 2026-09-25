import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quoteflow/core/localization/app_localizations.dart';
import 'package:quoteflow/core/theme/app_theme.dart';
import 'package:quoteflow/shared/providers/auth_provider.dart';
import 'package:quoteflow/shared/widgets/app_page_header.dart';

class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final auth = context.watch<AuthProvider>();

    if (auth.isLoading) {
      return AppPageHeader(
        title: l10n.loading,
        subtitle: l10n.profile,
        trailing: SizedBox.square(
          dimension: AppSizes.iconSm,
          child: CircularProgressIndicator(),
        ),
      );
    }

    final name = auth.displayName.isNotEmpty ? auth.displayName : l10n.guest;
    return AppPageHeader(title: name, subtitle: l10n.greeting(name));
  }
}
