import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/form_validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_confirm_dialog.dart';
import '../../../core/widgets/app_text_field.dart';
import '../data/language_storage.dart';
import '../data/language_word.dart';

class EditWordScreen extends StatefulWidget {
  final LanguageWord word;
  const EditWordScreen({super.key, required this.word});

  @override
  State<EditWordScreen> createState() => _EditWordScreenState();
}

class _EditWordScreenState extends State<EditWordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _wordController;
  late final TextEditingController _translationController;
  late final TextEditingController _pronunciationController;
  late final TextEditingController _exampleController;
  late final TextEditingController _categoryController;
  final LanguageStorage _storage = LanguageStorage();

  @override
  void initState() {
    super.initState();
    _wordController = TextEditingController(text: widget.word.word);
    _translationController = TextEditingController(
      text: widget.word.translation,
    );
    _pronunciationController = TextEditingController(
      text: widget.word.pronunciation,
    );
    _exampleController = TextEditingController(text: widget.word.example);
    _categoryController = TextEditingController(text: widget.word.category);
  }

  @override
  void dispose() {
    _wordController.dispose();
    _translationController.dispose();
    _pronunciationController.dispose();
    _exampleController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    final updated = LanguageWord(
      id: widget.word.id,
      word: _wordController.text.trim(),
      translation: _translationController.text.trim(),
      pronunciation: _pronunciationController.text.trim(),
      example: _exampleController.text.trim(),
      category: _categoryController.text.trim(),
      isFavorite: widget.word.isFavorite,
      isLearned: widget.word.isLearned,
    );
    await _storage.updateWord(updated);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _deleteWord() async {
    final l = AppLocalizations.of(context);
    final confirmed = await showConfirmDialog(
      context,
      title: l.deleteWord,
      message: l.deleteWordMessage,
      confirmLabel: l.delete,
    );
    if (confirmed != true) return;
    await _storage.deleteWord(widget.word.id);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.editWord),
        actions: [
          IconButton(
            onPressed: _deleteWord,
            tooltip: l.delete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _wordController,
                label: l.word,
                hint: l.hintWord,
                prefixIcon: Icons.translate_rounded,
                validator: requiredField(l.pleaseEnterWord),
              ),
              const SizedBox(height: 18),
              AppTextField(
                controller: _translationController,
                label: l.translation,
                hint: l.hintTranslation,
                prefixIcon: Icons.language_rounded,
                validator: requiredField(l.pleaseEnterTranslation),
              ),
              const SizedBox(height: 18),
              AppTextField(
                controller: _pronunciationController,
                label: l.pronunciation,
                hint: l.hintPronunciation,
                prefixIcon: Icons.record_voice_over_rounded,
                validator: requiredField(l.pleaseEnterPronunciation),
              ),
              const SizedBox(height: 18),
              AppTextField(
                controller: _exampleController,
                label: l.example,
                hint: l.hintExample,
                prefixIcon: Icons.format_quote_rounded,
                maxLines: 3,
                validator: requiredField(l.pleaseEnterExample),
              ),
              const SizedBox(height: 18),
              AppTextField(
                controller: _categoryController,
                label: l.category,
                hint: l.hintCategory,
                prefixIcon: Icons.category_rounded,
                validator: requiredField(l.pleaseEnterCategory),
              ),
              const SizedBox(height: 32),
              AppButton(
                text: l.saveChanges,
                icon: Icons.check_rounded,
                onPressed: _saveChanges,
              ),
              const SizedBox(height: 12),
              AppButton(
                text: l.cancel,
                type: AppButtonType.outlined,
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
