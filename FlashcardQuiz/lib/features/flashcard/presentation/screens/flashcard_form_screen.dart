import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/firestore_error.dart';
import '../../../../widgets/loading_button.dart';
import '../../data/flashcard_repository.dart';
import '../../domain/flashcard.dart';
import '../widgets/flashcard_form_fields.dart';

class FlashcardFormScreen extends StatefulWidget {
  final Flashcard? flashcard;

  const FlashcardFormScreen({super.key, this.flashcard});

  @override
  State<FlashcardFormScreen> createState() => _FlashcardFormScreenState();
}

class _FlashcardFormScreenState extends State<FlashcardFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = FlashcardRepository();
  late final TextEditingController _questionController;
  late final TextEditingController _answerController;
  late String _selectedCategory;
  bool _isSaving = false;

  bool get _isEdit => widget.flashcard != null;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(
      text: widget.flashcard?.question,
    );
    _answerController = TextEditingController(text: widget.flashcard?.answer);
    _selectedCategory =
        widget.flashcard?.category ?? AppConstants.defaultCategory;
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final loc = AppLocalizations.of(context);
    final flashcard = Flashcard(
      id: widget.flashcard?.id ?? const Uuid().v4(),
      question: _questionController.text.trim(),
      answer: _answerController.text.trim(),
      category: _selectedCategory,
      isFavorite: widget.flashcard?.isFavorite ?? false,
    );

    if (_isEdit) {
      Navigator.pop(context, flashcard);
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _repository.createFlashcard(flashcard);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      final message = firestoreErrorMessage(loc, error);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? loc.editFlashcard : loc.addFlashcard),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isEdit) ...[
                const SizedBox(height: 10),
                Text(
                  loc.createNewFlashcard,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
              ],
              FlashcardFormFields(
                questionController: _questionController,
                answerController: _answerController,
                selectedCategory: _selectedCategory,
                onCategoryChanged: (value) {
                  setState(() => _selectedCategory = value);
                },
              ),
              const SizedBox(height: 30),
              LoadingButton(
                isLoading: _isSaving,
                onPressed: _save,
                label: _isEdit ? loc.updateFlashcard : loc.save,
              ),
              if (!_isEdit) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(loc.cancel),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
