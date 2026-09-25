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

class SignUpScreen extends StatefulWidget {
  final VoidCallback onNavigateToLogin;

  const SignUpScreen({super.key, required this.onNavigateToLogin});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  static const int _minimumPasswordLength = 6;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _clearAuthError() {
    context.read<AuthProvider>().clearError();
  }

  void _navigateToLogin() {
    context.read<AuthProvider>().clearError();
    widget.onNavigateToLogin();
  }

  Future<void> _handleSignUp() async {
    final formState = _formKey.currentState;
    FocusManager.instance.primaryFocus?.unfocus();
    final authProvider = context.read<AuthProvider>();
    authProvider.clearError();

    if (formState?.validate() != true) return;

    await authProvider.signUp(
      name: _nameController.text.trim(),
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
        title: l10n.signUp,
        subtitle: l10n.signUpSubtitle,
        formKey: _formKey,
        logoSize: isExpanded ? AppSizes.logoHero : AppSizes.logoLg,
        padding: EdgeInsets.symmetric(
          horizontal: isExpanded ? AppSpacing.xxl : AppSpacing.lg,
          vertical: AppSpacing.xxxl,
        ),
        footer: AuthFooterLink(
          prompt: l10n.hasAccount,
          actionLabel: l10n.login,
          onPressed: isBusy ? null : _navigateToLogin,
        ),
        child: AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthTextField(
                controller: _nameController,
                labelText: l10n.name,
                hintText: l10n.nameHint,
                prefixIcon: Icons.person_outline_rounded,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                validator: (value) => AuthFormValidators.requiredValue(
                  value,
                  message: l10n.nameRequired,
                ),
                onChanged: (_) => _clearAuthError(),
                enabled: !isBusy,
              ),
              const SizedBox(height: AppSpacing.md),
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
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.next,
                validator: (value) => AuthFormValidators.password(
                  value,
                  requiredMessage: l10n.passwordRequired,
                  minLengthMessage: l10n.passwordMinLength,
                  minLength: _minimumPasswordLength,
                ),
                onChanged: (_) => _clearAuthError(),
                enabled: !isBusy,
              ),
              const SizedBox(height: AppSpacing.md),
              AuthPasswordField(
                controller: _confirmPasswordController,
                labelText: l10n.confirmPassword,
                hintText: l10n.confirmPasswordHint,
                showPasswordTooltip: l10n.showPassword,
                hidePasswordTooltip: l10n.hidePassword,
                autofillHints: const [AutofillHints.newPassword],
                validator: (value) => AuthFormValidators.passwordsMatch(
                  value,
                  password: _passwordController.text,
                  requiredMessage: l10n.passwordRequired,
                  mismatchMessage: l10n.passwordsDoNotMatch,
                ),
                onChanged: (_) => _clearAuthError(),
                enabled: !isBusy,
                onFieldSubmitted: (_) => _handleSignUp(),
              ),
              if (failure != null) ...[
                const SizedBox(height: AppSpacing.lg),
                AuthErrorBanner(message: l10n.authError(failure)),
              ],
              const SizedBox(height: AppSpacing.lg),
              CustomButton(
                label: l10n.signUp,
                isLoading: isBusy,
                onPressed: _handleSignUp,
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
