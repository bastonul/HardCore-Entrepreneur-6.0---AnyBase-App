import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'flashcard_screen.dart';
import '../services/api_service.dart';
import 'quiz_screen.dart';

class LibraryScreen extends StatefulWidget {

    final bool isQuizSelectionMode;
    const LibraryScreen({Key? key, this.isQuizSelectionMode = false}) : super(key: key);

    @override
    _LibraryScreenState createState() => _LibraryScreenState();
  }

class _LibraryScreenState extends State<LibraryScreen> {

    List<Map<String, dynamic>> _savedNotes = [];

    @override
    void initState (){
      super.initState();
      _loadNotes();
    }

    Future<void> _loadNotes() async {
      final prefs = await SharedPreferences.getInstance();
      List<String> notesJson = prefs.getStringList('my_saved_notes') ?? [];

      setState(() { _savedNotes = notesJson.map((item) => jsonDecode(item) as Map<String, dynamic>).toList(); });
    }
    Future<void> _deleteNote( int index ) async {
      final prefs = await SharedPreferences.getInstance();
      List<String> notesJson = prefs.getStringList('my_saved_notes') ?? [];
      notesJson.removeAt(index);
      await prefs.setStringList('my_saved_notes', notesJson);
      _loadNotes();
    }

    @override
    Widget build(BuildContext context) {
      final theme = Theme.of(context);
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text('My Offline Library'),
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: _savedNotes.isEmpty ?
          const Center(child: Text("No saved notes yet. Go adapt some texts!"))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _savedNotes.length,
                itemBuilder: (context, index) {
                  final note = _savedNotes[index];
                  return Card(
                  color: theme.colorScheme.surface,
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading:  Icon(Icons.menu_book, color: theme.colorScheme.primary),
                    title: Text(note['title'] ?? 'Untitled'),
                    subtitle: Text("${List<String>.from(note['cards']).length} cards saved",
                      style: TextStyle(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7)
                      ),
                    ),
                    trailing: IconButton(
                      onPressed: () => _deleteNote(index),
                      icon: Icon(Icons.delete_outline, color: Colors.red,),
                    ),
                  onTap: () async {
                    if (widget.isQuizSelectionMode) {
                      // FLUXUL DE QUIZ
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) =>
                        const Center(child: CircularProgressIndicator()),
                      );

                      try {
                        String joinedText = List<String>.from(note['cards'])
                            .join(" "); //text joining

                        final questions = await ApiService.generateQuiz(
                            joinedText, "DEFAULT"); //quiz request

                        if (context.mounted) {
                          Navigator.pop(context); // close loading
                          if (questions.isEmpty) throw Exception(
                              "AI didn't generate questions.");

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  QuizScreen(
                                    title: note['title'] ?? 'Quiz',
                                    questions: questions,
                                  ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          Navigator.pop(context); // close loading 2
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')));
                        }
                      }
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FlashcardScreen(
                                cards: List<String>.from(note['cards']),
                                isDyslexicMode: note['isDyslexic'] ?? false,
                                title: note['title'] ?? 'Library',
                              ),
                        ),
                      );
                    };
                  }
                  ),
                  );

                },
        ),
      );
    }
}
