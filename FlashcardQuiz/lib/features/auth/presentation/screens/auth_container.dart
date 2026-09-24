import 'package:flutter/material.dart';

import 'login_screen.dart';
import 'signup_screen.dart';

class AuthContainer extends StatefulWidget {
  final VoidCallback onAuthenticated;

  const AuthContainer({super.key, required this.onAuthenticated});

  @override
  State<AuthContainer> createState() => _AuthContainerState();
}

class _AuthContainerState extends State<AuthContainer> {
  bool _showLogin = true;

  void _toggle() {
    setState(() {
      _showLogin = !_showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _showLogin
        ? LoginScreen(
            onSignedIn: widget.onAuthenticated,
            onNavigateToSignUp: _toggle,
          )
        : SignUpScreen(
            onSignedUp: widget.onAuthenticated,
            onNavigateToLogin: _toggle,
          );
  }
}
