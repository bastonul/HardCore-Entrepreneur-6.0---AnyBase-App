import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'flashcard_screen.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:docx_to_text/docx_to_text.dart';
import 'library.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onThemeToggle;
  const HomeScreen({Key? key, this.onThemeToggle}) :super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _ProfileGridButton extends StatelessWidget {
    final IconData icon;
    final String label;
    final VoidCallback onTap;

    const _ProfileGridButton({
      required this.icon,
      required this.label,
      required this.onTap,
    });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: primaryColor.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeScreenState extends State<HomeScreen>{

  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;

  Future<void> _pickAndExtractFile() async {
    try{
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'pdf', 'docx']
        );
      if(result != null && result.files.single.path != null){
        setState(() { _isLoading = true; });

        String path = result.files.single.path!;
        String extension = result.files.single.extension ?? '';
        String extractedText = '';

        if(extension =='txt'){
          extractedText = await File(path).readAsString();
        } else if(extension == 'pdf'){
          final PdfDocument document = PdfDocument(inputBytes: await File(path).readAsBytes());
          extractedText = PdfTextExtractor(document).extractText();
          document.dispose();
        }
        else if(extension == 'docx'){
          final bytes = await File(path).readAsBytes();
          extractedText = docxToText(bytes);
        }
        setState(() { _textController.text = extractedText;
        _isLoading = false;
        });

      }
    } catch(e) {
      setState(() { _isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ERROR WHEN READING THE FILES: $e')));
    }
  }
  //text chunking
  List<String> _chunkText(String text, int chunkSize) {
    List<String> chunks = [];
    for (int i = 0; i < text.length; i += chunkSize) {
      int end = (i + chunkSize < text.length) ? i + chunkSize : text.length;
      chunks.add(text.substring(i, end));
    }
    return chunks;
  }

  void _processText(String profile) async {
    if(_textController.text.trim().isEmpty) return;

    setState(() { _isLoading = true; });

    try {
      final String fullText = _textController.text;
      final int maxCharsPerChunk = 5000;

      List<String> allCards = [];
      String generatedTitle = profile;
      final isDyslexic = profile == "DYSLEXIA";

      List<String> chunks = _chunkText(fullText, maxCharsPerChunk);

      for (int i = 0; i < chunks.length; i++) {
        debugPrint('I send the chunk: ${i + 1} from ${chunks.length}...');

        final responseMap = await ApiService.adaptContent(chunks[i], profile);
        if (i == 0) {
          generatedTitle = responseMap['title'];
        }
        allCards.addAll(responseMap['cards'] as List<String>);
      }

      if(mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FlashcardScreen(
            cards: allCards,
            isDyslexicMode: isDyslexic,
            title: generatedTitle,
          ),
          ),
        );
      }
    } catch(e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),

      );
    } finally {
      if (mounted)
        setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AnyBase'),
        actions: [
          IconButton(
            icon: const Icon(Icons.library_books),
            tooltip: 'My Library',
            onPressed: (){
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LibraryScreen())
              );
            },
          ),
          if (widget.onThemeToggle != null)
            IconButton(
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode_outlined),
              tooltip: 'Toggle Theme',
              onPressed: widget.onThemeToggle,
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: TextField(
                controller: _textController,
                maxLines: 6,
                minLines: 5,
                decoration:  InputDecoration(
                  hintText: "Insert the complete text here...",
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(20),
                  suffixIcon: IconButton(

                    icon: Icon(Icons.attach_file, color: Theme.of(context).colorScheme.primary),
                    tooltip: "Insert files (.txt or .pdf)",
                    onPressed: _pickAndExtractFile,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // profiles
            const Text(
              "Adaptation Profiles",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            if(_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _ProfileGridButton(
                    icon: Icons.spellcheck,
                    label: "DYSLEXIA",
                    onTap: () => _processText("DYSLEXIA"),
                  ),
                  _ProfileGridButton(
                    icon: Icons.psychology_outlined,
                    label: "ADHD",
                    onTap: () => _processText("ADHD"),
                  ),
                  _ProfileGridButton(
                    icon: Icons.format_list_bulleted,
                    label: "AUTISM",
                    onTap: () => _processText("AUTISM"),
                  ),
                  _ProfileGridButton(
                    icon: Icons.volume_up_outlined,
                    label: "PURE AUDIO",
                    onTap: () => _processText("AUDIO_TTS"),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}