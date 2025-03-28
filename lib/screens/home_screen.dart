import 'package:flutter/material.dart';
import 'reservation_screen.dart';
import 'menu_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Restaurant System')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionButton(
                context, 'Make Reservation', const ReservationScreen()),
            const SizedBox(height: 20),
            _buildActionButton(context, 'Start Ordering', const MenuScreen()),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String text, Widget screen) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(200, 50),
      ),
      onPressed: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
      child: Text(text),
    );
  }
}
