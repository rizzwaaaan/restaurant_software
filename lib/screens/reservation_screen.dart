import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:restaurant/models/reservation.dart';
import 'menu_screen.dart';
import 'speech_helper.dart';

class ReservationScreen extends StatefulWidget {
  final String? initialPhoneNumber;
  const ReservationScreen({super.key, this.initialPhoneNumber});

  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _peopleController = TextEditingController();
  bool _isLoading = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    SpeechHelper.initializeTts();
    _phoneController.text = widget.initialPhoneNumber ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isMuted) {
        SpeechHelper.speak(
            'This is the Reservation Screen. Enter your details to make a reservation.');
      }
    });
  }

  @override
  void dispose() {
    SpeechHelper.stop();
    SpeechHelper.dispose();
    super.dispose();
  }

  Future<void> _submitReservation() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final reservation = Reservation(
        name: _nameController.text,
        people: int.parse(_peopleController.text),
        phone: _phoneController.text,
      );
      try {
        final response = await http.post(
          Uri.parse('http://localhost:5000/api/reservations'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(reservation.toJson()),
        );
        setState(() => _isLoading = false);

        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reservation created successfully!',
                  style: GoogleFonts.poppins()),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => MenuScreen(phoneNumber: _phoneController.text),
            ),
          );
        } else {
          _showErrorSnackBar('Failed to create reservation: ${response.body}');
        }
      } catch (e) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Error: $e');
      }
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Make Reservation',
                                  style: GoogleFonts.poppins(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal.shade700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 30),
                                TextFormField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    labelText: 'Full Name',
                                    labelStyle: GoogleFonts.poppins(
                                        color: Colors.teal.shade700),
                                    prefixIcon: Icon(Icons.person,
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
                                  validator: (value) => value!.isEmpty
                                      ? 'Please enter your name'
                                      : null,
                                ),
                                const SizedBox(height: 20),
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
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _peopleController,
                                  decoration: InputDecoration(
                                    labelText: 'Number of People',
                                    labelStyle: GoogleFonts.poppins(
                                        color: Colors.teal.shade700),
                                    prefixIcon: Icon(Icons.group,
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
                                  keyboardType: TextInputType.number,
                                  validator: (value) =>
                                      value!.isEmpty || int.parse(value) <= 0
                                          ? 'Please enter a valid number'
                                          : null,
                                ),
                                const SizedBox(height: 40),
                                _isLoading
                                    ? CircularProgressIndicator(
                                        color: Colors.teal.shade700)
                                    : ElevatedButton(
                                        onPressed: _submitReservation,
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 15),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          elevation: 5,
                                          backgroundColor: Colors.teal.shade700,
                                        ),
                                        child: Text(
                                          'Make Reservation',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                const SizedBox(height: 20),
                                Text(
                                  'Smart Restaurant © 2025',
                                  style: GoogleFonts.poppins(
                                      color: Colors.grey[600]),
                                  textAlign: TextAlign.center,
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
