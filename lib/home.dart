import 'package:flutter/material.dart';
import 'newdeck.dart';
import 'review.dart';
import 'camera.dart';
import 'newcard.dart';
import 'playdeckless.dart';
import 'main.dart'; 
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
    fetchLooseFlashcards();
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

  Future<void> fetchLooseFlashcards() async {
    final userId = widget.userId;
    final response = await http.get(Uri.parse('http://10.0.2.2:5000/api/cards/loose?user_id=$userId'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        looseFlashcards = data.cast<Map<String, dynamic>>();
      });
    } else {
      print('You have no Loose Flashcards');
    }
  }

  Color get mainGreen => const Color(0xFF00AA13); // Tokopedia green
  Color get softGreen => const Color(0xFFF1FFF2); // Soft (for card bg)

  void _logout() {
    // Ganti semua route ke halaman login.dart (LoginPage)
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    const double boxHeight = 130; // gedein box input & deck
    const double deckWidth = 160;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // Logo bulat Tokped/Gojek
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: mainGreen.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/logo.png',
                              height: 32,
                              width: 32,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Text(
                          'Welcome, Sobat Ankey!',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    // Logout button
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.red, size: 28),
                      tooltip: "Logout",
                      onPressed: _logout,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Search
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search your flashcard...',
                      icon: Icon(Icons.search, color: Colors.green),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                // Create Section
                Text(
                  'Create Flashcard',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: mainGreen,
                  ),
                ),
                const SizedBox(height: 13),
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 0,
                        color: softGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () async {
                            final result = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ManualInputFlashcardPage(
                                  availableDecks: decks,
                                  userId: widget.userId,
                                ),
                              ),
                            );
                            if (result == true) {
                              fetchDecks();
                              fetchLooseFlashcards();
                            }
                          },
                          child: SizedBox(
                            height: boxHeight,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.edit_rounded, size: 38, color: mainGreen),
                                const SizedBox(height: 10),
                                const Text('Manual Input', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Card(
                        elevation: 0,
                        color: softGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(22),
                          onTap: () async {
                            final result = await Navigator.push<Map<String, dynamic>>(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CameraFlashcardPage(
                                  fromNewDeck: false,
                                  availableDecks: decks,
                                  userId: widget.userId,
                                ),
                              ),
                            );
                            if (result != null) {
                              await fetchLooseFlashcards();
                              await fetchDecks();
                            }
                          },
                          child: SizedBox(
                            height: boxHeight,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt_rounded, size: 38, color: mainGreen),
                                const SizedBox(height: 10),
                                const Text('Camera Scan', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                // Recent Decks Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Files',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: mainGreen),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle_outline_rounded, color: mainGreen, size: 28),
                      tooltip: "Add Deck",
                      onPressed: () async {
                        final result = await Navigator.push<Map<String, dynamic>>(
                          context,
                          MaterialPageRoute(builder: (context) => NewDeckPage(userId: widget.userId)),
                        );
                        if (result != null && result['created'] == true) {
                          await fetchDecks();
                          await fetchLooseFlashcards();
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: boxHeight + 30,
                  child: decks.isEmpty
                      ? Center(
                          child: Text(
                            "No decks yet.",
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: decks.length,
                          itemBuilder: (context, idx) {
                            final deck = decks[idx];
                            return GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReviewPage(
                                      title: deck['title'],
                                      flashcards: (deck['flashcards'] as List).cast<Map<String, dynamic>>(),
                                      duration: 1,
                                    ),
                                  ),
                                );
                                await fetchDecks();
                              },
                              child: Container(
                                width: deckWidth,
                                margin: const EdgeInsets.only(right: 18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(color: mainGreen.withOpacity(0.12)),
                                  borderRadius: BorderRadius.circular(22),
                                  boxShadow: [
                                    BoxShadow(
                                      color: mainGreen.withOpacity(0.08),
                                      blurRadius: 12,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Text(
                                      deck['title'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
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
                // Loose Flashcards Section
                Text(
                  'Loose Flashcards',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: mainGreen),
                ),
                const SizedBox(height: 8),
                looseFlashcards.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: Text(
                            "No loose flashcards.",
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        ),
                      )
                    : ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: looseFlashcards.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, idx) {
                          final card = looseFlashcards[idx];
                          return Card(
                            margin: EdgeInsets.zero,
                            elevation: 0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: mainGreen.withOpacity(0.13)),
                            ),
                            child: ListTile(
                              leading: Container(
                                decoration: BoxDecoration(
                                  color: mainGreen.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.all(7),
                                child: const Icon(Icons.note, color: Colors.green, size: 22),
                              ),
                              title: Text(
                                card['question']?.toString() ?? card['name']?.toString() ?? '',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                card['answer']?.toString() ?? '',
                                style: const TextStyle(fontSize: 15, color: Colors.black54),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LooseFlashcardPlayPage(
                                      flashcards: [card],
                                      title: "Loose Flashcard",
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}