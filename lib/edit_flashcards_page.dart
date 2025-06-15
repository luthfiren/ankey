import 'package:flutter/material.dart';

class EditFlashcardsPage extends StatefulWidget {
  const EditFlashcardsPage({super.key});

  @override
  State<EditFlashcardsPage> createState() => _EditFlashcardsPageState();
}

class _EditFlashcardsPageState extends State<EditFlashcardsPage> {
  List<Map<String, String>> flashcards = [
    {"question": "Lorem ipsum?", "answer": "Dolor sit amet."},
    {"question": "Lorem ipsum?", "answer": "Dolor sit amet."},
  ];

  void _addFlashcard() {
    setState(() {
      flashcards.add({"question": "", "answer": ""});
    });
  }

  void _deleteFlashcard(int index) {
    setState(() {
      flashcards.removeAt(index);
    });
  }

  void _saveFlashcards() {
    // TODO: Implement actual save logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Flashcards saved!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit New Flashcard 1',
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: flashcards.length + 1,
              itemBuilder: (context, index) {
                if (index == flashcards.length) {
                  return Center(
                    child: OutlinedButton.icon(
                      onPressed: _addFlashcard,
                      icon: const Icon(Icons.add),
                      label: const Text("Add More"),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.grey,
                          width: 1.5,
                          style: BorderStyle.solid,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Question ${index + 1}", style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: flashcards[index]['question'],
                        decoration: const InputDecoration(
                          hintText: "Enter question",
                          filled: true,
                          fillColor: Color(0xFFF5F5F5),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) => flashcards[index]['question'] = value,
                      ),
                      const SizedBox(height: 16),
                      Text("Answer ${index + 1}", style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      TextFormField(
                        initialValue: flashcards[index]['answer'],
                        decoration: const InputDecoration(
                          hintText: "Enter answer",
                          filled: true,
                          fillColor: Color(0xFFF5F5F5),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) => flashcards[index]['answer'] = value,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => _deleteFlashcard(index),
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text("Delete", style: TextStyle(color: Colors.red)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Save Button
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: SizedBox(
              width: 160,
              height: 48,
              child: ElevatedButton(
                onPressed: _saveFlashcards,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50), // Green
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text("Done", style: TextStyle(fontSize: 18)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
