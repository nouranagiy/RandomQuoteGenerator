import 'package:flutter/material.dart';

import '../../../../core/widgets/app_button.dart';

class QuizSetupChoice extends StatelessWidget {
  final String title;
  final Object value;

  const QuizSetupChoice({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      child: AppButton(
        text: title,
        type: AppButtonType.outlined,
        onPressed: () => Navigator.pop(context, value),
      ),
    );
  }
}
