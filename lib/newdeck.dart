import 'package:flutter/material.dart';
import 'camera.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class NewDeckPage extends StatefulWidget {
  final int userId;
  const NewDeckPage({super.key, required this.userId});

  @override
  State<NewDeckPage> createState() => _NewDeckPageState();
}

class _NewDeckPageState extends State<NewDeckPage> {
  String deckTitle = "New Deck";
  List<Map<String, dynamic>> flashcards = [
    {'question': '', 'answer': '', 'flashcardTitle': '', 'imagePath': null}
  ];
  int timerMinutes = 1;
  bool _isSubmitting = false;
  late TextEditingController deckTitleController;

  Color get mainGreen => const Color(0xFF00AA13);
  Color get softGreen => const Color(0xFFF1FFF2);

  void _addFlashcard() {
    setState(() {
      flashcards.add({'question': '', 'answer': '', 'flashcardTitle': '', 'imagePath': null});
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
          availableDecks: const [],
        ),
      ),
    );
    if (result != null && result is Map) {
      setState(() {
        flashcards[index]['question'] = result['question'] ?? '';
        flashcards[index]['answer'] = result['answer'] ?? '';
        flashcards[index]['imagePath'] = result['imagePath'] ?? '';
        flashcards[index]['flashcardTitle'] = result['flashcardTitle'] ?? "New Flashcard ${index + 1}";
      });
    }
  }

  Widget _buildFlashcardInput(int index) {
    final questionController = TextEditingController(text: flashcards[index]['question']?.toString() ?? '');
    final answerController = TextEditingController(text: flashcards[index]['answer']?.toString() ?? '');
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: softGreen,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  flashcards[index]['flashcardTitle']?.isNotEmpty == true
                      ? flashcards[index]['flashcardTitle']
                      : 'Flashcard ${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: mainGreen,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.camera_alt_rounded, color: mainGreen),
                  onPressed: () => _openCameraInput(index),
                  tooltip: 'Input from Camera',
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: questionController,
              style: const TextStyle(color: Colors.black, fontSize: 16),
              decoration: InputDecoration(
                labelText: 'Question',
                labelStyle: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (val) {
                flashcards[index]['question'] = val;
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: answerController,
              style: const TextStyle(color: Colors.black, fontSize: 16),
              decoration: InputDecoration(
                labelText: 'Answer',
                labelStyle: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500),
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
            const SizedBox(height: 10),
            if (flashcards[index]['imagePath'] != null && flashcards[index]['imagePath'].toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(flashcards[index]['imagePath']),
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    deckTitleController = TextEditingController(text: deckTitle);
  }

  @override
  void dispose() {
    deckTitleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = widget.userId;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Create New Deck', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Deck Title',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: deckTitleController,
                  decoration: InputDecoration(
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
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  onChanged: (val) => deckTitle = val,
                ),
                const SizedBox(height: 20),
                ...List.generate(flashcards.length, _buildFlashcardInput),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _addFlashcard,
                    icon: Icon(Icons.add, color: mainGreen),
                    label: Text('Add More', style: TextStyle(color: mainGreen, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 24),
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
                    onPressed: _isSubmitting
                        ? null
                        : () async {
                            setState(() => _isSubmitting = true);
                            try {
                              final deckResponse = await http.post(
                                Uri.parse('http://10.0.2.2:5000/api/decks'),
                                headers: {'Content-Type': 'application/json'},
                                body: jsonEncode({
                                  'name': deckTitle,
                                  'timer': timerMinutes,
                                  'user_id': widget.userId,
                                }),
                              );
                              if (deckResponse.statusCode != 200) {
                                throw Exception('Failed to create deck');
                              }
                              final deckData = jsonDecode(deckResponse.body);
                              final int deckId = deckData['deck_id'];

                              for (var i = 0; i < flashcards.length; i++) {
                                final card = flashcards[i];
                                String? base64Image;
                                if (card['imagePath'] != null && card['imagePath'].toString().isNotEmpty) {
                                  final file = File(card['imagePath']);
                                  if (await file.exists()) {
                                    final bytes = await file.readAsBytes();
                                    base64Image = base64Encode(bytes);
                                  }
                                }
                                await http.post(
                                  Uri.parse('http://10.0.2.2:5000/api/cards'),
                                  headers: {'Content-Type': 'application/json'},
                                  body: jsonEncode({
                                    'question': card['question'],
                                    'answer': card['answer'],
                                    'id_deck': deckId,
                                    'name': card['flashcardTitle']?.isNotEmpty == true
                                        ? card['flashcardTitle']
                                        : 'New Flashcard ${i + 1}',
                                    'image': base64Image,
                                  }),
                                );
                              }

                              if (mounted) Navigator.pop(context, {'created': true});
                            } catch (e) {
                              setState(() => _isSubmitting = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to create deck: $e')),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mainGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      minimumSize: const Size(120, 48),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                          )
                        : const Text('Save Deck'),
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