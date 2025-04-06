import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'speech_helper.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  Future<void> _sendMessage(String message) async {
    if (message.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': message});
      _isLoading = true;
    });
    _messageController.clear();

    final apiKey = dotenv.env['GROK_API_KEY'];
    final apiUrl = dotenv.env['API_URL'];

    if (apiKey == null || apiUrl == null) {
      _handleError('API configuration is missing. Please contact support.');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: json.encode({
          'message': message,
          'context': 'Smart Restaurant chatbot',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _messages.add({
            'sender': 'bot',
            'text': data['response'] ?? 'Sorry, I didn\'t understand that.'
          });
          _isLoading = false;
        });
        SpeechHelper.speak(
            data['response'] ?? 'Sorry, I didn\'t understand that.');
      } else {
        _handleError('Failed to get response from Grok API');
      }
    } catch (e) {
      _handleError('Error: $e');
    }
  }

  void _handleError(String message) {
    setState(() {
      _messages.add({'sender': 'bot', 'text': message});
      _isLoading = false;
    });
    SpeechHelper.speak(message);
  }

  @override
  void initState() {
    super.initState();
    SpeechHelper.speak(
        'Welcome to the Smart Restaurant Chatbot. Ask me anything about the restaurant or general questions!');
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
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Chatbot',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final isUser = message['sender'] == 'user';
                        return Align(
                          alignment: isUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color:
                                  isUser ? Colors.white : Colors.teal.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              message['text']!,
                              style: GoogleFonts.poppins(
                                color: isUser
                                    ? Colors.teal.shade700
                                    : Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (_isLoading)
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Ask me anything...',
                              hintStyle:
                                  GoogleFonts.poppins(color: Colors.white70),
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.2),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            style: GoogleFonts.poppins(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: Icon(Icons.send, color: Colors.white),
                          onPressed: () =>
                              _sendMessage(_messageController.text),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                bottom: 20,
                left: 20,
                child: Navigator.canPop(context)
                    ? IconButton(
                        icon: Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      )
                    : SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
