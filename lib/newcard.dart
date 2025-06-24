import 'package:flutter/material.dart';

class ManualInputFlashcardPage extends StatefulWidget {
  final List<String> availableDecks;

  const ManualInputFlashcardPage({
    super.key,
    required this.availableDecks,
  });

  @override
  State<ManualInputFlashcardPage> createState() => _ManualInputFlashcardPageState();
}

class _ManualInputFlashcardPageState extends State<ManualInputFlashcardPage> {
  String flashcardTitle = "New Flashcard 1";
  String question = '';
  String answer = '';
  String? selectedDeck;

  void _renameTitle() async {
    final controller = TextEditingController(text: flashcardTitle);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Flashcard'),
        content: TextField(
          controller: controller,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (newTitle != null && newTitle.trim().isNotEmpty) {
      setState(() {
        flashcardTitle = newTitle.trim();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool canDone = question.trim().isNotEmpty && answer.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(flashcardTitle, style: const TextStyle(fontWeight: FontWeight.w400)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          TextButton(
            onPressed: _renameTitle,
            child: const Text('Rename', style: TextStyle(color: Colors.deepPurple)),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: ListView(
            children: [
              const SizedBox(height: 8),
              Text(
                flashcardTitle,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              const Text('Question', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Question',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onChanged: (val) {
                  question = val;
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),
              const Text('Answer', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Answer',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onChanged: (val) {
                  answer = val;
                  setState(() {});
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Pilih Deck (opsional)'),
                value: selectedDeck,
                items: widget.availableDecks
                    .map((deck) => DropdownMenuItem(
                          value: deck,
                          child: Text(deck),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    selectedDeck = val;
                  });
                },
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canDone
                        ? Colors.green
                        : Colors.green.withOpacity(0.4),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    minimumSize: const Size(100, 40),
                  ),
                  onPressed: canDone
                      ? () async {
                          Navigator.pop(context, {
                            'question': question,
                            'answer': answer,
                            'deck': selectedDeck, // null jika tidak pilih deck
                          });
                        }
                      : null,
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}