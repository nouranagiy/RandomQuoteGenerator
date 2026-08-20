import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/language_word.dart';
class LanguageStorage {
  static const String _wordsKey = 'language_words';
  Future<List<LanguageWord>> getWords() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_wordsKey);
    if (data == null || data.isEmpty) {
      return [];
    }
    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((item) => LanguageWord.fromMap(Map<String, dynamic>.from(item),
      ),
    ).toList();
  }
  Future<void> saveWords(
      List<LanguageWord> words,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final data = words.map((word) => word.toMap()).toList();
    await prefs.setString(
      _wordsKey,
      jsonEncode(data),
    );
  }
  Future<void> initializeDefaultWords() async {
    final words = await getWords();
    if (words.isNotEmpty) {
      return;
    }
    final defaultWords = [
      LanguageWord(
        id: '1',
        word: 'Hello',
        translation: 'مرحبا',
        pronunciation: 'heh-LOH',
        example: 'Hello, how are you?',
        category: 'Greetings',
      ),
      LanguageWord(
        id: '2',
        word: 'Goodbye',
        translation: 'مع السلامة',
        pronunciation: 'good-BYE',
        example: 'Goodbye, see you tomorrow.',
        category: 'Greetings',
      ),
      LanguageWord(
        id: '3',
        word: 'Thank you',
        translation: 'شكرا',
        pronunciation: 'THANK yoo',
        example: 'Thank you for your help.',
        category: 'Greetings',
      ),
      LanguageWord(
        id: '4',
        word: 'Beautiful',
        translation: 'جميل',
        pronunciation: 'BYOO-tuh-fuhl',
        example: 'The garden is beautiful.',
        category: 'Common Words',
      ),
      LanguageWord(
        id: '5',
        word: 'Happy',
        translation: 'سعيد',
        pronunciation: 'HAP-ee',
        example: 'I am happy today.',
        category: 'Common Words',
      ),
      LanguageWord(
        id: '6',
        word: 'Book',
        translation: 'كتاب',
        pronunciation: 'book',
        example: 'I am reading a book.',
        category: 'Education',
      ),
      LanguageWord(
        id: '7',
        word: 'Teacher',
        translation: 'مُعلم',
        pronunciation: 'TEE-cher',
        example: 'My teacher is very helpful.',
        category: 'Education',
      ),
      LanguageWord(
        id: '8',
        word: 'Water',
        translation: 'ماء',
        pronunciation: 'WAW-ter',
        example: 'I drink water every day.',
        category: 'Food & Drinks',
      ),
      LanguageWord(
        id: '9',
        word: 'Coffee',
        translation: 'قهوة',
        pronunciation: 'KAW-fee',
        example: 'I would like a cup of coffee.',
        category: 'Food & Drinks',
      ),
      LanguageWord(
        id: '10',
        word: 'Morning',
        translation: 'صباح',
        pronunciation: 'MOR-ning',
        example: 'Good morning!',
        category: 'Time',
      ),
    ];
    await saveWords(defaultWords);
  }
  Future<void> addWord(LanguageWord word) async {
    final words = await getWords();
    words.add(word);
    await saveWords(words);
  }
  Future<void> updateWord(LanguageWord updatedWord) async {
    final words = await getWords();
    final index = words.indexWhere((word) => word.id == updatedWord.id,
    );
    if (index == -1) {
      return;
    }
    words[index] = updatedWord;
    await saveWords(words);
  }
  Future<void> deleteWord(String wordId) async {
    final words = await getWords();
    words.removeWhere((word) => word.id == wordId,
    );
    await saveWords(words);
  }
  Future<void> toggleFavorite(
      String wordId,
      ) async {
    final words = await getWords();
    final index = words.indexWhere((word) => word.id == wordId,
    );
    if (index == -1) {
      return;
    }
    words[index].isFavorite = !words[index].isFavorite;
    await saveWords(words);
  }
  Future<void> toggleLearned(String wordId) async {
    final words = await getWords();
    final index = words.indexWhere((word) => word.id == wordId,
    );
    if (index == -1) return;
    words[index].isLearned = !words[index].isLearned;
    await saveWords(words);
  }
  static const String _quizCountKey = 'quiz_count';
  static const String _bestScoreKey = 'best_quiz_score';
  static const String _lastScoreKey = 'last_quiz_score';
  static const String _bestTotalKey = 'best_quiz_total';
  static const String _lastTotalKey = 'last_quiz_total';
  Future<int> getQuizCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_quizCountKey) ?? 0;
  }
  Future<int> getBestQuizScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_bestScoreKey) ?? 0;
  }
  Future<int> getLastQuizScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastScoreKey) ?? 0;
  }
  Future<int> getBestQuizTotal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_bestTotalKey) ?? 0;
  }
  Future<int> getLastQuizTotal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastTotalKey) ?? 0;
  }
  Future<void> saveQuizResult(int score, int total) async {
    final prefs = await SharedPreferences.getInstance();
    final quizCount = (prefs.getInt(_quizCountKey) ?? 0) + 1;
    final bestScore = prefs.getInt(_bestScoreKey) ?? 0;
    final bestTotal = prefs.getInt(_bestTotalKey) ?? 0;
    await prefs.setInt(_quizCountKey, quizCount);
    await prefs.setInt(_lastScoreKey, score);
    await prefs.setInt(_lastTotalKey, total);
    final newPercentage = total == 0 ? 0 : (score / total);
    final bestPercentage = bestTotal == 0 ? -1 : (bestScore / bestTotal);
    if (newPercentage >= bestPercentage) {
      await prefs.setInt(_bestScoreKey, score);
      await prefs.setInt(_bestTotalKey, total);
    }
  }
  Future<void> resetAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_wordsKey);
    await prefs.remove(_quizCountKey);
    await prefs.remove(_bestScoreKey);
    await prefs.remove(_lastScoreKey);
    await prefs.remove(_bestTotalKey);
    await prefs.remove(_lastTotalKey);
  }
}