import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/welcome_screen.dart';
import 'screens/menu_screen.dart';
import 'screens/chatbot_screen.dart';

Future<void> main() async {
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Error loading .env file: $e');
    // Fallback: Set default values or exit gracefully
    dotenv.env['GROK_API_KEY'] =
        'fallback_key'; // Replace with a safe default or handle differently
    dotenv.env['API_URL'] = 'https://api.xai.com/grok/v1/chat';
  }
  runApp(const RestaurantApp());
}

class RestaurantApp extends StatefulWidget {
  const RestaurantApp({super.key});

  @override
  _RestaurantAppState createState() => _RestaurantAppState();
}

class _RestaurantAppState extends State<RestaurantApp> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = [
    WelcomeScreen(),
    MenuScreen(),
    ChatbotScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Restaurant',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.teal.shade700,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.food_bank),
              label: 'Welcome',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu),
              label: 'Check Menu',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chatbot',
            ),
          ],
        ),
      ),
    );
  }
}
