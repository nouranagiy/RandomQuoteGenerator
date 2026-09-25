import 'package:flutter/material.dart';
import 'package:quoteflow/app.dart';
import 'package:quoteflow/core/bootstrap.dart';
import 'package:quoteflow/shared/providers/auth_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final authProvider = AuthProvider();
  runApp(
    QuoteFlowApp(
      authProvider: authProvider,
      bootstrap: () => appBootstrap(authProvider),
    ),
  );
}
