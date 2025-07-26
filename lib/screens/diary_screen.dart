import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../utils/theme_provider.dart';
import '../services/firestore_service.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final Color violet = const Color(0xFF8F5CFF);

  void _showAddDiaryDialog(BuildContext parentContext) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showDialog(
      context: parentContext,
      builder: (context) {
        final themeNotifier = Provider.of<ThemeProvider>(context);
        final isDark = themeNotifier.isDark;
        return Dialog(
          backgroundColor: isDark ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('New Diary',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: violet,
                    )),
                const SizedBox(height: 16),
                _buildTextField(titleController, "Title", isDark),
                const SizedBox(height: 12),
                _buildTextField(
                    contentController, "What's on your mind?", isDark,
                    maxLines: 5),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel', style: TextStyle(color: violet)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.trim().isNotEmpty &&
                            contentController.text.trim().isNotEmpty) {
                          await FirestoreService.addDiaryEntryWithTitle(
                            titleController.text.trim(),
                            contentController.text.trim(),
                          );
                          if (!mounted) return;
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: violet,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text("Save"),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hintText,
    bool isDark, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: violet),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: violet.withOpacity(0.6)),
        filled: true,
        fillColor: isDark ? Colors.grey[900] : const Color(0xFFE8E0FF),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: violet.withOpacity(0.3),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: violet,
            width: 2,
          ),
        ),
      ),
    );
  }

  void _showEditDiaryDialog(BuildContext parentContext, String oldTitle,
      String oldText, String docId) {
    final titleController = TextEditingController(text: oldTitle);
    final contentController = TextEditingController(text: oldText);

    showDialog(
      context: parentContext,
      builder: (context) {
        final themeNotifier = Provider.of<ThemeProvider>(context);
        final isDark = themeNotifier.isDark;
        return Dialog(
          backgroundColor: isDark ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Edit Diary',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: violet,
                    )),
                const SizedBox(height: 16),
                _buildTextField(titleController, "Title", isDark),
                const SizedBox(height: 12),
                _buildTextField(
                    contentController, "What's on your mind?", isDark,
                    maxLines: 5),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel', style: TextStyle(color: violet)),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.trim().isNotEmpty &&
                            contentController.text.trim().isNotEmpty) {
                          await FirestoreService.editDiaryEntry(
                            docId,
                            titleController.text.trim(),
                            contentController.text.trim(),
                          );
                          if (!mounted) return;
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: violet,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text("Save"),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDiaryDetailDialog(BuildContext parentContext, String title,
      String text, String date, String docId) {
    showDialog(
      context: parentContext,
      builder: (context) {
        final themeNotifier = Provider.of<ThemeProvider>(context);
        final isDark = themeNotifier.isDark;
        return Dialog(
          backgroundColor: isDark ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: violet,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    text,
                    style:
                        TextStyle(color: violet.withOpacity(0.8), fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    date,
                    style:
                        TextStyle(color: violet.withOpacity(0.5), fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: violet),
                        tooltip: 'Edit',
                        onPressed: () {
                          Navigator.pop(context);
                          _showEditDiaryDialog(
                              parentContext, title, text, docId);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        tooltip: 'Delete',
                        onPressed: () async {
                          await FirestoreService.deleteDiaryEntry(docId);
                          if (!mounted) return;
                          Navigator.pop(context);
                        },
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Close', style: TextStyle(color: violet)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeProvider>(context);
    final isDark = themeNotifier.isDark;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 80;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        title: Text(
          'My Diary',
          style: GoogleFonts.poppins(
            color: violet,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: violet,
        onPressed: () => _showAddDiaryDialog(context),
        tooltip: 'Add Entry',
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirestoreService.diaryEntriesStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(color: violet),
              );
            }
            final docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return Center(
                child: Text(
                  'No entries yet.',
                  style: TextStyle(
                    color: violet.withOpacity(0.5),
                    fontSize: 16,
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding),
              itemCount: docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, i) {
                final doc = docs[i];
                final data = doc.data() as Map<String, dynamic>;
                final title =
                    data.containsKey('title') ? data['title'] : 'No Title';
                final text = data['text'];
                final date = data['date'].toString().substring(0, 10);

                return AnimatedOpacity(
                  duration: Duration(milliseconds: 300 + i * 80),
                  opacity: 1,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: violet,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _showDiaryDetailDialog(
                          context, title, text, date, doc.id),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.bookmark_border,
                                color: Colors.white),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    date,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white.withOpacity(0.7),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
