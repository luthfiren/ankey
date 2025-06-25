import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CameraFlashcardPage extends StatefulWidget {
  final bool fromNewDeck;
  final int flashcardNumber;
  final String? flashcardTitle;
  final List<Map<String, dynamic>> availableDecks; // Change type

  const CameraFlashcardPage({
    super.key,
    this.fromNewDeck = false,
    this.flashcardNumber = 1,
    this.flashcardTitle,
    required this.availableDecks, // Make required
  });

  @override
  State<CameraFlashcardPage> createState() => _CameraFlashcardPageState();
}

class _CameraFlashcardPageState extends State<CameraFlashcardPage> {
  late String flashcardTitle;
  String question = '';
  String answer = '';
  int? selectedDeckId; // Use deck_id
  File? image;
  final picker = ImagePicker();

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
    bool canDone = question.trim().isNotEmpty && answer.trim().isNotEmpty && image != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(flashcardTitle, style: const TextStyle(fontWeight: FontWeight.w400)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: ListView(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      flashcardTitle,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                    ),
                  ),
                  TextButton(
                    onPressed: _renameTitle,
                    child: const Text('Rename'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Question', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickImage,
                child: DottedBorder(
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(16),
                  dashPattern: const [8, 6],
                  color: Colors.green,
                  child: Container(
                    width: double.infinity,
                    height: 240,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: image == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, size: 48, color: Colors.green),
                              const SizedBox(height: 8),
                              const Text(
                                'Take Photos/From Gallery',
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.file(image!, fit: BoxFit.cover, width: double.infinity, height: 240),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Question',
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
              Text('Answer', style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Answer',
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
              if (!widget.fromNewDeck)
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Pilih Deck (opsional)'),
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to create card')),
                            );
                          }
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

enum BorderType { RRect }

class DottedBorder extends StatelessWidget {
  final Widget child;
  final BorderType borderType;
  final Radius radius;
  final List<double> dashPattern;
  final Color color;

  const DottedBorder({
    super.key,
    required this.child,
    this.borderType = BorderType.RRect,
    this.radius = const Radius.circular(8),
    this.dashPattern = const [4, 4],
    this.color = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DottedBorderPainter(
        radius: radius,
        dashPattern: dashPattern,
        color: color,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(radius),
        child: child,
      ),
    );
  }
}

class _DottedBorderPainter extends CustomPainter {
  final Radius radius;
  final List<double> dashPattern;
  final Color color;

  _DottedBorderPainter({
    required this.radius,
    required this.dashPattern,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(Offset.zero & size, radius);
    final path = Path()..addRRect(rrect);

    double dashOn = dashPattern[0];
    double dashOff = dashPattern[1];
    double distance = 0.0;
    for (final metric in path.computeMetrics()) {
      while (distance < metric.length) {
        final next = distance + dashOn;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashOff;
      }
      distance = 0.0;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}