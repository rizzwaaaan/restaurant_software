import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'package:restaurant/models/orders.dart';
import 'speech_helper.dart';

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
    setState(() => _isLoading = true);
    try {
      final response =
          await http.get(Uri.parse('http://localhost:5000/api/orders/$phone'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _orders = (data['orders'] as List)
              .map((json) => Order.fromJson(json))
              .toList();
          _totalAmount = (data['total_amount'] as num).toDouble();
          _isLoading = false;
        });
      } else {
        _handleFetchError('No pending orders found');
      }
    } catch (e) {
      _handleFetchError('Error: $e');
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
        Future.delayed(
            const Duration(seconds: 2), () => Navigator.pop(context));
      }
    } catch (e) {
      setState(() => _paymentStatus = 'error');
      _showErrorSnackBar('Error: $e');
    }
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

  @override
  void initState() {
    super.initState();
    _phoneController.text = widget.phoneNumber;
    _fetchOrders(widget.phoneNumber);
    SpeechHelper.speak(
        'This is the Payment Screen. Review your orders and confirm payment.');
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
              SingleChildScrollView(
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
                            children: [
                              Text(
                                'Payment',
                                style: GoogleFonts.poppins(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal.shade700,
                                ),
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
                                    borderSide:
                                        BorderSide(color: Colors.teal.shade700),
                                  ),
                                ),
                                keyboardType: TextInputType.phone,
                                onChanged: _fetchOrders,
                              ),
                              const SizedBox(height: 20),
                              if (_orders.isNotEmpty)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(15),
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
                                                fontWeight: FontWeight.w600)),
                                        children: order.items
                                            .map<Widget>((item) => ListTile(
                                                  title: Text(item['name'],
                                                      style: GoogleFonts
                                                          .poppins()),
                                                  subtitle: Text(
                                                      'Qty: ${item['quantity']}',
                                                      style:
                                                          GoogleFonts.poppins(
                                                              color: Colors
                                                                  .grey[600])),
                                                  trailing: Text(
                                                      '\$${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                                                      style:
                                                          GoogleFonts.poppins(
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
                                  Text('\$${_totalAmount.toStringAsFixed(2)}',
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
                                  fillColor: Colors.white.withOpacity(0.9),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                style: GoogleFonts.poppins(color: Colors.black),
                                items: const [
                                  DropdownMenuItem(
                                      value: 'credit_card',
                                      child: Text('Credit Card')),
                                  DropdownMenuItem(
                                      value: 'upi', child: Text('UPI Payment')),
                                ],
                                onChanged: (value) =>
                                    setState(() => _selectedMethod = value!),
                              ),
                              const SizedBox(height: 40),
                              ElevatedButton(
                                onPressed: _orders.isEmpty ||
                                        _paymentStatus == 'success'
                                    ? null
                                    : _processPayment,
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
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
