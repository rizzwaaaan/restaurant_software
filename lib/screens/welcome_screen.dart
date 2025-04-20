import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'reservation_check_screen.dart';
import 'speech_helper.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isMuted = false;

  final List<Map<String, String>> _foodItems = [
    {'image': 'assets/food1.jpg', 'name': '', 'description': ''},
    {'image': 'assets/food2.jpg', 'name': '', 'description': ''},
    {'image': 'assets/food3.jpg', 'name': '', 'description': ''},
  ];

  @override
  void initState() {
    super.initState();
    SpeechHelper.initializeTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isMuted) {
        SpeechHelper.speak(
            'Welcome to the Smart Restaurant. Tap anywhere to proceed to reservation check.');
      }
    });
  }

  @override
  void dispose() {
    SpeechHelper.stop();
    SpeechHelper.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      if (_isMuted) {
        SpeechHelper.stop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade700, Colors.teal.shade200],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ReservationCheckScreen()),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'Smart Restaurant',
                        style: GoogleFonts.poppins(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(2, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _foodItems.length,
                        onPageChanged: (page) =>
                            setState(() => _currentPage = page),
                        itemBuilder: (context, index) {
                          final item = _foodItems[index];
                          return Container(
                            margin: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                              image: DecorationImage(
                                image: AssetImage(item['image']!),
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                  Colors.black.withOpacity(0.3),
                                  BlendMode.dstATop,
                                ),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name']!,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    item['description']!,
                                    style: GoogleFonts.poppins(
                                      color: Colors.white70,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _buildPageIndicator(),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Tap to Continue',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.teal.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: 20,
                child: Row(
                  children: [
                    Navigator.canPop(context)
                        ? IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          )
                        : SizedBox.shrink(),
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
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPageIndicator() {
    return _foodItems.map((item) {
      int index = _foodItems.indexOf(item);
      return AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: _currentPage == index ? 20 : 10,
        height: 10,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: _currentPage == index ? Colors.white : Colors.white54,
        ),
      );
    }).toList();
  }
}
