import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/diary_entry.dart';
import '../models/todo_item.dart';

class StorageService {
  static Future<List<DiaryEntry>> getDiaryEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('diary') ?? [];
    return data.map((e) => DiaryEntry.fromJson(json.decode(e))).toList();
  }

  static Future<void> saveDiaryEntries(List<DiaryEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final data = entries.map((e) => json.encode(e.toJson())).toList();
    await prefs.setStringList('diary', data);
  }

  static Future<List<TodoItem>> getTodoItems() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('todo') ?? [];
    return data.map((e) => TodoItem.fromJson(json.decode(e))).toList();
  }

  static Future<void> saveTodoItems(List<TodoItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final data = items.map((e) => json.encode(e.toJson())).toList();
    await prefs.setStringList('todo', data);
  }
}
