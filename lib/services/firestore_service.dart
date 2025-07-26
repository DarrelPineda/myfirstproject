import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;
  static String get _uid => FirebaseAuth.instance.currentUser!.uid;

  // Diary
  static Future<void> addDiaryEntry(String text) async {
    final now = DateTime.now().toIso8601String();
    await _db
        .collection('users')
        .doc(_uid)
        .collection('diary')
        .doc(now)
        .set({'text': text, 'date': now});
  }

  static Future<void> addDiaryEntryWithTitle(String title, String text) async {
    final now = DateTime.now().toIso8601String();
    await _db
        .collection('users')
        .doc(_uid)
        .collection('diary')
        .doc(now)
        .set({'title': title, 'text': text, 'date': now});
  }

  // Edit diary entry (title and text)
  static Future<void> editDiaryEntry(
      String docId, String newTitle, String newText) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('diary')
        .doc(docId)
        .update({'title': newTitle, 'text': newText});
  }

  static Stream<QuerySnapshot> diaryEntriesStream() {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('diary')
        .orderBy('date', descending: true)
        .snapshots();
  }

  static Future<void> deleteDiaryEntry(String id) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('diary')
        .doc(id)
        .delete();
  }

  // To-Do
  static Future<void> addTodo(String task) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('todo')
        .add({'task': task, 'done': false});
  }

  static Stream<QuerySnapshot> todoStream() {
    return _db.collection('users').doc(_uid).collection('todo').snapshots();
  }

  static Future<void> updateTodo(String id, bool done) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('todo')
        .doc(id)
        .update({'done': done});
  }

  static Future<void> deleteTodo(String id) async {
    await _db.collection('users').doc(_uid).collection('todo').doc(id).delete();
  }

  static Future<void> editTodo(String docId, String newTask) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('todo')
        .doc(docId)
        .update({'task': newTask});
  }

  static Future<void> restoreTodo(String docId, String task, bool done) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('todo')
        .doc(docId)
        .set({'task': task, 'done': done});
  }
}
