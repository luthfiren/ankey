import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math';

// Firework animation widget
class FireworkConfetti extends StatefulWidget {
  final bool show;
  const FireworkConfetti({super.key, required this.show});

  @override
  State<FireworkConfetti> createState() => _FireworkConfettiState();
}

class _FireworkConfettiState extends State<FireworkConfetti> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    if (widget.show) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant FireworkConfetti oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.show && !oldWidget.show) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Simple firework particle painter
  @override
  Widget build(BuildContext context) {
    if (!widget.show) return const SizedBox.shrink();
    return IgnorePointer(
      child: CustomPaint(
        size: MediaQuery.of(context).size,
        painter: _FireworkPainter(_controller),
        willChange: true,
      ),
    );
  }
}

class _FireworkPainter extends CustomPainter {
  final Animation<double> animation;
  _FireworkPainter(this.animation) : super(repaint: animation);

  final List<Color> colors = [
    Colors.redAccent,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.yellow,
    Colors.blue,
    Colors.pink,
  ];
  final int particles = 44;

  @override
  void paint(Canvas canvas, Size size) {
    final time = animation.value;
    final centerPoints = [
      Offset(size.width / 2, size.height / 3),
      Offset(size.width / 3, size.height / 2),
      Offset(size.width * 2 / 3, size.height / 2),
    ];
    for (final center in centerPoints) {
      for (var i = 0; i < particles; i++) {
        final angle = (2 * pi / particles) * i;
        final radius = Curves.easeOut.transform(time) * 110 * (0.7 + 0.7 * (i % 2));
        final dx = center.dx + cos(angle) * radius;
        final dy = center.dy + sin(angle) * radius;
        final color = colors[(i + (center.dx ~/ 40)) % colors.length];
        final paint = Paint()
          ..color = color.withOpacity(1 - time)
          ..strokeWidth = 4 - 2 * time
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(center, Offset(dx, dy), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FireworkPainter oldDelegate) => true;
}

class PlayFlashcardPage extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> flashcards;
  const PlayFlashcardPage({
    super.key,
    this.title = 'New Flashcard 1',
    this.flashcards = const [
      {'question': 'Lorem ipsum?', 'answer': 'Dolor sit amet.'},
      {'question': 'Apa itu Flutter?', 'answer': 'Framework UI dari Google.'},
      {'question': '2 + 2 = ?', 'answer': '4'},
      {'question': 'Ibukota Indonesia?', 'answer': 'Jakarta'},
      {'question': 'Warna daun?', 'answer': 'Hijau'},
    ],
  });

  @override
  State<PlayFlashcardPage> createState() => _PlayFlashcardPageState();
}

class _PlayFlashcardPageState extends State<PlayFlashcardPage> with SingleTickerProviderStateMixin {
  int current = 0;
  bool showAnswer = false;
  int correct = 0;
  int secondsLeft = 60;
  bool finished = false;
  late final PageController _pageController;
  bool lastAnswerWrong = false;

  // For flip animation
  late AnimationController _flipController;
  bool isFront = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      if (finished || secondsLeft == 0) return false;
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) setState(() => secondsLeft--);
      return !finished && secondsLeft > 0;
    });
  }

  void _nextCard(bool isCorrect) {
    if (isCorrect) correct++;
    if (!isCorrect) {
      setState(() {
        lastAnswerWrong = true;
      });
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        if (current < widget.flashcards.length - 1) {
          setState(() {
            current++;
            showAnswer = false;
            lastAnswerWrong = false;
            isFront = true;
            _flipController.reverse();
          });
          _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        } else {
          setState(() {
            finished = true;
          });
        }
      });
    } else {
      if (current < widget.flashcards.length - 1) {
        setState(() {
          current++;
          showAnswer = false;
          lastAnswerWrong = false;
          isFront = true;
          _flipController.reverse();
        });
        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      } else {
        setState(() {
          finished = true;
        });
      }
    }
  }

  void _flipCard() {
    if (!showAnswer) {
      _flipController.forward();
      setState(() {
        showAnswer = true;
        isFront = false;
      });
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = MediaQuery.of(context).size.width - 48;
    final double cardHeight = MediaQuery.of(context).size.height * 0.36;

    double scorePercent = correct / widget.flashcards.length;

    if (finished || secondsLeft == 0) {
      // Result Page + Firework if score >= 80%
      bool showFirework = scorePercent >= 0.8;
      return Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: const BackButton(color: Colors.black),
              title: Text(widget.title, style: const TextStyle(color: Colors.black)),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (showFirework)
                    const SizedBox(height: 170), // Space for confetti
                  const Text('Congratulations!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 32),
                  Text(
                    '$correct of ${widget.flashcards.length}\nQuestions answered',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$secondsLeft\nseconds left!',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      child: Text('Done', style: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Animasi petasan/confetti
          if (showFirework)
            const Positioned.fill(
              child: IgnorePointer(
                child: FireworkConfetti(show: true),
              ),
            ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(widget.title, style: const TextStyle(color: Colors.black)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Text(
              '${(secondsLeft / 60).floor()}:${(secondsLeft % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: LinearProgressIndicator(
              value: (current + 1) / widget.flashcards.length,
              backgroundColor: Colors.grey[300],
              color: Colors.green,
              minHeight: 6,
            ),
          ),
          // Step indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(widget.flashcards.length, (i) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    height: 4,
                    decoration: BoxDecoration(
                      color: i <= current ? Colors.green : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.flashcards.length,
              itemBuilder: (context, idx) {
                final card = widget.flashcards[idx];
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: _flipCard,
                      child: Center(
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
                                  color: lastAnswerWrong && showAnswer
                                      ? Colors.red[200]
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: !showAnswer
                                        ? Colors.grey[400]!
                                        : lastAnswerWrong
                                            ? Colors.red
                                            : Colors.green,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    )
                                  ],
                                ),
                                child: isUnder
                                    ? Transform(
                                        alignment: Alignment.center,
                                        transform: Matrix4.identity()..rotateY(pi),
                                        child: Center(
                                          child: Text(
                                            card['answer'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.black,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            if (card['imageBase64'] != null && card['imageBase64'].isNotEmpty)
                                              Image.memory(
                                                base64Decode(card['imageBase64']),
                                                fit: BoxFit.cover,
                                                key: ValueKey(card['id']),
                                              ),
                                            if ((card['imageBase64'] == null || card['imageBase64'].isEmpty) &&
                                                card['imagePath'] != null && card['imagePath'].isNotEmpty)
                                              Image.file(
                                                File(card['imagePath']!),
                                                fit: BoxFit.cover,
                                                key: ValueKey(card['id']),
                                              ),
                                            if (card['question'] != null && card['question']!.isNotEmpty)
                                              Container(
                                                alignment: Alignment.bottomCenter,
                                                padding: const EdgeInsets.all(16),
                                                child: Container(
                                                  color: card['imagePath'] != null && card['imagePath']!.isNotEmpty
                                                      ? Colors.black.withOpacity(0.5)
                                                      : Colors.transparent,
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  child: Text(
                                                    card['question'] ?? '',
                                                    style: TextStyle(
                                                      fontSize: 22,
                                                      fontWeight: FontWeight.w500,
                                                      color: card['imagePath'] != null && card['imagePath']!.isNotEmpty
                                                          ? Colors.white
                                                          : Colors.black,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      showAnswer ? 'Is your answer correct?' : 'Tap to flip and see the answer!',
                      style: const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 24),
                    if (showAnswer)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () => _nextCard(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              child: Text('Yes', style: TextStyle(fontSize: 18)),
                            ),
                          ),
                          const SizedBox(width: 24),
                          ElevatedButton(
                            onPressed: () => _nextCard(false),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              child: Text('No', style: TextStyle(fontSize: 18)),
                            ),
                          ),
                        ],
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}