import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/welcome_screen.dart';
import 'screens/chatbot_screen.dart';

Future<void> main() async {
  try {
    await dotenv.load(fileName: ".env");
    print('Successfully loaded .env file');
  } catch (e) {
    print('Error loading .env file: $e');
    dotenv.env.clear();
    dotenv.env.addAll({
      'GROK_API_KEY': 'fallback_key',
      'API_URL': 'https://api.xai.com/grok/v1/chat',
    });
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
    const WelcomeScreen(),
    const ChatbotScreen(),
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
      debugShowCheckedModeBanner: false,
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
              icon: Icon(Icons.home),
              label: 'Welcome',
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
