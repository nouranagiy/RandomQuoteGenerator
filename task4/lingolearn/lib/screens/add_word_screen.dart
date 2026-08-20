import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/language_word.dart';
import '../services/language_storage.dart';
class AddWordScreen extends StatefulWidget {
  const AddWordScreen({super.key});
  @override
  State<AddWordScreen> createState() => _AddWordScreenState();
}
class _AddWordScreenState extends State<AddWordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _wordController = TextEditingController();
  final _translationController = TextEditingController();
  final _pronunciationController = TextEditingController();
  final _exampleController = TextEditingController();
  final _categoryController = TextEditingController();
  final LanguageStorage _storage = LanguageStorage();
  @override
  void dispose() {
    _wordController.dispose();
    _translationController.dispose();
    _pronunciationController.dispose();
    _exampleController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
  Future<void> _saveWord() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final word = LanguageWord(
      id: Uuid().v4(),
      word: _wordController.text.trim(),
      translation: _translationController.text.trim(),
      pronunciation: _pronunciationController.text.trim(),
      example: _exampleController.text.trim(),
      category: _categoryController.text.trim(),
    );
    await _storage.addWord(word);
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
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Word',
          style: TextStyle(fontWeight: FontWeight.bold,),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding:  EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add New Word',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text('Add a new word to your vocabulary.',
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
                validator: (value) => _validateRequired(value, 'the word'),
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
                validator: (value) => _validateRequired(value, 'the translation'),
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
                validator: (value) => _validateRequired(value, 'the pronunciation'),
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
                validator: (value) => _validateRequired(value, 'an example'),
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
                validator: (value) => _validateRequired(value, 'the category'),
              ),
              SizedBox(height: 35),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: _saveWord,
                  icon: Icon(Icons.check_rounded,),
                  label: Text('Save Word',),
                ),
              ),
              SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Cancel',),
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