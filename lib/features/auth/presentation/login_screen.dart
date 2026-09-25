import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quoteflow/core/localization/app_localizations.dart';
import 'package:quoteflow/core/theme/app_theme.dart';
import 'package:quoteflow/features/auth/presentation/widgets/app_auth_form.dart';
import 'package:quoteflow/features/auth/presentation/widgets/auth_error_banner.dart';
import 'package:quoteflow/features/auth/presentation/widgets/auth_footer_link.dart';
import 'package:quoteflow/features/auth/presentation/widgets/auth_form_validators.dart';
import 'package:quoteflow/features/auth/presentation/widgets/auth_text_fields.dart';
import 'package:quoteflow/shared/providers/auth_provider.dart';
import 'package:quoteflow/shared/widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onNavigateToSignUp;

  const LoginScreen({super.key, required this.onNavigateToSignUp});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _clearAuthError() {
    context.read<AuthProvider>().clearError();
  }

  void _navigateToSignUp() {
    context.read<AuthProvider>().clearError();
    widget.onNavigateToSignUp();
  }

  Future<void> _handleLogin() async {
    final formState = _formKey.currentState;
    FocusManager.instance.primaryFocus?.unfocus();
    final authProvider = context.read<AuthProvider>();
    authProvider.clearError();

    if (formState?.validate() != true) return;

    await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final authProvider = context.watch<AuthProvider>();
    final failure = authProvider.failure;
    final isBusy = authProvider.isBusy;
    final isExpanded =
        MediaQuery.sizeOf(context).width >= AppBreakpoints.expanded;

    return Scaffold(
      body: AppAuthForm(
        title: l10n.login,
        subtitle: l10n.loginSubtitle,
        formKey: _formKey,
        logoSize: isExpanded ? AppSizes.logoHero : AppSizes.logoLg,
        padding: EdgeInsets.symmetric(
          horizontal: isExpanded ? AppSpacing.xxl : AppSpacing.lg,
          vertical: AppSpacing.xxxl,
        ),
        footer: AuthFooterLink(
          prompt: l10n.noAccount,
          actionLabel: l10n.signUp,
          onPressed: isBusy ? null : _navigateToSignUp,
        ),
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthEmailField(
                controller: _emailController,
                labelText: l10n.email,
                hintText: l10n.emailHint,
                requiredMessage: l10n.emailRequired,
                invalidMessage: l10n.invalidEmail,
                onChanged: (_) => _clearAuthError(),
                enabled: !isBusy,
              ),
              const SizedBox(height: AppSpacing.md),
              AuthPasswordField(
                controller: _passwordController,
                labelText: l10n.password,
                hintText: l10n.passwordHint,
                showPasswordTooltip: l10n.showPassword,
                hidePasswordTooltip: l10n.hidePassword,
                validator: (value) => AuthFormValidators.password(
                  value,
                  requiredMessage: l10n.passwordRequired,
                ),
                onChanged: (_) => _clearAuthError(),
                enabled: !isBusy,
                onFieldSubmitted: (_) => _handleLogin(),
              ),
              if (failure != null) ...[
                const SizedBox(height: AppSpacing.lg),
                AuthErrorBanner(message: l10n.authError(failure)),
              ],
              const SizedBox(height: AppSpacing.lg),
              CustomButton(
                label: l10n.login,
                isLoading: isBusy,
                onPressed: _handleLogin,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
