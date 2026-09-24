class Flashcard {
  final String id;
  String question;
  String answer;
  String category;
  bool isFavorite;

  Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    this.category = 'General',
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'category': category,
      'isFavorite': isFavorite,
    };
  }

  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'] ?? '',
      question: map['question'] ?? '',
      answer: map['answer'] ?? '',
      category: map['category'] ?? 'General',
      isFavorite: map['isFavorite'] ?? false,
    );
  }
}
