import 'package:flutter/material.dart';
import 'newdeck.dart';
import 'review.dart';
import 'camera.dart';
import 'newcard.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> decks = [
    {
      'title': 'History',
      'flashcards': [
        {'question': 'Kapan proklamasi?', 'answer': '1945'},
        {'question': 'Siapa presiden pertama?', 'answer': 'Soekarno'},
      ]
    },
    {
      'title': 'Biology',
      'flashcards': [
        {'question': 'Sel terkecil?', 'answer': 'Prokariotik'},
        {'question': 'Fotosintesis terjadi di?', 'answer': 'Kloroplas'},
      ]
    },
  ];

  final List<Map<String, String>> looseFlashcards = [
    {'title': 'New Flashcard 1', 'time': '19.00'},
    {'title': 'New Flashcard 2', 'time': '18.00'},
    {'title': 'New Flashcard 3', 'time': '19.00'},
  ];

  @override
  Widget build(BuildContext context) {
    const double boxHeight = 100;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Welcome, Sobat Ankey!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Search bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'search',
                    icon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Create Flashcard',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        // MANUAL INPUT ACTION
                        final result = await Navigator.push<Map<String, dynamic>>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManualInputFlashcardPage(
                              availableDecks: decks.map<String>((d) => d['title'] as String).toList(),
                            ),
                          ),
                        );
                        if (result != null) {
                          if (result['deck'] != null) {
                            final deckIndex = decks.indexWhere((d) => d['title'] == result['deck']);
                            if (deckIndex != -1) {
                              setState(() {
                                (decks[deckIndex]['flashcards'] as List).add({
                                  'question': result['question'],
                                  'answer': result['answer'],
                                });
                              });
                            }
                          } else {
                            setState(() {
                              looseFlashcards.add({
                                'title': result['question'],
                                'time': TimeOfDay.now().format(context),
                              });
                            });
                          }
                        }
                      },
                      child: Container(
                        height: boxHeight,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.edit, size: 28),
                            const SizedBox(height: 4),
                            const Text('Manual Input', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        // CAMERA SCAN ACTION
                        final result = await Navigator.push<Map<String, dynamic>>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CameraFlashcardPage(
                              fromNewDeck: false,
                              availableDecks: decks.map<String>((d) => d['title'] as String).toList(),
                            ),
                          ),
                        );
                        if (result != null) {
                          if (result['deck'] != null) {
                            final deckIndex = decks.indexWhere((d) => d['title'] == result['deck']);
                            if (deckIndex != -1) {
                              setState(() {
                                (decks[deckIndex]['flashcards'] as List).add({
                                  'question': result['question'],
                                  'answer': result['answer'],
                                });
                              });
                            }
                          } else {
                            setState(() {
                              looseFlashcards.add({
                                'title': result['question'],
                                'time': TimeOfDay.now().format(context),
                              });
                            });
                          }
                        }
                      },
                      child: Container(
                        height: boxHeight,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.camera_alt, size: 28),
                            const SizedBox(height: 4),
                            const Text('Camera Scan', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Recent Files',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              // Decks horizontal swipe
              SizedBox(
                height: boxHeight,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: decks.length + 1,
                  itemBuilder: (context, idx) {
                    if (idx < decks.length) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReviewPage(
                                title: decks[idx]['title'],
                                flashcards: decks[idx]['flashcards'],
                                duration: 1, // atau sesuai kebutuhan
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: boxHeight,
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Text(
                              decks[idx]['title'],
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      );
                    } else {
                      // Add Group button
                      return GestureDetector(
                        onTap: () async {
                          // Navigasi ke NewDeckPage dan tunggu hasilnya
                          final newDeck = await Navigator.push<Map<String, dynamic>>(
                            context,
                            MaterialPageRoute(builder: (context) => const NewDeckPage()),
                          );
                          if (newDeck != null && newDeck['title'] != null && newDeck['flashcards'] != null) {
                            setState(() {
                              decks.add({
                                'title': newDeck['title'],
                                'flashcards': newDeck['flashcards'],
                              });
                            });
                          }
                        },
                        child: Container(
                          width: boxHeight,
                          margin: const EdgeInsets.only(right: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.add, size: 28, color: Colors.grey),
                                SizedBox(height: 4),
                                Text('Add Group', style: TextStyle(fontSize: 13, color: Colors.grey)),
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Loose flashcards list
              Expanded(
                child: ListView.separated(
                  itemCount: looseFlashcards.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, idx) {
                    final card = looseFlashcards[idx];
                    return ListTile(
                      leading: const Icon(Icons.note, color: Colors.blue),
                      title: Text(card['title']!),
                      trailing: Text(card['time']!),
                      onTap: () {
                        // TODO: Open flashcard
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}