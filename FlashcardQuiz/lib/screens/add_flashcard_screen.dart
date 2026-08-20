import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/flashcard.dart';
import '../services/flashcard_storage.dart';

class AddFlashcardScreen extends StatefulWidget {
  const AddFlashcardScreen({super.key});

  @override
  State<AddFlashcardScreen> createState() => _AddFlashcardScreenState();
}

class _AddFlashcardScreenState extends State<AddFlashcardScreen> {
  String _selectedCategory = 'General';

  final List<String> _categories = [
    'General',
    'Flutter',
    'Dart',
    'Programming',
    'Database',
  ];
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _questionController =
  TextEditingController();

  final TextEditingController _answerController =
  TextEditingController();

  final FlashcardStorage _storage = FlashcardStorage();

  bool _isSaving = false;

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _saveFlashcard() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final flashcards = await _storage.getFlashcards();

    final newFlashcard = Flashcard(
      id: const Uuid().v4(),
      question: _questionController.text.trim(),
      answer: _answerController.text.trim(),
      category: _selectedCategory,
    );
    flashcards.add(newFlashcard);

    await _storage.saveFlashcards(flashcards);

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
        ),
        title: const Text('Add Flashcard'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              Text(
                'Create a new flashcard',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              TextFormField(
                controller: _questionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Question',
                  hintText: 'Enter the question',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.help_outline),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a question';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _answerController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Answer',
                  hintText: 'Enter the answer',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.question_answer_outlined),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an answer';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveFlashcard,
                  child: _isSaving
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Save Flashcard',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}