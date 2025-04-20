import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'speech_helper.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isMuted = false;
  bool _isLoading = false;
  String _currentStep = 'initial'; // Tracks conversation state
  Map<String, String> _reservationDetails = {
    'name': '',
    'phone': '',
    'people': ''
  };
  Map<String, String> _menuFilter = {'category': '', 'course': ''};

  @override
  void initState() {
    super.initState();
    SpeechHelper.initializeTts();
    _addBotMessage(
      'Welcome to Smart Restaurant! Please choose an option:\n1. Check Reservation\n2. Make Reservation\n3. Check Menu',
      'Welcome to Smart Restaurant. Choose to check your reservation, make a reservation, or view the menu.',
    );
  }

  @override
  void dispose() {
    SpeechHelper.stop();
    SpeechHelper.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _addBotMessage(String displayText, String speakText) {
    setState(() {
      _messages.insert(0, {'sender': 'bot', 'text': displayText});
    });
    if (!_isMuted) {
      SpeechHelper.speak(speakText);
    }
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.insert(0, {'sender': 'user', 'text': text});
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      if (_isMuted) {
        SpeechHelper.stop();
      }
    });
  }

  void _handleUserInput(String input) async {
    _addUserMessage(input);
    setState(() => _isLoading = true);

    if (_currentStep == 'initial') {
      await _handleInitialInput(input);
    } else if (_currentStep == 'check_reservation_phone') {
      await _handleCheckReservationPhone(input);
    } else if (_currentStep == 'name') {
      _handleNameInput(input);
    } else if (_currentStep == 'phone') {
      _handlePhoneInput(input);
    } else if (_currentStep == 'people') {
      _handlePeopleInput(input);
    } else if (_currentStep == 'confirm') {
      await _handleConfirmation(input);
    } else if (_currentStep == 'edit') {
      _handleEditInput(input);
    } else if (_currentStep == 'menu_category') {
      _handleMenuCategory(input);
    } else if (_currentStep == 'menu_course') {
      await _handleMenuCourse(input);
    }

    setState(() => _isLoading = false);
    _messageController.clear();
  }

  Future<void> _handleInitialInput(String input) async {
    final choice = input.trim().toLowerCase();
    if (choice == '1' || choice.contains('check reservation')) {
      _currentStep = 'check_reservation_phone';
      _addBotMessage(
        'Please enter your phone number to check your reservation.',
        'Please tell me your phone number.',
      );
    } else if (choice == '2' || choice.contains('make reservation')) {
      _currentStep = 'name';
      _reservationDetails = {'name': '', 'phone': '', 'people': ''};
      _addBotMessage(
        'Please enter your full name for the reservation.',
        'Please tell me your full name.',
      );
    } else if (choice == '3' || choice.contains('check menu')) {
      _currentStep = 'menu_category';
      _menuFilter = {'category': '', 'course': ''};
      _addBotMessage(
        'Would you like Vegetarian or Non-Vegetarian items?\n1. Vegetarian\n2. Non-Vegetarian\n3. Both',
        'Do you want vegetarian, non-vegetarian, or both?',
      );
    } else {
      _addBotMessage(
        'Invalid option. Please choose:\n1. Check Reservation\n2. Make Reservation\n3. Check Menu',
        'Sorry, I didn’t understand. Please choose option 1, 2, or 3.',
      );
    }
  }

  Future<void> _handleCheckReservationPhone(String input) async {
    if (input.trim().length < 10 || !RegExp(r'^\d+$').hasMatch(input.trim())) {
      _addBotMessage(
        'Invalid phone number. Please enter a valid 10-digit phone number.',
        'Please provide a valid phone number.',
      );
    } else {
      try {
        final response = await http.get(
          Uri.parse(
              'http://localhost:5000/api/check-reservation?phone=${input.trim()}'),
        );
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          _addBotMessage(
            'Reservation found:\nName: ${data['name']}\nPhone: ${data['phone']}\nPeople: ${data['people']}\nStatus: ${data['status']}\n\nChoose an option:\n1. Check Reservation\n2. Make Reservation\n3. Check Menu',
            'Reservation found for ${data['name']} with ${data['people']} people. What next?',
          );
        } else {
          _addBotMessage(
            'No reservation found for this phone number.\n\nChoose an option:\n1. Check Reservation\n2. Make Reservation\n3. Check Menu',
            'No reservation found. What would you like to do?',
          );
        }
      } catch (e) {
        _addBotMessage(
          'Error checking reservation: $e\n\nChoose an option:\n1. Check Reservation\n2. Make Reservation\n3. Check Menu',
          'An error occurred. Please try again.',
        );
      }
      _currentStep = 'initial';
    }
  }

  void _handleNameInput(String input) {
    if (input.trim().isEmpty) {
      _addBotMessage(
        'Name cannot be empty. Please enter your full name.',
        'Please provide a valid name.',
      );
    } else {
      _reservationDetails['name'] = input.trim();
      _currentStep = 'phone';
      _addBotMessage(
        'Please enter your phone number (e.g., 1234567890).',
        'Now, please tell me your phone number.',
      );
    }
  }

  void _handlePhoneInput(String input) {
    if (input.trim().length < 10 || !RegExp(r'^\d+$').hasMatch(input.trim())) {
      _addBotMessage(
        'Invalid phone number. Please enter a valid 10-digit phone number.',
        'Please provide a valid phone number.',
      );
    } else {
      _reservationDetails['phone'] = input.trim();
      _currentStep = 'people';
      _addBotMessage(
        'Please enter the number of people for the reservation.',
        'How many people will be dining?',
      );
    }
  }

  void _handlePeopleInput(String input) {
    if (!RegExp(r'^\d+$').hasMatch(input.trim()) ||
        int.parse(input.trim()) <= 0) {
      _addBotMessage(
        'Invalid number. Please enter a valid number of people.',
        'Please provide a valid number of people.',
      );
    } else {
      _reservationDetails['people'] = input.trim();
      _currentStep = 'confirm';
      _addBotMessage(
        'Please review your reservation details:\nName: ${_reservationDetails['name']}\nPhone: ${_reservationDetails['phone']}\nPeople: ${_reservationDetails['people']}\n\nType "confirm" to proceed, "edit" to change details, or "cancel" to start over.',
        'Please review: Name ${_reservationDetails['name']}, Phone ${_reservationDetails['phone']}, for ${_reservationDetails['people']} people. Say confirm, edit, or cancel.',
      );
    }
  }

  Future<void> _handleConfirmation(String input) async {
    final choice = input.trim().toLowerCase();
    if (choice == 'confirm') {
      try {
        final response = await http.post(
          Uri.parse('http://localhost:5000/api/reservations'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'name': _reservationDetails['name'],
            'phone': _reservationDetails['phone'],
            'people': int.parse(_reservationDetails['people']!),
          }),
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          _addBotMessage(
            'Reservation confirmed for ${_reservationDetails['name']} for ${_reservationDetails['people']} people.\n\nChoose an option:\n1. Check Reservation\n2. Make Reservation\n3. Check Menu',
            'Reservation confirmed. What would you like to do next?',
          );
          _currentStep = 'initial';
        } else {
          _addBotMessage(
            'Failed to create reservation. Please try again.\n\nChoose an option:\n1. Check Reservation\n2. Make Reservation\n3. Check Menu',
            'Sorry, there was an error. Please try again.',
          );
          _currentStep = 'initial';
        }
      } catch (e) {
        _addBotMessage(
          'Error: $e\n\nChoose an option:\n1. Check Reservation\n2. Make Reservation\n3. Check Menu',
          'An error occurred. Please try again.',
        );
        _currentStep = 'initial';
      }
    } else if (choice == 'edit') {
      _currentStep = 'edit';
      _addBotMessage(
        'Which detail would you like to edit?\n1. Name\n2. Phone\n3. People',
        'Which detail do you want to edit? Name, phone, or people?',
      );
    } else if (choice == 'cancel') {
      _currentStep = 'initial';
      _addBotMessage(
        'Reservation cancelled.\n\nChoose an option:\n1. Check Reservation\n2. Make Reservation\n3. Check Menu',
        'Reservation cancelled. What would you like to do?',
      );
    } else {
      _addBotMessage(
        'Invalid option. Please type "confirm", "edit", or "cancel".',
        'Please say confirm, edit, or cancel.',
      );
    }
  }

  void _handleEditInput(String input) {
    final choice = input.trim().toLowerCase();
    if (choice == '1' || choice.contains('name')) {
      _currentStep = 'name';
      _addBotMessage(
        'Please enter the new full name.',
        'Tell me the new name.',
      );
    } else if (choice == '2' || choice.contains('phone')) {
      _currentStep = 'phone';
      _addBotMessage(
        'Please enter the new phone number.',
        'Tell me the new phone number.',
      );
    } else if (choice == '3' || choice.contains('people')) {
      _currentStep = 'people';
      _addBotMessage(
        'Please enter the new number of people.',
        'How many people now?',
      );
    } else {
      _addBotMessage(
        'Invalid option. Please choose:\n1. Name\n2. Phone\n3. People',
        'Please choose name, phone, or people to edit.',
      );
    }
  }

  void _handleMenuCategory(String input) {
    final choice = input.trim().toLowerCase();
    if (choice == '1' || choice.contains('vegetarian') || choice == 'veg') {
      _menuFilter['category'] = 'veg';
      _currentStep = 'menu_course';
      _addBotMessage(
        'Which course would you like?\n1. All\n2. Appetizers\n3. Main\n4. Desserts',
        'Which course? All, appetizers, main, or desserts?',
      );
    } else if (choice == '2' ||
        choice.contains('non-vegetarian') ||
        choice == 'non-veg') {
      _menuFilter['category'] = 'non-veg';
      _currentStep = 'menu_course';
      _addBotMessage(
        'Which course would you like?\n1. All\n2. Appetizers\n3. Main\n4. Desserts',
        'Which course? All, appetizers, main, or desserts?',
      );
    } else if (choice == '3' || choice.contains('both')) {
      _menuFilter['category'] = '';
      _currentStep = 'menu_course';
      _addBotMessage(
        'Which course would you like?\n1. All\n2. Appetizers\n3. Main\n4. Desserts',
        'Which course? All, appetizers, main, or desserts?',
      );
    } else {
      _addBotMessage(
        'Invalid option. Please choose:\n1. Vegetarian\n2. Non-Vegetarian\n3. Both',
        'Please choose vegetarian, non-vegetarian, or both.',
      );
    }
  }

  Future<void> _handleMenuCourse(String input) async {
    final choice = input.trim().toLowerCase();
    String course;
    if (choice == '1' || choice.contains('all')) {
      course = 'all';
    } else if (choice == '2' || choice.contains('appetizer')) {
      course = 'appetizer';
    } else if (choice == '3' || choice.contains('main')) {
      course = 'main';
    } else if (choice == '4' || choice.contains('dessert')) {
      course = 'dessert';
    } else {
      _addBotMessage(
        'Invalid option. Please choose:\n1. All\n2. Appetizers\n3. Main\n4. Desserts',
        'Please choose all, appetizers, main, or desserts.',
      );
      return;
    }

    _menuFilter['course'] = course;
    try {
      final uri = Uri.parse(
        'http://localhost:5000/api/menu${(_menuFilter['category'] != null && _menuFilter['category']!.isNotEmpty) ? '?category=${_menuFilter['category']}' : ''}${course != 'all' ? '${(_menuFilter['category'] != null && _menuFilter['category']!.isNotEmpty) ? '&' : '?'}course=$course' : ''}',
      );
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final menuItems = json.decode(response.body);
        if (menuItems.isEmpty) {
          _addBotMessage(
            'No menu items found for this selection.\n\nChoose an option:\n1. Check Reservation\n2. Make Reservation\n3. Check Menu',
            'No items found. What would you like to do next?',
          );
        } else {
          final menuText = menuItems
              .map((item) =>
                  '${item['name']} - \$${item['price'].toStringAsFixed(2)}')
              .join('\n');
          _addBotMessage(
            'Menu items:\n$menuText\n\nChoose an option:\n1. Check Reservation\n2. Make Reservation\n3. Check Menu',
            'Here are the menu items. What would you like to do next?',
          );
        }
      } else {
        _addBotMessage(
          'Error fetching menu.\n\nChoose an option:\n1. Check Reservation\n2. Make Reservation\n3. Check Menu',
          'Sorry, I couldn’t fetch the menu. Please try again.',
        );
      }
    } catch (e) {
      _addBotMessage(
        'Error: $e\n\nChoose an option:\n1. Check Reservation\n2. Make Reservation\n3. Check Menu',
        'An error occurred. Please try again.',
      );
    }
    _currentStep = 'initial';
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
                      'Restaurant Assistant',
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
                child: ListView.builder(
                  reverse: true, // New messages at bottom, older at top
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isBot = message['sender'] == 'bot';
                    return Align(
                      alignment:
                          isBot ? Alignment.centerLeft : Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: isBot
                              ? Colors.white.withOpacity(0.9)
                              : Colors.teal.shade700,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          message['text']!,
                          style: GoogleFonts.poppins(
                            color: isBot ? Colors.teal.shade700 : Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_isLoading) const CircularProgressIndicator(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Type your response...',
                          hintStyle: GoogleFonts.poppins(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: GoogleFonts.poppins(color: Colors.white),
                        onSubmitted: (value) {
                          if (value.isNotEmpty) {
                            _handleUserInput(value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        if (_messageController.text.isNotEmpty) {
                          _handleUserInput(_messageController.text);
                        }
                      },
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
