import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../widgets/loading_button.dart';
import '../widgets/auth_error_text.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_switch_link.dart';
import '../widgets/auth_validators.dart';
import '../widgets/password_field.dart';

class SignUpScreen extends StatefulWidget {
  final VoidCallback onSignedUp;
  final VoidCallback onNavigateToLogin;

  const SignUpScreen({
    super.key,
    required this.onSignedUp,
    required this.onNavigateToLogin,
  });

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
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
      );

      if (!mounted) return;
      widget.onSignedUp();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final loc = AppLocalizations.of(context);
      setState(() {
        _errorMessage = loc.get(_authService.getErrorMessage(e.code));
      });
    } catch (_) {
      if (!mounted) return;
      final loc = AppLocalizations.of(context);
      setState(() {
        _errorMessage = loc.get('genericError');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AuthHeader(
                    title: loc.signUpTitle,
                    subtitle: loc.signUpSubtitle,
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: loc.name,
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return loc.nameRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: loc.email,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    validator: (value) => validateEmail(value, loc),
                  ),
                  const SizedBox(height: 16),
                  PasswordField(
                    controller: _passwordController,
                    label: loc.password,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return loc.passwordRequired;
                      }
                      if (value.length < 6) {
                        return loc.passwordTooShort;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  PasswordField(
                    controller: _confirmPasswordController,
                    label: loc.confirmPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return loc.passwordRequired;
                      }
                      if (value != _passwordController.text) {
                        return loc.passwordsDoNotMatch;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  AuthErrorText(message: _errorMessage),
                  const SizedBox(height: 16),
                  LoadingButton(
                    isLoading: _isLoading,
                    onPressed: _signUp,
                    label: loc.signUp,
                  ),
                  const SizedBox(height: 24),
                  AuthSwitchLink(
                    text: loc.hasAccount,
                    linkLabel: loc.login,
                    onLinkTap: widget.onNavigateToLogin,
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
