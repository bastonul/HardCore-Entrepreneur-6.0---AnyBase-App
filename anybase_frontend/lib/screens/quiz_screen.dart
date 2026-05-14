import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  final String title;
  final List<dynamic> questions;

  const QuizScreen({Key? key, required this.title, required this.questions}) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  int _score = 0;
  bool _answered = false;
  String _selectedOption = "";

  void _checkAnswer(String option) {
    if (_answered) return;

    setState(() {
      _selectedOption = option;
      _answered = true;
      if (option == widget.questions[_currentIndex]['answer']) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < widget.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _answered = false;
        _selectedOption = "";
      });
    } else {
      // Quiz Complete Dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("Quiz Completed!"),
          content: Text("Your score: $_score / ${widget.questions.length}"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // close quiz screen
              },
              child: const Text("Okay"),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = widget.questions[_currentIndex];
    final List<dynamic> options = currentQ['options'];

    return Scaffold(
      appBar: AppBar(title: Text("Quiz: ${widget.title}")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Question ${_currentIndex + 1} of ${widget.questions.length}",
              style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              currentQ['q'],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 40),
            ...options.map((option) {
              Color btnColor = Theme.of(context).colorScheme.surface;
              Color txtColor = Theme.of(context).colorScheme.onSurface;

              if (_answered) {
                if (option == currentQ['answer']) {
                  btnColor = Colors.green.shade400;
                  txtColor = Colors.white;
                } else if (option == _selectedOption) {
                  btnColor = Colors.red.shade400;
                  txtColor = Colors.white;
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: btnColor,
                    foregroundColor: txtColor,
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.centerLeft,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () => _checkAnswer(option),
                  child: Text(option, style: const TextStyle(fontSize: 16)),
                ),
              );
            }).toList(),
            const Spacer(),
            if (_answered)
              ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(20),
                ),
                child: const Text("Next", style: TextStyle(fontSize: 18)),
              )
          ],
        ),
      ),
    );
  }
}