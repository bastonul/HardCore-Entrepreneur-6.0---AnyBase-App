import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FlashcardScreen extends StatefulWidget {
    final List<String> cards;
    final bool isDyslexicMode;
    final String title;

    const FlashcardScreen({
      Key? key,
      required this.cards, this.isDyslexicMode = false, required this.title,
    }) : super(key: key);

    @override
    _FlashcardScreenState createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  final PageController _pageController = PageController();
  final TtsService _ttsService = TtsService();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    _ttsService.stop();
    super.dispose();
  }

  void _playCurrentCard(){
    _ttsService.speak(widget.cards[_currentIndex]);
  }

  Future<void> _saveToLibrary() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedNotes = prefs.getStringList('my_saved_notes') ?? [];

    Map<String, dynamic> newNote = {
      'title': widget.title,
      'cards': widget.cards,
      'isDyslexic': widget.isDyslexicMode,
    };

    savedNotes.add(jsonEncode(newNote));
    await prefs.setStringList('my_saved_notes', savedNotes);

    if(mounted){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to your offline Library!')),);
    }
  }

  @override
  Widget build(BuildContext context){

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final Color bgColor = widget.isDyslexicMode ?
    (isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFFDF6E3)) : Theme.of(context).colorScheme.surface; //gray/beige
    final Color textColor = widget.isDyslexicMode ?
    (isDarkMode ? const Color(0xFFEBEBEB) : const Color(0xFF333333)) : Theme.of(context).colorScheme.onSurface;

    final fontFamily = widget.isDyslexicMode ? 'OpenDyslexic' : null;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('${widget.title} (${_currentIndex + 1}/${widget.cards.length})'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: isDarkMode ? Colors.white : Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: _playCurrentCard ,//tts button
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_add),
            onPressed: _saveToLibrary,
          ),
        ],
      ),
    body: PageView.builder(
      controller: _pageController,
        onPageChanged: (index) {
          setState (() {
            _currentIndex = index;
            _ttsService.stop();
          });
    },
    itemCount: widget.cards.length,
    itemBuilder: (context, index) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          child: Container(
            padding: const EdgeInsets.all(32.0),
            constraints: const BoxConstraints(minHeight: 300),
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Text(
                widget.cards[index],
                  style: TextStyle(
                    fontSize: 26.0,
                    color: textColor,
                    fontFamily: fontFamily,
                    height: 1.4,
                    letterSpacing: widget.isDyslexicMode? 1.2 : 0.5,
                  ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          ),
        ),
      );
    },
    ),
    );
  }
}