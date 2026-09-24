import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/routing/app_router.dart';
import '../../../core/utils/debug_log.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_error.dart';
import '../../../core/widgets/app_loading.dart';
import '../data/dictionary_entry.dart';
import '../data/dictionary_result.dart';
import 'dictionary_controller.dart';
import 'widgets/dictionary_result_card.dart';
import 'widgets/dictionary_search_field.dart';
import 'widgets/recent_searches.dart';
import 'widgets/suggestion_list.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key, this.controller});

  final DictionaryController? controller;

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final TextEditingController _textController = TextEditingController();
  late final DictionaryController _controller =
      widget.controller ?? DictionaryController();
  late final bool _ownsController = widget.controller == null;

  @override
  void dispose() {
    _textController.dispose();
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _handleClear() {
    _textController.clear();
    _controller.onQueryChanged('');
    _controller.clearResult();
  }

  Future<void> _search(String word) async {
    _syncFieldWith(word);
    debugLog('DictionaryScreen', 'search submitted: "$word"');
    _controller.selectSuggestion(word);
    FocusScope.of(context).unfocus();
  }

  Future<void> _selectSuggestion(String word) async {
    _syncFieldWith(word);
    FocusScope.of(context).unfocus();
    await _controller.search(word);
  }

  void _syncFieldWith(String word) {
    if (_textController.text != word) {
      _textController.text = word;
      _textController.selection = TextSelection.collapsed(offset: word.length);
    }
  }

  void _openDetails(DictionaryEntry entry) {
    debugLog(
      'DictionaryScreen',
      'result selected: "${entry.word}" — opening details with the cached entry (no refetch)',
    );
    Navigator.of(context).pushNamed(AppRoutes.dictionaryWord, arguments: entry);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.dictionary)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: DictionarySearchField(
              controller: _textController,
              hintText: l.searchAnyWord,
              onChanged: _controller.onQueryChanged,
              onSubmitted: _search,
              onClear: _handleClear,
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: _controller,
              builder: (context, _) => _buildBody(l, _controller),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(AppLocalizations l, DictionaryController controller) {
    if (controller.status == DictionaryLookupStatus.found &&
        controller.entry != null) {
      final entry = controller.entry!;
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          DictionaryResultCard(entry: entry, onTap: () => _openDetails(entry)),
        ],
      );
    }

    if (controller.suggestions.isNotEmpty) {
      return SuggestionList(
        suggestions: controller.suggestions,
        onSelected: _selectSuggestion,
      );
    }

    switch (controller.status) {
      case DictionaryLookupStatus.idle:
        return _buildIdle(l, controller);
      case DictionaryLookupStatus.loading:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppLoading(),
              const SizedBox(height: 16),
              Text(
                l.searchingWord,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      case DictionaryLookupStatus.found:
        return const SizedBox.shrink();
      case DictionaryLookupStatus.notFound:
        return AppEmptyState(
          icon: Icons.search_off_rounded,
          title: l.wordNotFoundMessage,
          subtitle: l.tryAnotherSearch,
        );
      case DictionaryLookupStatus.networkError:
        return AppError(
          message: l.couldNotConnect,
          onRetry: () => _controller.search(controller.query),
        );
      case DictionaryLookupStatus.timeout:
        return AppError(
          message: l.requestTimedOut,
          onRetry: () => _controller.search(controller.query),
        );
      case DictionaryLookupStatus.invalidResponse:
        return AppError(
          message: l.dictionaryInvalidResponse,
          onRetry: () => _controller.search(controller.query),
        );
      case DictionaryLookupStatus.apiError:
        return AppError(
          message: l.dictionaryApiError,
          onRetry: () => _controller.search(controller.query),
        );
    }
  }

  Widget _buildIdle(AppLocalizations l, DictionaryController controller) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (controller.recentSearches.isNotEmpty) ...[
          RecentSearches(
            recent: controller.recentSearches,
            onSelected: _selectSuggestion,
            onRemove: controller.removeRecentSearch,
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 32),
        AppEmptyState(
          icon: Icons.menu_book_rounded,
          title: l.searchAnyWord,
          subtitle: l.dictionaryHint,
        ),
      ],
    );
  }
}
