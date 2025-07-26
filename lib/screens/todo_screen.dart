// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/theme_provider.dart';
import '../services/firestore_service.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final Color violet = const Color(0xFF8F5CFF); // Strong violet
  final Color lightViolet =
      const Color(0xFFD6C4FF); // More saturated light violet

  void _showAddTaskDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Provider.of<ThemeProvider>(context).isDark;
        return Dialog(
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add New Task',
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: violet,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller,
                  autofocus: true,
                  style: GoogleFonts.poppins(
                    color: isDark ? Colors.white : violet,
                  ),
                  decoration: InputDecoration(
                    hintText: "Enter your task...",
                    hintStyle: GoogleFonts.poppins(
                      color: isDark ? Colors.grey : violet.withOpacity(0.6),
                    ),
                    filled: true,
                    fillColor: isDark
                        ? Colors.grey[850]
                        : lightViolet.withOpacity(0.4),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: violet.withOpacity(0.4)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: violet.withOpacity(0.4)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: violet, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: violet,
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        final task = controller.text.trim();
                        if (task.isNotEmpty) {
                          await FirestoreService.addTodo(task);
                          if (!mounted) return;
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Task added',
                                style: GoogleFonts.poppins(),
                              ),
                              backgroundColor: violet,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: violet,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: Text(
                        'Add Task',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'To-Do List',
          style: GoogleFonts.poppins(
            color: violet,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: violet,
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirestoreService.todoStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: violet),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_outlined,
                          size: 50, color: violet.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text(
                        'No tasks yet',
                        style: GoogleFonts.poppins(
                          color: isDark ? Colors.grey : violet.withOpacity(0.6),
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final docs = snapshot.data!.docs;

              return ListView.separated(
                itemCount: docs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final task = doc['task'];
                  final done = doc['done'] ?? false;

                  return Dismissible(
                    key: Key(doc.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.redAccent,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) async {
                      await FirestoreService.deleteTodo(doc.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Task deleted',
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? violet.withOpacity(0.2)
                            : lightViolet.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: violet.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ListTile(
                        leading: Checkbox(
                          value: done,
                          onChanged: (value) async {
                            await FirestoreService.updateTodo(
                                doc.id, value ?? false);
                          },
                          activeColor: violet,
                          checkColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        title: Text(
                          task,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black,
                            decoration:
                                done ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.redAccent),
                          onPressed: () async {
                            await FirestoreService.deleteTodo(doc.id);
                          },
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
