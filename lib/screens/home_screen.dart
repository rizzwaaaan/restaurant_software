import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'reservation_screen.dart';
import 'menu_screen.dart';
import 'reservation_check_screen.dart';
import 'speech_helper.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SpeechHelper.speak(
          'Welcome to the Home Screen of the Smart Restaurant System. Choose to check your reservation, view the menu, or make a new reservation.');
    });

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
                    Text(
                      'Smart Restaurant',
                      style: GoogleFonts.poppins(
                        fontSize: 40,
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
                    Text(
                      'Your dining experience awaits',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 60),
                    _buildActionButton(
                      context,
                      'Check Reservation',
                      const ReservationCheckScreen(),
                      Icons.check,
                    ),
                    const SizedBox(height: 30),
                    _buildActionButton(
                      context,
                      'Check Menu',
                      const MenuScreen(),
                      Icons.restaurant_menu,
                    ),
                    const SizedBox(height: 30),
                    _buildActionButton(
                      context,
                      'Make Reservation',
                      const ReservationScreen(),
                      Icons.book,
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 20,
                left: 20,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
      BuildContext context, String text, Widget screen, IconData icon) {
    return ElevatedButton(
      onPressed: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 10,
        backgroundColor: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.teal.shade700, size: 30),
          const SizedBox(width: 15),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
