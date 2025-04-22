import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/welcome_screen.dart';
import 'screens/chatbot_screen.dart';
import 'screens/entertainment_screen.dart';
import 'screens/speech_helper.dart';

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
      _speakForScreen(index);
    });
  }

  void _speakForScreen(int index) {
    SpeechHelper.stop();
    switch (index) {
      case 0:
        SpeechHelper.speak(
            'Welcome to the Smart Restaurant. Explore your options!');
        break;
      case 1:
        SpeechHelper.speak(
            'You are now in the chatbot section. How can I assist you?');
        break;
      default:
        SpeechHelper.speak('Navigating to a new section.');
    }
  }

  @override
  void initState() {
    super.initState();
    _speakForScreen(_selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Restaurant',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
      debugShowCheckedModeBanner: false,
      navigatorObservers: [SpeechNavigatorObserver()],
      home: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
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
      onGenerateRoute: (settings) {
        if (settings.name == '/entertainment') {
          return MaterialPageRoute(builder: (_) => const EntertainmentScreen());
        }
        return null;
      },
    );
  }
}

class SpeechNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    SpeechHelper.stop();
    _speakForRoute(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    SpeechHelper.stop();
    if (previousRoute != null) {
      _speakForRoute(previousRoute);
    }
  }

  void _speakForRoute(Route<dynamic> route) {
    final name = route.settings.name ?? '';
    switch (name) {
      case '/':
      case '/welcome':
        SpeechHelper.speak(
            'Welcome to the Smart Restaurant. Explore your options!');
        break;
      case '/chatbot':
        SpeechHelper.speak(
            'You are now in the chatbot section. How can I assist you?');
        break;
      case '/entertainment':
        SpeechHelper.speak(
            'Welcome to the entertainment section. Enjoy while you wait!');
        break;
    }
  }
}
