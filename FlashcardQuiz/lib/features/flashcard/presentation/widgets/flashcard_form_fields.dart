import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_localizations.dart';

class FlashcardFormFields extends StatelessWidget {
  final TextEditingController questionController;
  final TextEditingController answerController;
  final String selectedCategory;
  final ValueChanged<String> onCategoryChanged;

  const FlashcardFormFields({
    super.key,
    required this.questionController,
    required this.answerController,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Column(
      children: [
        TextFormField(
          controller: questionController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: loc.question,
            hintText: loc.enterQuestion,
            prefixIcon: const Icon(Icons.help_outline),
            alignLabelWithHint: true,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return loc.questionRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: answerController,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: loc.answer,
            hintText: loc.enterAnswer,
            prefixIcon: const Icon(Icons.question_answer_outlined),
            alignLabelWithHint: true,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return loc.answerRequired;
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          initialValue: selectedCategory,
          decoration: InputDecoration(
            labelText: loc.category,
            prefixIcon: const Icon(Icons.category_outlined),
          ),
          items: AppConstants.categories
              .where((c) => c != AppConstants.allCategory)
              .map(
                (category) =>
                    DropdownMenuItem(value: category, child: Text(category)),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) onCategoryChanged(value);
          },
        ),
      ],
    );
  }
}
