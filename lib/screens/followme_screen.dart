import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'speech_helper.dart';

class FollowMeScreen extends StatefulWidget {
  const FollowMeScreen({super.key});

  @override
  _FollowMeScreenState createState() => _FollowMeScreenState();
}

class _FollowMeScreenState extends State<FollowMeScreen> {
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    SpeechHelper.initializeTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isMuted) {
        SpeechHelper.speak(
            'This is the Follow Me screen. The robot is preparing to guide you to your table.');
      }
    });
  }

  @override
  void dispose() {
    SpeechHelper.stop();
    SpeechHelper.dispose();
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
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.directions_walk,
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Follow the Robot',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
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
                    const SizedBox(height: 15),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        'Preparing to guide you to your table',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.teal.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Robot navigation in progress',
                                style: GoogleFonts.poppins()),
                            backgroundColor: Colors.teal.shade700,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                        backgroundColor: Colors.white,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow, color: Colors.teal.shade700),
                          const SizedBox(width: 10),
                          Text(
                            'Start Navigation',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
}
