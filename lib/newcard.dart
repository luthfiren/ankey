import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ManualInputFlashcardPage extends StatefulWidget {
  final List<Map<String, dynamic>> availableDecks;
  final int userId;

  const ManualInputFlashcardPage({
    super.key,
    required this.availableDecks,
    required this.userId,
  });

  @override
  State<ManualInputFlashcardPage> createState() => _ManualInputFlashcardPageState();
}

class _ManualInputFlashcardPageState extends State<ManualInputFlashcardPage> {
  String flashcardTitle = "New Flashcard 1";
  String question = '';
  String answer = '';
  int? selectedDeckId;
  bool _isSubmitting = false;

  Color get mainGreen => const Color(0xFF00AA13);
  Color get softGreen => const Color(0xFFF1FFF2);

  void _renameTitle() async {
    final controller = TextEditingController(text: flashcardTitle);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Flashcard'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Enter new title",
          ),
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
    bool canDone = question.trim().isNotEmpty && answer.trim().isNotEmpty && !_isSubmitting;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(
          flashcardTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          TextButton(
            onPressed: _renameTitle,
            child: Text('Rename', style: TextStyle(color: mainGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card preview look
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                  decoration: BoxDecoration(
                    color: softGreen,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: mainGreen.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: mainGreen.withOpacity(0.14),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        flashcardTitle,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: mainGreen,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        question.isNotEmpty ? question : 'Question preview...',
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      if (answer.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Icon(Icons.check_circle_rounded, color: mainGreen, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              "Answer",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: mainGreen,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            answer,
                            style: const TextStyle(fontSize: 16, color: Colors.black),
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                const Text(
                  'Question',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Type your question here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color.fromARGB(255, 209, 209, 209)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: mainGreen, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                  onChanged: (val) {
                    question = val;
                    setState(() {});
                  },
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Answer',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 8),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Type your answer here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: const BorderSide(color: Color.fromARGB(255, 209, 209, 209)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: mainGreen, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                  ),
                  onChanged: (val) {
                    answer = val;
                    setState(() {});
                  },
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 22),
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Pilih Deck (opsional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  value: selectedDeckId,
                  items: widget.availableDecks
                      .map((deck) => DropdownMenuItem<int>(
                            value: deck['deck_id'] as int,
                            child: Text(deck['title']),
                          ))
                      .toList(),
                  onChanged: (val) {
                    setState(() {
                      selectedDeckId = val;
                    });
                  },
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canDone ? mainGreen : mainGreen.withOpacity(0.4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: canDone
                        ? () async {
                            setState(() => _isSubmitting = true);
                            final response = await http.post(
                              Uri.parse('http://10.0.2.2:5000/api/cards'),
                              headers: {'Content-Type': 'application/json'},
                              body: jsonEncode({
                                'question': question,
                                'answer': answer,
                                'id_deck': selectedDeckId,
                                'name': flashcardTitle,
                                'id_user': widget.userId,
                              }),
                            );
                            if (response.statusCode == 200) {
                              if (mounted) Navigator.pop(context, true);
                            } else {
                              setState(() => _isSubmitting = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to create card')),
                              );
                            }
                          }
                        : null,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}