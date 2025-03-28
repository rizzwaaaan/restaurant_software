import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReservationScreen extends StatefulWidget {
  const ReservationScreen({super.key});

  @override
  _ReservationScreenState createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  int _people = 2;

  Future<void> _submitReservation() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/reservations'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': _nameController.text,
          'people': _people,
          'phone': _phoneController.text,
        }),
      );

      if (response.statusCode == 201) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reservation successful!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Table Reservation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator:
                    (value) => value!.length < 10 ? 'Invalid number' : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                value: _people,
                decoration: const InputDecoration(
                  labelText: 'Number of Guests',
                  prefixIcon: Icon(Icons.people),
                ),
                items: List.generate(
                  10,
                  (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text('${i + 1} ${i == 0 ? 'person' : 'people'}'),
                  ),
                ),
                onChanged: (value) => setState(() => _people = value!),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitReservation,
                child: const Text('Confirm Reservation'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
