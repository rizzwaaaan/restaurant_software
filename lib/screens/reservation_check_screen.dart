import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'followme_screen.dart';
import 'reservation_screen.dart';
import 'speech_helper.dart';

class ReservationCheckScreen extends StatefulWidget {
  const ReservationCheckScreen({super.key});

  @override
  _ReservationCheckScreenState createState() => _ReservationCheckScreenState();
}

class _ReservationCheckScreenState extends State<ReservationCheckScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isMuted = false;

  Future<void> _checkReservation() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final response = await http.get(
          Uri.parse(
              'http://localhost:5000/api/check-reservation?phone=${_phoneController.text}'),
        );
        print('API Response: ${response.body}');
        setState(() => _isLoading = false);

        if (response.statusCode == 200) {
          final reservation = json.decode(response.body);
          bool isPresent = reservation['present'] == 'yes';
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => isPresent
                  ? const FollowMeScreen()
                  : ReservationScreen(
                      initialPhoneNumber: _phoneController.text),
            ),
          );
        } else {
          _showErrorSnackBar(
              'Error checking reservation: ${response.statusCode} - ${response.body}');
        }
      } catch (e) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Network error: $e');
      }
    }
  }

  void _navigateToReservation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ReservationScreen(initialPhoneNumber: _phoneController.text),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.redAccent,
      ),
    );
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
  void initState() {
    super.initState();
    SpeechHelper.initializeTts();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isMuted) {
        SpeechHelper.speak(
            'This is the Reservation Check Screen. Enter your phone number to check or make a reservation.');
      }
    });
  }

  @override
  void dispose() {
    SpeechHelper.stop();
    SpeechHelper.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.teal.shade600, Colors.teal.shade200],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Card(
                        elevation: 15,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                        color: Colors.white.withOpacity(0.9),
                        child: Padding(
                          padding: const EdgeInsets.all(30),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Check Reservation',
                                  style: GoogleFonts.poppins(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal.shade700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 30),
                                TextFormField(
                                  controller: _phoneController,
                                  decoration: InputDecoration(
                                    labelText: 'Phone Number',
                                    labelStyle: GoogleFonts.poppins(
                                        color: Colors.teal.shade700),
                                    prefixIcon: Icon(Icons.phone,
                                        color: Colors.teal.shade700),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.9),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide(
                                          color: Colors.teal.shade700),
                                    ),
                                  ),
                                  style: GoogleFonts.poppins(),
                                  keyboardType: TextInputType.phone,
                                  validator: (value) =>
                                      value!.isEmpty || value.length < 10
                                          ? 'Invalid phone number'
                                          : null,
                                ),
                                const SizedBox(height: 40),
                                _isLoading
                                    ? CircularProgressIndicator(
                                        color: Colors.teal.shade700)
                                    : Column(
                                        children: [
                                          ElevatedButton(
                                            onPressed: _checkReservation,
                                            style: ElevatedButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 15),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              elevation: 5,
                                              backgroundColor:
                                                  Colors.teal.shade700,
                                            ),
                                            child: Text(
                                              'Check Reservation',
                                              style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          TextButton(
                                            onPressed: _navigateToReservation,
                                            child: Text(
                                              'Make New Reservation',
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                color: Colors.teal.shade700,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                const SizedBox(height: 20),
                                Text(
                                  'Smart Restaurant © 2025',
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
