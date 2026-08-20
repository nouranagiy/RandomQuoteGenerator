import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/flashcard.dart';

class FlashcardStorage {
  static const String _key = 'flashcards';

  Future<List<Flashcard>> getFlashcards() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(_key);

    if (data == null) {
      return [];
    }

    final List<dynamic> decodedData = jsonDecode(data);

    return decodedData
        .map((item) => Flashcard.fromMap(item))
        .toList();
  }

  Future<void> saveFlashcards(List<Flashcard> flashcards) async {
    final prefs = await SharedPreferences.getInstance();

    final data = flashcards
        .map((flashcard) => flashcard.toMap())
        .toList();

    await prefs.setString(_key, jsonEncode(data));
  }

  Future<void> clearFlashcards() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_key);
  }
}