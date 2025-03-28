import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final double totalAmount;

  const PaymentScreen({
    super.key,
    required this.cartItems,
    required this.totalAmount,
  });

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _paymentStatus = '';
  String _selectedMethod = 'credit_card';

  Future<void> _processPayment() async {
    final response = await http.post(
      Uri.parse('http://localhost:5000/api/payments'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'order_id': DateTime.now().millisecondsSinceEpoch,
        'amount': widget.totalAmount,
        'method': _selectedMethod,
      }),
    );

    setState(() {
      _paymentStatus = jsonDecode(response.body)['status'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            for (var item in widget.cartItems)
              ListTile(
                title: Text(item['name']),
                trailing: Text('\$${item['price']}'),
              ),
            const Divider(),
            Text(
              'Total: \$${widget.totalAmount}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            const Text('Select Payment Method', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedMethod,
              items: const [
                DropdownMenuItem(
                  value: 'credit_card',
                  child: Text('Credit Card'),
                ),
                DropdownMenuItem(value: 'upi', child: Text('UPI Payment')),
              ],
              onChanged: (value) => setState(() => _selectedMethod = value!),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _processPayment,
              child: const Text('Confirm Payment'),
            ),
            const SizedBox(height: 20),
            Text(
              _paymentStatus,
              style: TextStyle(
                color: _paymentStatus == 'success' ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
