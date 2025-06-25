import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:math';

class LooseFlashcardPlayPage extends StatefulWidget {
  final List<Map<String, dynamic>> flashcards;
  final String title;

  const LooseFlashcardPlayPage({
    super.key,
    required this.flashcards,
    this.title = "Loose Flashcards",
  });

  @override
  State<LooseFlashcardPlayPage> createState() => _LooseFlashcardPlayPageState();
}

class _LooseFlashcardPlayPageState extends State<LooseFlashcardPlayPage> with SingleTickerProviderStateMixin {
  int current = 0;
  bool showBack = false;
  late AnimationController _flipController;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (!showBack) {
      _flipController.forward();
      setState(() => showBack = true);
    } else {
      _flipController.reverse();
      setState(() => showBack = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.flashcards[current];
    final double cardWidth = MediaQuery.of(context).size.width - 48;
    final double cardHeight = MediaQuery.of(context).size.height * 0.36;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.flashcards.length > 1)
              Text(
                "Card ${current + 1} of ${widget.flashcards.length}",
                style: const TextStyle(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.bold),
              ),
            if (widget.flashcards.length > 1) const SizedBox(height: 16),
            GestureDetector(
              onTap: _flipCard,
              child: AnimatedBuilder(
                animation: _flipController,
                builder: (context, child) {
                  final angle = _flipController.value * pi;
                  final isUnder = (angle > pi / 2);
                  return Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle),
                    child: Container(
                      width: cardWidth,
                      height: cardHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: isUnder
                          ? Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..rotateY(pi),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Text(
                                    card['answer']?.toString() ?? '',
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            )
                          : Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Text(
                                  card['question']?.toString() ?? card['name']?.toString() ?? '',
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              showBack ? 'Tap to flip to Question' : 'Tap to flip to Answer',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}