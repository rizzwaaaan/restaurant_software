import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:restaurant/models/orders.dart';
import 'speech_helper.dart';

class PaymentScreen extends StatefulWidget {
  final String? initialPhoneNumber;
  const PaymentScreen({super.key, this.initialPhoneNumber});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String _paymentStatus = '';
  String _selectedMethod = 'credit_card';
  List<Order> _orders = [];
  double _totalAmount = 0.0;
  bool _isLoading = true;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    SpeechHelper.initializeTts();
    _phoneController.text = widget.initialPhoneNumber ?? '';
    _fetchOrders(_phoneController.text);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isMuted) {
        SpeechHelper.speak(
            'This is the Payment Screen. Review your unpaid orders.');
      }
    });
  }

  @override
  void dispose() {
    SpeechHelper.stop();
    SpeechHelper.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders(String phone) async {
    setState(() => _isLoading = true);
    try {
      final response =
          await http.get(Uri.parse('http://localhost:5000/api/orders/$phone'));
      print('API Response: ${response.body}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _orders = (data['orders'] as List)
              .map((json) => Order.fromJson(json))
              .where((order) => order.status == 'pending')
              .toList();
          _totalAmount = _orders.fold(0, (sum, order) => sum + order.total);
          _isLoading = false;
        });
      } else {
        _handleFetchError(
            'No pending orders found or invalid response: ${response.statusCode}');
      }
    } catch (e) {
      _handleFetchError('Error fetching orders: $e');
    }
  }

  Future<void> _processPayment() async {
    if (_orders.isEmpty) {
      _showErrorSnackBar('No pending orders to pay');
      return;
    }

    String? phoneNumber = await _showPhoneConfirmationDialog();
    if (phoneNumber == null || phoneNumber.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/payments'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'phone': phoneNumber,
          'amount': _totalAmount,
          'method': _selectedMethod,
        }),
      );
      final result = jsonDecode(response.body);
      setState(() => _paymentStatus = result['status'] ?? 'error');

      if (_paymentStatus == 'success') {
        await _fetchOrders(phoneNumber);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _paymentStatus == 'success'
                  ? 'Payment successful!'
                  : 'Payment failed',
              style: GoogleFonts.poppins()),
          backgroundColor:
              _paymentStatus == 'success' ? Colors.green : Colors.redAccent,
        ),
      );
      if (_paymentStatus == 'success') {
        Future.delayed(const Duration(seconds: 2), () {
          setState(() => _paymentStatus = '');
        });
      }
    } catch (e) {
      setState(() => _paymentStatus = 'error');
      _showErrorSnackBar('Error: $e');
    }
  }

  Future<String?> _showPhoneConfirmationDialog() async {
    String phoneNumber = _phoneController.text;
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Enter Phone Number',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, color: Colors.teal.shade700)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone Number',
                labelStyle: GoogleFonts.poppins(color: Colors.teal.shade700),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: Colors.teal.shade700)),
          ),
          ElevatedButton(
            onPressed: _phoneController.text.length >= 10
                ? () => Navigator.pop(context, _phoneController.text)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _phoneController.text.length >= 10
                  ? Colors.teal.shade700
                  : Colors.grey,
            ),
            child: Text('Confirm',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _handleFetchError(String message) {
    setState(() {
      _orders = [];
      _totalAmount = 0.0;
      _isLoading = false;
    });
    _showErrorSnackBar(message);
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
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Card(
                        elevation: 15,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                        child: Padding(
                          padding: const EdgeInsets.all(30),
                          child: _isLoading
                              ? Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.teal.shade700))
                              : Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Payment',
                                      style: GoogleFonts.poppins(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal.shade700,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 20),
                                    TextField(
                                      controller: _phoneController,
                                      decoration: InputDecoration(
                                        labelText: 'Enter Phone Number',
                                        labelStyle: GoogleFonts.poppins(
                                            color: Colors.teal.shade700),
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                      ),
                                      keyboardType: TextInputType.phone,
                                      onChanged: (value) => setState(() {}),
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () =>
                                          _fetchOrders(_phoneController.text),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.teal.shade700,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15),
                                      ),
                                      child: Text(
                                        'Check Unpaid Orders',
                                        style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    if (_orders.isNotEmpty)
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.9),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: _orders.length,
                                          itemBuilder: (context, index) {
                                            final order = _orders[index];
                                            return ExpansionTile(
                                              title: Text('Order #${order.id}',
                                                  style: GoogleFonts.poppins(
                                                      fontWeight:
                                                          FontWeight.w600)),
                                              children: order.items
                                                  .map<Widget>(
                                                      (item) => ListTile(
                                                            title: Text(
                                                                item['name'],
                                                                style: GoogleFonts
                                                                    .poppins()),
                                                            subtitle: Text(
                                                                'Qty: ${item['quantity']}',
                                                                style: GoogleFonts.poppins(
                                                                    color: Colors
                                                                            .grey[
                                                                        600])),
                                                            trailing: Text(
                                                                '\$${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                                                                style: GoogleFonts.poppins(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600)),
                                                          ))
                                                  .toList(),
                                            );
                                          },
                                        ),
                                      ),
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Total:',
                                            style: GoogleFonts.poppins(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                            '\$${_totalAmount.toStringAsFixed(2)}',
                                            style: GoogleFonts.poppins(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.teal.shade700)),
                                      ],
                                    ),
                                    const SizedBox(height: 30),
                                    DropdownButtonFormField<String>(
                                      value: _selectedMethod,
                                      decoration: InputDecoration(
                                        labelText: 'Payment Method',
                                        labelStyle: GoogleFonts.poppins(
                                            color: Colors.teal.shade700),
                                        filled: true,
                                        fillColor:
                                            Colors.white.withOpacity(0.9),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          borderSide: BorderSide.none,
                                        ),
                                      ),
                                      style: GoogleFonts.poppins(
                                          color: Colors.black),
                                      items: const [
                                        DropdownMenuItem(
                                            value: 'credit_card',
                                            child: Text('Credit Card')),
                                        DropdownMenuItem(
                                            value: 'upi',
                                            child: Text('UPI Payment')),
                                      ],
                                      onChanged: (value) => setState(
                                          () => _selectedMethod = value!),
                                    ),
                                    const SizedBox(height: 40),
                                    ElevatedButton(
                                      onPressed: _processPayment,
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 15),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        elevation: 5,
                                        backgroundColor: Colors.teal.shade700,
                                      ),
                                      child: Text(
                                        'Confirm Payment',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    if (_paymentStatus.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 20),
                                        child: Text(
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
                                      ),
                                  ],
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
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
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
            ],
          ),
        ),
      ),
    );
  }
}
