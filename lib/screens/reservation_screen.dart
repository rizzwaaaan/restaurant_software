import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
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
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  int _people = 2;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController(text: widget.initialPhoneNumber);
    SpeechHelper.speak(
        'This is the Reservation Screen. Enter your details to book a table.');
  }

  Future<void> _submitReservation() async {
    if (_formKey.currentState!.validate()) {
      try {
        final response = await http.post(
          Uri.parse('http://localhost:5000/api/reservations'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'name': _nameController.text,
            'people': _people,
            'phone': _phoneController.text,
          }),
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => MenuScreen(phoneNumber: _phoneController.text),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Reservation successful!', style: GoogleFonts.poppins()),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          _showErrorSnackBar('Reservation failed');
        }
      } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade600, Colors.teal.shade100],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Card(
                  elevation: 15,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25)),
                  child: Padding(
                    padding: const EdgeInsets.all(30),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Book Your Table',
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade700,
                            ),
                          ),
                          const SizedBox(height: 30),
                          _buildTextField(
                              _nameController, 'Name', Icons.person),
                          const SizedBox(height: 20),
                          _buildTextField(
                              _phoneController, 'Phone Number', Icons.phone,
                              keyboardType: TextInputType.phone),
                          const SizedBox(height: 20),
                          DropdownButtonFormField<int>(
                            value: _people,
                            decoration: _inputDecoration(
                                'Number of Guests', Icons.people),
                            style: GoogleFonts.poppins(color: Colors.black),
                            items: List.generate(
                              10,
                              (i) => DropdownMenuItem(
                                value: i + 1,
                                child: Text(
                                    '${i + 1} ${i == 0 ? 'person' : 'people'}'),
                              ),
                            ),
                            onChanged: (value) =>
                                setState(() => _people = value!),
                          ),
                          const SizedBox(height: 40),
                          ElevatedButton(
                            onPressed: _submitReservation,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 40),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              elevation: 5,
                              backgroundColor: Colors.teal.shade700,
                            ),
                            child: Text(
                              'Confirm Reservation',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      decoration: _inputDecoration(label, icon),
      style: GoogleFonts.poppins(),
      keyboardType: keyboardType,
      validator: (value) =>
          value!.isEmpty || (label == 'Phone Number' && value.length < 10)
              ? 'Invalid'
              : null,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(color: Colors.teal.shade700),
      prefixIcon: Icon(icon, color: Colors.teal.shade700),
      filled: true,
      fillColor: Colors.white.withOpacity(0.9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.teal.shade700),
      ),
    );
  }
}
