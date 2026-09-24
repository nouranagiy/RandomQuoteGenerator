import 'package:flutter/material.dart';

class SuggestionList extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onSelected;

  const SuggestionList({
    super.key,
    required this.suggestions,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      itemCount: suggestions.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          leading: const Icon(Icons.lightbulb_outline_rounded),
          title: Text(suggestion),
          trailing: const Icon(Icons.north_west_rounded, size: 16),
          onTap: () => onSelected(suggestion),
        );
      },
    );
  }
}
