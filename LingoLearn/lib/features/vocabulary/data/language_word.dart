class LanguageWord {
  final String id;
  String word;
  String translation;
  String pronunciation;
  String example;
  String category;
  bool isFavorite;
  bool isLearned;

  String? phonetic;

  String? audioUrl;

  String? partOfSpeech;

  String? source;

  int? createdAt;

  LanguageWord({
    required this.id,
    required this.word,
    required this.translation,
    required this.pronunciation,
    required this.example,
    required this.category,
    this.isFavorite = false,
    this.isLearned = false,
    this.phonetic,
    this.audioUrl,
    this.partOfSpeech,
    this.source,
    this.createdAt,
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
      'phonetic': phonetic,
      'audioUrl': audioUrl,
      'partOfSpeech': partOfSpeech,
      'source': source,
      'createdAt': createdAt,
    };
  }

  factory LanguageWord.fromMap(Map<String, dynamic> map) {
    return LanguageWord(
      id: map['id'] ?? '',
      word: map['word'] ?? '',
      translation: map['translation'] ?? '',
      pronunciation: map['pronunciation'] ?? '',
      example: map['example'] ?? '',
      category: map['category'] ?? 'General',
      isFavorite: map['isFavorite'] ?? false,
      isLearned: map['isLearned'] ?? false,
      phonetic: map['phonetic'] as String?,
      audioUrl: map['audioUrl'] as String?,
      partOfSpeech: map['partOfSpeech'] as String?,
      source: map['source'] as String?,
      createdAt: map['createdAt'] as int?,
    );
  }
}
