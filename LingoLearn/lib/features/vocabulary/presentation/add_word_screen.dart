import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/utils/form_validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/error_card.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/word_audio_button.dart';
import '../../dictionary/data/dictionary_result.dart';
import '../../dictionary/presentation/widgets/part_of_speech_badge.dart';
import '../data/language_storage.dart';
import 'add_word_controller.dart';

class AddWordScreen extends StatefulWidget {
  const AddWordScreen({super.key});

  @override
  State<AddWordScreen> createState() => _AddWordScreenState();
}

class _AddWordScreenState extends State<AddWordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _wordController = TextEditingController();
  final _translationController = TextEditingController();
  final _exampleController = TextEditingController();
  final _categoryController = TextEditingController();
  final LanguageStorage _storage = LanguageStorage();
  final AddWordController _controller = AddWordController();

  @override
  void dispose() {
    _wordController.dispose();
    _translationController.dispose();
    _exampleController.dispose();
    _categoryController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _lookup() async {
    if (!_formKey.currentState!.validate()) return;
    final word = _wordController.text.trim();
    await _controller.lookup(word);
    if (!mounted || _controller.status != DictionaryLookupStatus.found) return;

    final entry = _controller.entry!;
    _translationController.text = entry.summary;
    _exampleController.text = entry.exampleSentence;
    _categoryController.text = 'General';
  }

  Future<void> _saveWord() async {
    if (_controller.entry == null) return;
    final word = _controller.toLanguageWord(
      id: const Uuid().v4(),
      translation: _translationController.text.trim(),
      example: _exampleController.text.trim(),
      category: _categoryController.text.trim(),
    );
    try {
      await _storage.addWord(word);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).saveWordFailed)),
      );
      return;
    }
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.addWord)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.fetchWordHint,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 18),
              AppTextField(
                controller: _wordController,
                label: l.word,
                hint: l.hintWord,
                prefixIcon: Icons.translate_rounded,
                textInputAction: TextInputAction.search,
                onFieldSubmitted: (_) => _lookup(),
                validator: requiredField(l.pleaseEnterWord),
              ),
              const SizedBox(height: 16),
              ListenableBuilder(
                listenable: _controller,
                builder: (context, _) => _buildStatusArea(l),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusArea(AppLocalizations l) {
    switch (_controller.status) {
      case DictionaryLookupStatus.idle:
        return AppButton(
          text: l.fetchWord,
          icon: Icons.search_rounded,
          onPressed: _lookup,
        );
      case DictionaryLookupStatus.loading:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: AppLoading()),
        );
      case DictionaryLookupStatus.notFound:
        return ErrorCard(
          message: l.wordNotFoundMessage,
          onRetry: () {
            _controller.reset();
            _lookup();
          },
        );
      case DictionaryLookupStatus.networkError:
        return ErrorCard(message: l.couldNotConnect, onRetry: _lookup);
      case DictionaryLookupStatus.timeout:
        return ErrorCard(message: l.requestTimedOut, onRetry: _lookup);
      case DictionaryLookupStatus.invalidResponse:
        return ErrorCard(
          message: l.dictionaryInvalidResponse,
          onRetry: _lookup,
        );
      case DictionaryLookupStatus.apiError:
        return ErrorCard(message: l.dictionaryApiError, onRetry: _lookup);
      case DictionaryLookupStatus.found:
        return _buildFoundArea(l);
    }
  }

  Widget _buildFoundArea(AppLocalizations l) {
    final entry = _controller.entry!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.word,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (entry.phonetic != null &&
                        entry.phonetic!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        entry.phonetic!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    if (entry.primaryMeaning != null)
                      PartOfSpeechBadge(
                        text: entry.primaryMeaning!.partOfSpeech,
                      ),
                  ],
                ),
              ),
              WordAudioButton(
                text: entry.word,
                audioUrl: entry.audioUrl,
                iconSize: 28,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        InfoCard(
          icon: Icons.record_voice_over_rounded,
          title: l.pronunciation,
          value: entry.phonetic?.isNotEmpty ?? false
              ? '${entry.phonetic} $_autoFetchedLabel'
              : _autoFetchedLabel,
        ),
        const SizedBox(height: 18),
        AppTextField(
          controller: _translationController,
          label: l.translation,
          hint: l.hintTranslation,
          prefixIcon: Icons.language_rounded,
          maxLines: 3,
        ),
        const SizedBox(height: 18),
        AppTextField(
          controller: _exampleController,
          label: l.example,
          hint: l.hintExample,
          prefixIcon: Icons.format_quote_rounded,
          maxLines: 3,
        ),
        const SizedBox(height: 18),
        AppTextField(
          controller: _categoryController,
          label: l.category,
          hint: l.hintCategory,
          prefixIcon: Icons.category_rounded,
        ),
        const SizedBox(height: 24),
        AppButton(
          text: l.addToMyWords,
          icon: Icons.playlist_add_rounded,
          onPressed: _saveWord,
        ),
        const SizedBox(height: 12),
        AppButton(
          text: l.cancel,
          type: AppButtonType.outlined,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  String get _autoFetchedLabel {
    final l = AppLocalizations.of(context);
    return '(${l.autoFetched})';
  }
}
