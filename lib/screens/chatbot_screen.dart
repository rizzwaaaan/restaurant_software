import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'speech_helper.dart';
import 'dart:developer' as developer;

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  String _response = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadEnv();
    SpeechHelper.speak(
        'This is the Chatbot Screen. Ask me anything about the restaurant!');
  }

  Future<void> _loadEnv() async {
    await dotenv.load(fileName: ".env");
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) {
      _showErrorSnackBar('Please enter a message');
      return;
    }

    setState(() {
      _isLoading = true;
      _response = 'Loading...';
    });

    try {
      String? apiUrl = dotenv.env['API_URL'];
      String? apiKey = dotenv.env['OPENAI_API_KEY'];

      if (apiUrl == null || apiKey == null) {
        throw Exception('API_URL or OPENAI_API_KEY not found in .env');
      }

      developer.log('API URL: $apiUrl', name: 'Chatbot');
      final response = await http.post(
        Uri.parse('$apiUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'user', 'content': _messageController.text},
          ],
          'max_tokens': 150,
          'temperature': 0.7,
        }),
      );

      developer.log('Response Status: ${response.statusCode}', name: 'Chatbot');
      developer.log('Response Body: ${response.body}', name: 'Chatbot');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null &&
            data['choices'] != null &&
            data['choices'] is List &&
            data['choices'].isNotEmpty) {
          setState(() {
            _response =
                data['choices'][0]['message']['content'] ?? 'No response';
            _isLoading = false;
          });
        } else {
          throw Exception('Unexpected response format: $data');
        }
      } else {
        final errorData = json.decode(response.body);
        String errorMessage = 'Unknown error';
        if (errorData != null &&
            errorData['error'] != null &&
            errorData['error'] is Map) {
          errorMessage =
              (errorData['error'] as Map<String, dynamic>)['message'] ??
                  'Unknown error';
        }
        setState(() {
          _response = 'Error: ${response.statusCode} - $errorMessage';
          _isLoading = false;
        });
        _showErrorSnackBar('API Error: ${response.statusCode} - $errorMessage');
      }
    } catch (e) {
      setState(() {
        _response = 'Error: $e';
        _isLoading = false;
      });
      _showErrorSnackBar('Error: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: Colors.redAccent,
      ),
    );
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
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text(
                  'Chatbot',
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    labelText: 'Ask me anything...',
                    labelStyle:
                        GoogleFonts.poppins(color: Colors.teal.shade700),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15)),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                  ),
                  style: GoogleFonts.poppins(),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _sendMessage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    'Send',
                    style: GoogleFonts.poppins(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator(color: Colors.teal.shade700)
                    : Expanded(
                        child: SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              _response,
                              style: GoogleFonts.poppins(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
