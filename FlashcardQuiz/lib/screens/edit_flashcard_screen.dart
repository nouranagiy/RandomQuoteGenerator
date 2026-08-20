import 'package:flutter/material.dart';

import '../models/flashcard.dart';

class EditFlashcardScreen extends StatefulWidget {
  final Flashcard flashcard;

  const EditFlashcardScreen({
    super.key,
    required this.flashcard,
  });

  @override
  State<EditFlashcardScreen> createState() =>
      _EditFlashcardScreenState();
}

class _EditFlashcardScreenState extends State<EditFlashcardScreen> {
  String _selectedCategory = 'General';

  final List<String> _categories = [
    'General',
    'Flutter',
    'Dart',
    'Programming',
    'Database',
  ];
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _questionController;
  late final TextEditingController _answerController;

  @override
  void initState() {
    super.initState();

    _questionController = TextEditingController(
      text: widget.flashcard.question,
    );
    _answerController = TextEditingController(
      text: widget.flashcard.answer,
    );
    _selectedCategory = widget.flashcard.category;
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _updateFlashcard() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updatedFlashcard = Flashcard(
      id: widget.flashcard.id,
      question: _questionController.text.trim(),
      answer: _answerController.text.trim(),
      category: _selectedCategory,
      isFavorite: widget.flashcard.isFavorite,
    );
    Navigator.pop(context, updatedFlashcard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Flashcard'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 10),

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
                  onPressed: _updateFlashcard,
                  child: const Text(
                    'Update Flashcard',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}