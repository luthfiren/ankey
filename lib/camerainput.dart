import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

void main() {
  runApp(const MyApp());
}

class Flashcard {
  String question;
  String answer;
  File? image;

  Flashcard({this.question = '', this.answer = '', this.image});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera Scan',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white, // background putih
      ),
      home: const FlashcardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});
  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  String flashcardTitle = "New Flashcard 1";
  List<Flashcard> flashcards = [Flashcard()];
  final picker = ImagePicker();

  void _pickImage(int index) async {
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
        flashcards[index].image = File(pickedFile.path);
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

  Widget _buildFlashcard(int index) {
    final card = flashcards[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Question ${index + 1}', style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _pickImage(index),
          child: DottedBorder(
            borderType: BorderType.RRect,
            radius: const Radius.circular(16),
            dashPattern: const [8, 6],
            color: Colors.green,
            child: Container(
              width: double.infinity,
              height: 240,
              decoration: BoxDecoration(
                color: Colors.white, // background putih
                borderRadius: BorderRadius.circular(16),
              ),
              child: card.image == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.image_outlined, size: 48, color: Colors.black),
                        const SizedBox(height: 8),
                        const Text(
                          'Take Photos/From Gallery',
                          style: TextStyle(color: Colors.black),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.file(card.image!, fit: BoxFit.cover, width: double.infinity, height: 240),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Answer ${index + 1}', style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.green,
              width: 2,
            ),
          ),
          child: TextField(
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: (val) {
              card.answer = val;
              setState(() {}); // update tombol Done
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tombol Done aktif jika semua jawaban terisi DAN semua gambar sudah dipilih
    bool allAnswered = flashcards.every((c) => c.answer.trim().isNotEmpty);
    bool allImagesPicked = flashcards.every((c) => c.image != null);
    bool canDone = allAnswered && allImagesPicked;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Camera Scan', style: TextStyle(fontWeight: FontWeight.w400)),
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
              ...List.generate(flashcards.length, _buildFlashcard),
              GestureDetector(
                onTap: () {
                  setState(() {
                    flashcards.add(Flashcard());
                  });
                },
                child: DottedBorder(
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(12),
                  dashPattern: const [6, 4],
                  color: Colors.grey,
                  child: Container(
                    width: double.infinity,
                    height: 48,
                    alignment: Alignment.center,
                    child: const Text(
                      '+ Add More',
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
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
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Flashcards saved!')),
                          );
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

// DottedBorder widget (simple implementation)
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

enum BorderType { RRect }

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