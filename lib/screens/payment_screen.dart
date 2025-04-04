import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:restaurant/models/orders.dart';
import 'speech_helper.dart'; // Import SpeechHelper

class PaymentScreen extends StatefulWidget {
  final String phoneNumber;
  const PaymentScreen({super.key, required this.phoneNumber});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _paymentStatus = '';
  String _selectedMethod = 'credit_card';
  List<Order> _orders = [];
  double _totalAmount = 0.0;
  bool _isLoading = true;
  final TextEditingController _phoneController = TextEditingController();

  Future<void> _fetchOrders(String phone) async {
    try {
      print('Fetching orders for phone: $phone');
      final response =
          await http.get(Uri.parse('http://localhost:5000/api/orders/$phone'));
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Parsed data: $data');
        setState(() {
          _orders = (data['orders'] as List)
              .map((json) => Order.fromJson(json))
              .toList();
          _totalAmount = (data['total_amount'] as num).toDouble();
          _isLoading = false;
          print('Orders fetched: $_orders');
          print('Total amount: $_totalAmount');
        });
      } else {
        setState(() {
          _orders = [];
          _totalAmount = 0.0;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('No pending orders found'),
              backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      print('Error fetching orders: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<void> _processPayment() async {
    if (_orders.isEmpty) return;
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/payments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone': _phoneController.text,
          'amount': _totalAmount,
          'method': _selectedMethod,
        }),
      );

      final result = jsonDecode(response.body);
      setState(() => _paymentStatus = result['status'] ?? 'error');

      if (_paymentStatus == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment successful!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        Future.delayed(
            const Duration(seconds: 2), () => Navigator.pop(context));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed. Please try again.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      setState(() => _paymentStatus = 'error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.phoneNumber;
    _fetchOrders(widget.phoneNumber);
    SpeechHelper.speak(
        'This is the Payment Screen. Review your orders, select a payment method, and confirm your payment.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Payment',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Card(
          elevation: 10,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Order Summary',
                        style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Enter Phone Number',
                          labelStyle: GoogleFonts.poppins(color: Colors.teal),
                          prefixIcon:
                              const Icon(Icons.phone, color: Colors.teal),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        keyboardType: TextInputType.phone,
                        onChanged: (value) {
                          setState(() {
                            _isLoading = true;
                          });
                          _fetchOrders(value);
                        },
                      ),
                      const SizedBox(height: 20),
                      if (_orders.isNotEmpty)
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _orders.length,
                          itemBuilder: (context, index) {
                            final order = _orders[index];
                            return ExpansionTile(
                              title: Text('Order #${order.id}',
                                  style: GoogleFonts.poppins()),
                              children: order.items
                                  .map<Widget>((item) => ListTile(
                                        title: Text(item['name'],
                                            style: GoogleFonts.poppins()),
                                        subtitle: Text(
                                            'Qty: ${item['quantity']}',
                                            style: GoogleFonts.poppins(
                                                color: Colors.grey[600])),
                                        trailing: Text(
                                            '\$${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                                            style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600)),
                                      ))
                                  .toList(),
                            );
                          },
                        ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total:',
                              style: GoogleFonts.poppins(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('\$${_totalAmount.toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal)),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Text(
                        'Select Payment Method',
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.teal),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedMethod,
                        decoration: InputDecoration(
                          labelStyle: GoogleFonts.poppins(color: Colors.teal),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 12),
                        ),
                        style: GoogleFonts.poppins(color: Colors.black),
                        items: const [
                          DropdownMenuItem(
                              value: 'credit_card', child: Text('Credit Card')),
                          DropdownMenuItem(
                              value: 'upi', child: Text('UPI Payment')),
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedMethod = value!),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed:
                            _orders.isEmpty || _paymentStatus == 'success'
                                ? null
                                : _processPayment,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.teal, Colors.tealAccent],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Center(
                            child: Text(
                              'Confirm Payment',
                              style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      if (_paymentStatus.isNotEmpty)
                        Text(
                          _paymentStatus == 'success'
                              ? 'Payment Successful!'
                              : 'Payment Failed',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _paymentStatus == 'success'
                                ? Colors.green
                                : Colors.redAccent,
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }
}
