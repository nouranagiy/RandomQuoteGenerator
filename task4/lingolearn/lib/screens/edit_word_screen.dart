import 'package:flutter/material.dart';
import '../models/language_word.dart';
import '../services/language_storage.dart';
class EditWordScreen extends StatefulWidget {
  final LanguageWord word;
  const EditWordScreen({
    super.key,
    required this.word,
  });
  @override
  State<EditWordScreen> createState() => _EditWordScreenState();
}
class _EditWordScreenState extends State<EditWordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _wordController = TextEditingController();
  final _translationController = TextEditingController();
  final _pronunciationController = TextEditingController();
  final _exampleController = TextEditingController();
  final _categoryController = TextEditingController();
  final LanguageStorage _storage = LanguageStorage();
  @override
  void initState() {
    super.initState();
    _wordController.text = widget.word.word;
    _translationController.text = widget.word.translation;
    _pronunciationController.text = widget.word.pronunciation;
    _exampleController.text = widget.word.example;
    _categoryController.text = widget.word.category;
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
  String? _validateRequired(
      String? value,
      String fieldName,) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }
  Future<void> _updateWord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final updatedWord = LanguageWord(
      id: widget.word.id,
      word: _wordController.text.trim(),
      translation: _translationController.text.trim(),
      pronunciation: _pronunciationController.text.trim(),
      example: _exampleController.text.trim(),
      category: _categoryController.text.trim(),
      isFavorite: widget.word.isFavorite,
    );
    await _storage.updateWord(updatedWord);
    if (!mounted) return;
    Navigator.pop(context, true);
  }
  Future<void> _deleteWord() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Word'),
          content: Text('Are you sure you want to delete "${widget.word.word}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
    if (shouldDelete != true) return;
    await _storage.deleteWord(widget.word.id);
    if (!mounted) return;
    Navigator.pop(context, true);
  }
  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Word',
          style: TextStyle(fontWeight: FontWeight.bold,),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Word',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text('Update the information of this word.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 30),
              Text('Word',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _wordController,
                decoration: _inputDecoration(
                  hint: 'e.g. Amazing',
                  icon: Icons.translate_rounded,
                ),
                validator: (value) => _validateRequired(
                      value,
                      'the word',
                    ),
              ),
              SizedBox(height: 20),
              Text('Translation',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _translationController,
                decoration: _inputDecoration(
                  hint: 'e.g. رائع',
                  icon: Icons.language_rounded,
                ),
                validator: (value) => _validateRequired(
                      value,
                      'the translation',
                    ),
              ),
              SizedBox(height: 20),
              Text('Pronunciation',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _pronunciationController,
                decoration: _inputDecoration(
                  hint: 'e.g. uh-MAY-zing',
                  icon: Icons.record_voice_over_rounded,
                ),
                validator: (value) => _validateRequired(
                      value,
                      'the pronunciation',
                    ),
              ),
              SizedBox(height: 20),
              Text('Example',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _exampleController,
                maxLines: 3,
                decoration: _inputDecoration(
                  hint: 'e.g. This is an amazing experience.',
                  icon: Icons.format_quote_rounded,
                ),
                validator: (value) => _validateRequired(
                      value,
                      'an example',
                    ),
              ),
              SizedBox(height: 20),
              Text('Category',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _categoryController,
                decoration: _inputDecoration(
                  hint: 'e.g. Common Words',
                  icon: Icons.category_rounded,
                ),
                validator: (value) => _validateRequired(
                      value,
                      'the category',
                    ),
              ),
              SizedBox(height: 35),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _updateWord,
                  icon: Icon(Icons.save_rounded,),
                  label: Text('Save Changes',),
                ),
              ),
              SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  onPressed: _deleteWord,
                  icon: Icon(Icons.delete_outline_rounded,),
                  label: Text('Delete Word',),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}