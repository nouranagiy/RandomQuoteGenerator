import 'package:flutter/material.dart';

class AuthSwitchLink extends StatelessWidget {
  final String text;
  final String linkLabel;
  final VoidCallback onLinkTap;

  const AuthSwitchLink({
    super.key,
    required this.text,
    required this.linkLabel,
    required this.onLinkTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text('$text ', style: Theme.of(context).textTheme.bodyMedium),
        ),
        GestureDetector(
          onTap: onLinkTap,
          child: Text(
            linkLabel,
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
