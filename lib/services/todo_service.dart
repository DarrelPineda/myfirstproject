import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo_item.dart';

class TodoService {
  static const String key = 'todo_items';

  static Future<List<TodoItem>> getTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(key) ?? [];
    return data.map((e) => TodoItem.fromJson(json.decode(e))).toList();
  }

  static Future<void> saveTodos(List<TodoItem> todos) async {
    final prefs = await SharedPreferences.getInstance();
    final data = todos.map((e) => json.encode(e.toJson())).toList();
    await prefs.setStringList(key, data);
  }
}
