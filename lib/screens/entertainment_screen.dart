import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flame/game.dart';
import 'package:flame/widgets.dart';
import 'speech_helper.dart';
import 'dart:async';

// Simple Flame game for tapping bugs
class BugTapGame extends Game {
  int score = 0;
  late Timer _timer;
  bool _isRunning = true;

  @override
  Future<void> onLoad() async {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isRunning) score += 1; // Score increases every second if active
    });
  }

  void tap() {
    if (_isRunning) score += 10; // Add 10 points per tap
  }

  @override
  void render(Canvas canvas) {
    // Basic rendering (placeholder, can be enhanced with sprites)
  }

  @override
  void update(double dt) {
    // Update game state (placeholder)
  }

  void stop() {
    _isRunning = false;
    _timer.cancel();
  }
}

class EntertainmentScreen extends StatefulWidget {
  const EntertainmentScreen({super.key});

  @override
  State<EntertainmentScreen> createState() => _EntertainmentScreenState();
}

class _EntertainmentScreenState extends State<EntertainmentScreen> {
  bool _isMuted = false;
  final BugTapGame _bugGame = BugTapGame();
  List<List<bool>> _memoryGrid = List.generate(4, (_) => List.filled(4, false));
  int _pairsFound = 0;
  List<int> _shuffledIndices = [];
  int _selectedIndex = -1;

  @override
  void initState() {
    super.initState();
    SpeechHelper.speak(
        'Welcome to the entertainment section. Enjoy while you wait!');
    _initializeMemoryGame();
  }

  void _initializeMemoryGame() {
    _shuffledIndices = List.generate(8, (i) => i)
      ..addAll(List.generate(8, (i) => i))
      ..shuffle();
    _pairsFound = 0;
    _selectedIndex = -1;
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      if (_isMuted) {
        SpeechHelper.stop();
      } else {
        SpeechHelper.speak('Entertainment section unmuted.');
      }
    });
  }

  void _tapBug() {
    setState(() {
      _bugGame.tap();
    });
    SpeechHelper.speak('Nice tap! Score is ${_bugGame.score}.');
  }

  void _tapMemoryCard(int index) {
    if (_selectedIndex == -1) {
      setState(() {
        _selectedIndex = index;
        _memoryGrid[index ~/ 4][index % 4] = true;
      });
    } else if (_selectedIndex != index &&
        _shuffledIndices[_selectedIndex] == _shuffledIndices[index]) {
      setState(() {
        _memoryGrid[index ~/ 4][index % 4] = true;
        _pairsFound++;
        _selectedIndex = -1;
      });
      SpeechHelper.speak('Match found! Pairs left: ${4 - _pairsFound}.');
    } else {
      setState(() {
        _memoryGrid[index ~/ 4][index % 4] = true;
      });
      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _memoryGrid[_selectedIndex ~/ 4][_selectedIndex % 4] = false;
          _memoryGrid[index ~/ 4][index % 4] = false;
          _selectedIndex = -1;
        });
        SpeechHelper.speak('No match. Try again!');
      });
    }
  }

  @override
  void dispose() {
    SpeechHelper.stop();
    SpeechHelper.dispose();
    _bugGame.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.tealAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Entertainment',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isMuted ? Icons.volume_off : Icons.volume_up,
                        color: Colors.white,
                      ),
                      onPressed: _toggleMute,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Card(
                        color: Colors.white.withOpacity(0.9),
                        margin: const EdgeInsets.all(16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Bug Tap Game',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal.shade700,
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 200,
                                child: GestureDetector(
                                  onTap: _tapBug,
                                  child: GameWidget(game: _bugGame),
                                ),
                              ),
                              Text(
                                'Score: ${_bugGame.score}',
                                style: GoogleFonts.poppins(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        color: Colors.white.withOpacity(0.9),
                        margin: const EdgeInsets.all(16.0),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Memory Match Game',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal.shade700,
                                ),
                              ),
                              const SizedBox(height: 10),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 4,
                                  childAspectRatio: 1,
                                  crossAxisSpacing: 4,
                                  mainAxisSpacing: 4,
                                ),
                                itemCount: 16,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () => _tapMemoryCard(index),
                                    child: Card(
                                      color: _memoryGrid[index ~/ 4][index % 4]
                                          ? Colors.teal
                                          : Colors.grey,
                                      child: Center(
                                        child: _memoryGrid[index ~/ 4]
                                                [index % 4]
                                            ? Text(
                                                '${_shuffledIndices[index] + 1}',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                ),
                                              )
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              Text(
                                'Pairs Found: $_pairsFound/4',
                                style: GoogleFonts.poppins(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text('Back to Home', style: GoogleFonts.poppins()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
