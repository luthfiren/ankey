import 'package:flutter/material.dart';

class FlashcardView extends StatefulWidget {
  const FlashcardView({super.key});

  @override
  State<FlashcardView> createState() => _FlashcardViewState();
}

class _FlashcardViewState extends State<FlashcardView> {
  bool isFlipped = false;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    final double cardWidth = screenWidth * 0.88;
    final double cardHeight = screenHeight * 0.38;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: const Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Icon(Icons.arrow_back, color: Colors.black),
          ),
          title: const Text(
            'New Flashcard 1',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20, // Samakan dengan ReviewPage
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              child: Row(
                children: List.generate(
                  5,
                  (index) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      height: 5,
                      decoration: BoxDecoration(
                        color: index == 0 ? Color(0xFF4CAF50) : Colors.grey[300],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Flashcard
            GestureDetector(
              onTap: () {
                setState(() {
                  isFlipped = !isFlipped;
                });
              },
              child: Container(
                width: cardWidth,
                height: cardHeight,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    isFlipped ? "Dolor sit amet." : "Lorem ipsum?",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 26),

            // Text or Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: isFlipped
                  ? Column(
                      children: [
                        const Text(
                          "Is your answer correct?",
                          style: TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _actionButton("Yes"),
                            const SizedBox(width: 16),
                            _actionButton("No"),
                          ],
                        ),
                      ],
                    )
                  : const Text(
                      "Flip to see the answer!",
                      style: TextStyle(fontSize: 13),
                    ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _actionButton(String text) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.grey[300],
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      onPressed: () {
        // Implement action
      },
      child: Text(text),
    );
  }
}
