class LanguageWord {
  final String id;
  String word;
  String translation;
  String pronunciation;
  String example;
  String category;
  bool isFavorite;
  bool isLearned;
  LanguageWord({
    required this.id,
    required this.word,
    required this.translation,
    required this.pronunciation,
    required this.example,
    required this.category,
    this.isFavorite = false,
    this.isLearned = false,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'translation': translation,
      'pronunciation': pronunciation,
      'example': example,
      'category': category,
      'isFavorite': isFavorite,
      'isLearned': isLearned,
    };
  }
  factory LanguageWord.fromMap(
      Map<String, dynamic> map,) {
    return LanguageWord(
      id: map['id'] ?? '',
      word: map['word'] ?? '',
      translation: map['translation'] ?? '',
      pronunciation: map['pronunciation'] ?? '',
      example: map['example'] ?? '',
      category: map['category'] ?? 'General',
      isFavorite: map['isFavorite'] ?? false,
      isLearned: map['isLearned'] ?? false,
    );
  }
}