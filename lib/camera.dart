import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CameraFlashcardPage extends StatefulWidget {
  final bool fromNewDeck;
  final int? userId;
  final int flashcardNumber;
  final String? flashcardTitle;
  final List<Map<String, dynamic>> availableDecks;

  const CameraFlashcardPage({
    super.key,
    required this.availableDecks,
    this.fromNewDeck = false,
    this.userId,
    this.flashcardNumber = 1,
    this.flashcardTitle,
  });

  @override
  State<CameraFlashcardPage> createState() => _CameraFlashcardPageState();
}

class _CameraFlashcardPageState extends State<CameraFlashcardPage> {
  late String flashcardTitle;
  String question = '';
  String answer = '';
  int? selectedDeckId;
  File? image;
  final picker = ImagePicker();
  bool _isSubmitting = false;

  Color get mainGreen => const Color(0xFF00AA13);
  Color get softGreen => const Color(0xFFF1FFF2);

  @override
  void initState() {
    super.initState();
    flashcardTitle = widget.flashcardTitle ?? "New Flashcard ${widget.flashcardNumber}";
  }

  void _pickImage() async {
    final pickedFile = await showModalBottomSheet<XFile?>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () async {
                final photo = await picker.pickImage(source: ImageSource.camera);
                Navigator.pop(context, photo);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('From Gallery'),
              onTap: () async {
                final photo = await picker.pickImage(source: ImageSource.gallery);
                Navigator.pop(context, photo);
              },
            ),
          ],
        ),
      ),
    );
    if (pickedFile != null) {
      setState(() {
        image = File(pickedFile.path);
      });
    }
  }

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
    bool canDone = question.trim().isNotEmpty && answer.trim().isNotEmpty && image != null && !_isSubmitting;

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
                // Preview Card
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
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: mainGreen.withOpacity(0.17)),
                          ),
                          child: image == null
                              ? Icon(Icons.camera_alt, color: mainGreen, size: 32)
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(image!, fit: BoxFit.cover, width: 70, height: 70),
                                ),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              flashcardTitle,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: mainGreen,
                              ),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              question.isNotEmpty ? question : 'Question preview...',
                              style: const TextStyle(fontSize: 15, color: Colors.black),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
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
                if (!widget.fromNewDeck)
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
                            String? base64Image;
                            if (image != null) {
                              final bytes = await image!.readAsBytes();
                              base64Image = base64Encode(bytes);
                            }
                            final response = await http.post(
                              Uri.parse('http://10.0.2.2:5000/api/cards'),
                              headers: {'Content-Type': 'application/json'},
                              body: jsonEncode({
                                'question': question,
                                'answer': answer,
                                'id_deck': selectedDeckId,
                                'name': flashcardTitle,
                                'image': base64Image,
                                'id_user': widget.userId,
                              }),
                            );
                            if (response.statusCode == 200) {
                              if (mounted) {
                                Navigator.pop(context, {
                                  'question': question,
                                  'answer': answer,
                                  'imagePath': image?.path,
                                  'flashcardTitle': flashcardTitle,
                                  'deck': selectedDeckId != null
                                      ? (widget.availableDecks.firstWhere(
                                          (deck) => deck['deck_id'] == selectedDeckId,
                                          orElse: () => {},
                                        )['title'] ?? '')
                                      : null,
                                });
                              }
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