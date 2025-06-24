import 'package:flutter/material.dart';
import 'dart:io';

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

class _PlayFlashcardPageState extends State<PlayFlashcardPage> {
  int current = 0;
  bool showAnswer = false;
  int correct = 0;
  int secondsLeft = 60;
  bool finished = false;
  late final PageController _pageController;
  bool lastAnswerWrong = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
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
        });
        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      } else {
        setState(() {
          finished = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (finished || secondsLeft == 0) {
      // Result Page
      return Scaffold(
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
      );
    }

    final double cardWidth = MediaQuery.of(context).size.width - 48; // 24 padding kiri-kanan
    final double cardHeight = MediaQuery.of(context).size.height * 0.36; // lebih tinggi

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
                      onTap: () {
                        if (!showAnswer) {
                          setState(() {
                            showAnswer = true;
                          });
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
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
                        ),
                        child: showAnswer
                            ? Center(
                                child: Text(
                                  card['answer'] ?? '',
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500, color: Colors.black),
                                  textAlign: TextAlign.center,
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    if (card['imagePath'] != null && card['imagePath']!.isNotEmpty)
                                      Image.file(
                                        File(card['imagePath']!),
                                        fit: BoxFit.cover,
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
                    ),
                    const SizedBox(height: 24),
                    Text(
                      showAnswer ? 'Is your answer correct?' : 'Flip to see the answer!',
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