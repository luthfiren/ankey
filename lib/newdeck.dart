import 'package:flutter/material.dart';
import 'camera.dart';

class NewDeckPage extends StatefulWidget {
  const NewDeckPage({super.key});

  @override
  State<NewDeckPage> createState() => _NewDeckPageState();
}

class _NewDeckPageState extends State<NewDeckPage> {
  String deckTitle = "New Deck";
  List<Map<String, dynamic>> flashcards = [
    {'question': '', 'answer': ''}
  ]; // <-- pastikan dynamic, bukan String

  int timerMinutes = 1;

  void _addFlashcard() {
    setState(() {
      flashcards.add({'question': '', 'answer': ''});
    });
  }

  Future<void> _openCameraInput(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraFlashcardPage(
          fromNewDeck: true,
          flashcardNumber: index + 1,
          flashcardTitle: "New Flashcard ${index + 1}",
        ),
      ),
    );
    if (result != null && result is Map) {
      setState(() {
        flashcards[index]['question'] = result['question'] ?? '';
        flashcards[index]['answer'] = result['answer'] ?? '';
        flashcards[index]['imagePath'] = result['imagePath'] ?? '';
      });
    }
  }

  Widget _buildFlashcardInput(int index) {
    final questionController = TextEditingController(text: flashcards[index]['question']?.toString() ?? '');
    final answerController = TextEditingController(text: flashcards[index]['answer']?.toString() ?? '');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: questionController,
          style: const TextStyle(color: Colors.black, fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Question ${index + 1}',
            labelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            suffixIcon: IconButton(
              icon: const Icon(Icons.camera_alt, color: Colors.green),
              onPressed: () => _openCameraInput(index),
              tooltip: 'Input from Camera',
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (val) {
            flashcards[index]['question'] = val;
          },
        ),
        const SizedBox(height: 8),
        TextField(
          controller: answerController,
          style: const TextStyle(color: Colors.black, fontSize: 16),
          decoration: InputDecoration(
            labelText: 'Answer ${index + 1}',
            labelStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: (val) {
            flashcards[index]['answer'] = val;
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create New Deck', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: ListView(
            children: [
              const Text(
                'Deck Title',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  filled: true,
                  fillColor: Colors.white,
                ),
                style: const TextStyle(color: Colors.black, fontSize: 16),
                onChanged: (val) => deckTitle = val,
                controller: TextEditingController(text: deckTitle),
              ),
              const SizedBox(height: 20),
              ...List.generate(flashcards.length, _buildFlashcardInput),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _addFlashcard,
                  icon: const Icon(Icons.add, color: Colors.black),
                  label: const Text('Add More', style: TextStyle(color: Colors.black)),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text('Set Timer:', style: TextStyle(fontSize: 16, color: Colors.black)),
                  const SizedBox(width: 16),
                  DropdownButton<int>(
                    value: timerMinutes,
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: Colors.black, fontSize: 16),
                    items: List.generate(10, (i) => i + 1)
                        .map((val) => DropdownMenuItem(
                              value: val,
                              child: Text('$val min'),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => timerMinutes = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, {
                      'title': deckTitle,
                      'flashcards': flashcards, // sudah benar, dynamic
                      'timer': timerMinutes,
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    minimumSize: const Size(120, 44),
                  ),
                  child: const Text('Save Deck', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}