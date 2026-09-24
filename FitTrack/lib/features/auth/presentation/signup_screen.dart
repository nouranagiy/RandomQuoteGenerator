import 'package:flutter/material.dart';
import '../../../generated/l10n/app_localizations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_text_field.dart';
import '../../profile/data/profile_provider.dart';
import '../data/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String _getErrorMessage(AppLocalizations l10n, dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return l10n.errorEmailInUse;
        case 'invalid-email':
          return l10n.errorInvalidEmail;
        case 'weak-password':
          return l10n.errorWeakPassword;
        case 'network-request-failed':
          return l10n.errorNetwork;
        default:
          return l10n.errorGeneric;
      }
    }
    return l10n.errorGeneric;
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.signUp(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      // Reload the freshly-created Firestore profile so the Welcome
      // Header shows the account name without a race with auth state change.
      if (!mounted) return;
      await context.read<ProfileProvider>().refreshProfile();
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed(AppRouter.home);
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getErrorMessage(l10n, e)),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    child: Icon(
                      Icons.person_add_rounded,
                      size: 36,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    l10n.signUp,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.signUpSubtitle,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.huge),
                  AppTextField(
                    controller: _nameController,
                    labelText: l10n.fullName,
                    hintText: l10n.nameHint,
                    prefixIcon: Icons.person_outline,
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.errorNameRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    controller: _emailController,
                    labelText: l10n.email,
                    hintText: l10n.emailHint,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return l10n.errorEmailRequired;
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return l10n.errorInvalidEmail;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    controller: _passwordController,
                    labelText: l10n.password,
                    hintText: l10n.passwordHint,
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                      ),
                      tooltip: _obscurePassword
                          ? l10n.showPassword
                          : l10n.hidePassword,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.errorPasswordRequired;
                      }
                      if (value.length < 6) {
                        return l10n.errorWeakPassword;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    controller: _confirmPasswordController,
                    labelText: l10n.confirmPassword,
                    hintText: l10n.confirmPasswordHint,
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      onPressed: () => setState(
                        () => _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                      ),
                      tooltip: _obscureConfirmPassword
                          ? l10n.showPassword
                          : l10n.hidePassword,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.errorPasswordRequired;
                      }
                      if (value != _passwordController.text) {
                        return l10n.errorPasswordMismatch;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  AppButton(
                    label: _isLoading ? l10n.creatingAccount : l10n.createAccount,
                    onPressed: _isLoading ? null : _signUp,
                    isLoading: _isLoading,
                    icon: Icons.person_add_rounded,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.hasAccount,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushReplacementNamed(AppRouter.login);
                        },
                        child: Text(l10n.login),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
