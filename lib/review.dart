import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'play.dart';
import 'package:http/http.dart' as http;

class ReviewPage extends StatefulWidget {
  final String title;
  final int duration;
  final List<Map<String, dynamic>> flashcards;

  const ReviewPage({
    super.key,
    required this.title,
    required this.flashcards,
    this.duration = 1,
  });

  @override
  State<ReviewPage> createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  bool isEditMode = false;
  late List<Map<String, dynamic>> flashcards;
  List<int> pendingDeletes = [];
  List<Map<String, dynamic>> pendingEdits = [];

  @override
  void initState() {
    super.initState();
    // Deep copy to allow editing
    flashcards = widget.flashcards.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  void _removeFlashcard(int index) {
    final cardId = flashcards[index]['id'];
    pendingDeletes.add(cardId);
    setState(() {
      flashcards.removeAt(index);
    });
  }

  void _editFlashcard(int index) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        final questionController = TextEditingController(text: flashcards[index]['question'] ?? '');
        final answerController = TextEditingController(text: flashcards[index]['answer'] ?? '');
        return AlertDialog(
          title: const Text('Edit Flashcard'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: questionController,
                decoration: const InputDecoration(labelText: 'Question'),
              ),
              TextField(
                controller: answerController,
                decoration: const InputDecoration(labelText: 'Answer'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop<Map<String, dynamic>>(context, {
                  ...flashcards[index],
                  'question': questionController.text,
                  'answer': answerController.text,
                });
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      setState(() {
        flashcards[index] = result;
        // Remove any previous edit for this card
        pendingEdits.removeWhere((e) => e['id'] == result['id']);
        pendingEdits.add(result);
      });
    }
  }

  Future<void> _commitChanges() async {
    // Delete cards
    for (final id in pendingDeletes) {
      await http.delete(Uri.parse('http://10.0.2.2:5000/api/cards/$id'));
    }
    // Edit cards
    for (final card in pendingEdits) {
      await http.put(
        Uri.parse('http://10.0.2.2:5000/api/cards/${card['id']}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'question': card['question'],
          'answer': card['answer'],
        }),
      );
    }
    pendingDeletes.clear();
    pendingEdits.clear();
  }

  Future<void> _deleteDeck() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Deck"),
        content: const Text("Are you sure you want to delete this deck and all its flashcards?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
    if (confirm == true) {
      // Assuming API endpoint for deck deletion
      final res = await http.delete(
        Uri.parse('http://10.0.2.2:5000/api/decks?title=${Uri.encodeComponent(widget.title)}'),
      );
      if (res.statusCode == 200) {
        // GO BACK TO HOMEPAGE
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete deck!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Color mainGreen = const Color(0xFF00AA13);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 90),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildHeaderBox(flashcards.length, widget.duration, mainGreen),
                  const SizedBox(height: 32),
                  ...List.generate(flashcards.length, (index) {
                    final card = flashcards[index];
                    final number = index + 1;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Question $number",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const Spacer(),
                            if (isEditMode)
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert, size: 20, color: Colors.black54),
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _editFlashcard(index);
                                  } else if (value == 'delete') {
                                    _removeFlashcard(index);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit, size: 18),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, size: 18),
                                        SizedBox(width: 8),
                                        Text('Delete'),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _WhiteBox(
                          height: 60,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: card['imageBase64'] != null && card['imageBase64'].isNotEmpty
                                  ? Row(
                                      children: [
                                        Image.memory(base64Decode(card['imageBase64'])),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            card['question'] ?? '',
                                            style: const TextStyle(fontSize: 16, color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    )
                                  : card['imagePath'] != null && card['imagePath']!.isNotEmpty
                                      ? Row(
                                          children: [
                                            Image.file(
                                              File(card['imagePath']!),
                                              width: 48,
                                              height: 48,
                                              fit: BoxFit.cover,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                card['question'] ?? '',
                                                style: const TextStyle(fontSize: 16, color: Colors.black),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          card['question'] ?? '',
                                          style: const TextStyle(fontSize: 16, color: Colors.black),
                                        ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              "Answer $number",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _WhiteBox(
                          height: 100,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                card['answer'] ?? '',
                                style: const TextStyle(fontSize: 16, color: Colors.black),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),

          // Play/Done/Edit/Delete button fixed at bottom
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Edit/Play/Done
                SizedBox(
                  width: 150,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: flashcards.isEmpty
                        ? null
                        : () async {
                            if (isEditMode) {
                              await _commitChanges();
                              setState(() {
                                isEditMode = false;
                              });
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlayFlashcardPage(
                                    title: widget.title,
                                    flashcards: flashcards,
                                  ),
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isEditMode ? "Done" : "Play!",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Delete (always visible, but with confirm dialog)
                SizedBox(
                  width: 150,
                  height: 42,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    label: const Text(
                      "Delete Deck",
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _deleteDeck,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBox(int flashcardCount, int duration, Color mainGreen) {
    return CustomPaint(
      painter: DashRectPainter(
        color: mainGreen,
        strokeWidth: 2,
        radius: 24,
        gap: 8,
        dash: 8,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Expanded(
              child: _InfoCard(
                label: "Flashcards",
                value: flashcardCount.toString(),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _InfoCard(
                label: "Minute",
                value: duration.toString(),
              ),
            ),
            const SizedBox(width: 16),
            // Edit button
            SizedBox(
              height: 42,
              child: ElevatedButton.icon(
                icon: Icon(isEditMode ? Icons.close : Icons.edit, color: Colors.white),
                label: Text(isEditMode ? "Cancel" : "Edit", style: const TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  minimumSize: const Size(80, 42),
                ),
                onPressed: () {
                  setState(() {
                    if (isEditMode) {
                      // Cancel: restore original flashcards and clear pending changes
                      flashcards = widget.flashcards.map((e) => Map<String, dynamic>.from(e)).toList();
                      pendingDeletes.clear();
                      pendingEdits.clear();
                      isEditMode = false;
                    } else {
                      // Enter edit mode
                      isEditMode = true;
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;

  const _InfoCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF00AA13), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black)),
            Text(label, style: const TextStyle(fontSize: 16, color: Colors.black)),
          ],
        ),
      ),
    );
  }
}

class _WhiteBox extends StatelessWidget {
  final double height;
  final Widget? child;

  const _WhiteBox({required this.height, this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00AA13), width: 1.5),
      ),
      child: child,
    );
  }
}

// Dashed border painter for header box
class DashRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double radius;
  final double dash;
  final double gap;

  DashRectPainter({
    required this.color,
    this.strokeWidth = 2,
    this.radius = 24,
    this.dash = 8,
    this.gap = 8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );

    _drawDashedRRect(canvas, rrect, paint, dash, gap);
  }

  void _drawDashedRRect(Canvas canvas, RRect rrect, Paint paint, double dash, double gap) {
    final Path path = Path()..addRRect(rrect);
    final PathMetrics metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double len = (distance + dash < metric.length) ? dash : metric.length - distance;
        canvas.drawPath(
          metric.extractPath(distance, distance + len),
          paint,
        );
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}