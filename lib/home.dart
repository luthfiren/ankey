import 'package:flutter/material.dart';
import 'newdeck.dart';
import 'review.dart';
import 'camera.dart';
import 'newcard.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  final int userId;
  const HomePage({super.key, required this.userId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> decks = [];

  List<Map<String, dynamic>> looseFlashcards = [];

  @override
  void initState() {
    super.initState();
    fetchDecks();
    looseFlashcards.addAll([
      {'title': 'New Flashcard 1', 'time': '19.00'},
      {'title': 'New Flashcard 2', 'time': '18.00'},
      {'title': 'New Flashcard 3', 'time': '19.00'},
    ]);
  }

  Future<void> fetchDecks() async {
    final userId = widget.userId;
    final response = await http.get(Uri.parse('http://10.0.2.2:5000/api/decks?user_id=$userId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        decks = data.cast<Map<String, dynamic>>();
      });
    } else {
      print('Failed to load decks');
    }
  }

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
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManualInputFlashcardPage(
                              availableDecks: decks,
                            ),
                          ),
                        );
                        if (result == true) {
                          fetchDecks();
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
                          print('DEBUG result: $result');
                          if (result['deck'] != null && (result['deck'] as String).trim().isNotEmpty) {
                            final deckIndex = decks.indexWhere(
                              (d) => d['title'].toString().trim() == (result['deck'] as String).trim(),
                            );
                            print('DEBUG deckIndex: $deckIndex');
                            if (deckIndex != -1) {
                              setState(() {
                                (decks[deckIndex]['flashcards'] as List).add({
                                  'question': result['question'],
                                  'answer': result['answer'],
                                  if (result['imagePath'] != null) 'imagePath': result['imagePath'],
                                });
                              });
                              print('DEBUG flashcards in deck: ${decks[deckIndex]['flashcards']}');
                            } else {
                              print('DEBUG: Deck not found, masuk looseFlashcards');
                              setState(() {
                                looseFlashcards.add({
                                  'title': (result['question'] ?? '').toString(),
                                  'time': TimeOfDay.now().format(context),
                                });
                              });
                            }
                          } else {
                            setState(() {
                              looseFlashcards.add({
                                'title': (result['question'] ?? '').toString(),
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
              SizedBox(
                height: boxHeight,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: decks.length + 1,
                  itemBuilder: (context, idx) {
                    if (idx < decks.length) {
                      final deck = decks[idx];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReviewPage(
                                title: deck['title'],
                                flashcards: (deck['flashcards'] as List).cast<Map<String, dynamic>>(),
                                duration: 1,
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
                              deck['title'] ?? '',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      );
                    } else {
                      // "Add Group" button
                      return GestureDetector(
                        onTap: () async {
                          final newDeck = await Navigator.push<Map<String, dynamic>>(
                            context,
                            MaterialPageRoute(builder: (context) => const NewDeckPage()),
                          );
                          if (newDeck != null && newDeck['title'] != null && newDeck['flashcards'] != null) {
                            setState(() {
                              decks.add({
                                'title': newDeck['title'],
                                'flashcards': (newDeck['flashcards'] as List).cast<Map<String, dynamic>>(),
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
              Expanded(
                child: ListView.separated(
                  itemCount: looseFlashcards.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, idx) {
                    final card = looseFlashcards[idx];
                    return ListTile(
                      leading: const Icon(Icons.note, color: Colors.blue),
                      title: Text(card['title']?.toString() ?? ''),
                      trailing: Text(card['time']?.toString() ?? ''),
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