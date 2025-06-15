import 'package:flutter/material.dart';

class ReviewPage extends StatelessWidget {
  final String title;
  final int flashcardCount;
  final int duration;

  const ReviewPage({
    Key? key,
    this.title = 'New Flashcard 1',
    this.flashcardCount = 5,
    this.duration = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: Icon(Icons.arrow_back, color: Colors.black),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.black, fontSize: 20),
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
                  _buildHeaderBox(),
                  const SizedBox(height: 32),
                  ...List.generate(5, (index) {
                    final number = index + 1;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Question $number",
                          style: TextStyle(
                            fontSize: 16,
                            color: number > flashcardCount ? Colors.grey : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _GreyBox(height: 60, opacity: number > flashcardCount ? 0.2 : 1.0),
                        const SizedBox(height: 16),
                        Text(
                          "Answer $number",
                          style: TextStyle(
                            fontSize: 16,
                            color: number > flashcardCount ? Colors.grey : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _GreyBox(height: 100, opacity: number > flashcardCount ? 0.2 : 1.0),
                        const SizedBox(height: 24),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ),

          // Play button fixed at bottom
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 150,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Play flashcards
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4CAF50), // hijau
                    foregroundColor: Colors.black, // teks putih
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Play!", style: TextStyle(fontSize: 18)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
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
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 6),
                  Text("Edit", style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          ),
        ],
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
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(value, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class _GreyBox extends StatelessWidget {
  final double height;
  final double opacity;

  const _GreyBox({required this.height, this.opacity = 1.0});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
