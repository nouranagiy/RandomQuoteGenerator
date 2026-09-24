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

class LoginScreen extends StatefulWidget {
  final VoidCallback onSignedIn;
  final VoidCallback onNavigateToSignUp;

  const LoginScreen({
    super.key,
    required this.onSignedIn,
    required this.onNavigateToSignUp,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      widget.onSignedIn();
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
                    title: loc.loginTitle,
                    subtitle: loc.loginSubtitle,
                  ),
                  const SizedBox(height: 40),
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
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),
                  AuthErrorText(message: _errorMessage),
                  const SizedBox(height: 16),
                  LoadingButton(
                    isLoading: _isLoading,
                    onPressed: _login,
                    label: loc.login,
                  ),
                  const SizedBox(height: 24),
                  AuthSwitchLink(
                    text: loc.noAccount,
                    linkLabel: loc.signUp,
                    onLinkTap: widget.onNavigateToSignUp,
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
