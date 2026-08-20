import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/fitness_entry.dart';
class FitnessStorage {
  static const String _key = 'fitness_entries';
  Future<List<FitnessEntry>> getEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key) ?? [];
    return data.map((item) => FitnessEntry.fromMap(
        jsonDecode(item),
      ),
    ).toList();
  }
  Future<void> saveEntries(
      List<FitnessEntry> entries,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    final data = entries.map(
          (entry) => jsonEncode(entry.toMap(),),
    ).toList();
    await prefs.setStringList(
      _key,
      data,
    );
  }
}