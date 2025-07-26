import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diary_entry.dart';

class DiaryService {
  static const String key = 'diary_entries';

  static Future<List<DiaryEntry>> getEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(key) ?? [];
    return data.map((e) => DiaryEntry.fromJson(json.decode(e))).toList();
  }

  static Future<void> addEntry(DiaryEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getEntries();
    entries.insert(0, entry);
    final data = entries.map((e) => json.encode(e.toJson())).toList();
    await prefs.setStringList(key, data);
  }

  static Future<void> deleteEntry(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getEntries();
    entries.removeAt(index);
    final data = entries.map((e) => json.encode(e.toJson())).toList();
    await prefs.setStringList(key, data);
  }
}
