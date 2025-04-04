import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'payment_screen.dart';
import 'package:restaurant/models/orders.dart';
import 'speech_helper.dart'; // Import SpeechHelper

class MenuScreen extends StatefulWidget {
  final String? phoneNumber;
  const MenuScreen({super.key, this.phoneNumber});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<dynamic> _menuItems = [];
  String _selectedCategory = 'veg';
  String _selectedCourse = 'all'; // Added course selection
  final List<Map<String, dynamic>> _cart = [];

  Future<void> _loadMenu() async {
    try {
      final uri = Uri.parse(
          'http://localhost:5000/api/menu?category=$_selectedCategory${_selectedCourse != 'all' ? '&course=$_selectedCourse' : ''}');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        setState(() => _menuItems = json.decode(response.body));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<void> _placeOrder() async {
    if (_cart.isEmpty) return;
    if (widget.phoneNumber == null || widget.phoneNumber!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Phone number is required'),
            backgroundColor: Colors.redAccent),
      );
      return;
    }
    final order = Order(
      id: 0,
      phone: widget.phoneNumber!,
      items: _cart,
      total: _totalAmount,
      status: 'pending',
    );
    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/orders'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(order.toJson()),
      );
      if (response.statusCode == 201) {
        setState(() => _cart.clear());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order placed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to place order'),
              backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  void _addToCart(item) {
    setState(() {
      _cart.add({
        'id': item['id'],
        'name': item['name'],
        'price': item['price'],
        'quantity': 1,
      });
    });
  }

  double get _totalAmount {
    return _cart.fold(
        0, (sum, item) => sum + (item['price'] * item['quantity']));
  }

  void _showPhoneNumberDialog() {
    final TextEditingController phoneController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    if (widget.phoneNumber != null && widget.phoneNumber!.isNotEmpty) {
      phoneController.text = widget.phoneNumber!;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Enter Phone Number',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold, color: Colors.teal),
        ),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              labelStyle: GoogleFonts.poppins(color: Colors.teal),
              prefixIcon: const Icon(Icons.phone, color: Colors.teal),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Phone number is required';
              }
              if (value.length < 10) {
                return 'Phone number must be at least 10 digits';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text('Cancel', style: GoogleFonts.poppins(color: Colors.teal)),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        PaymentScreen(phoneNumber: phoneController.text),
                  ),
                );
              }
            },
            child: Text('Proceed',
                style: GoogleFonts.poppins(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadMenu();
    SpeechHelper.speak(
        'This is the Menu Screen. Browse vegetarian or non-vegetarian items by course - appetizers, main courses, or desserts. Add them to your cart and place your order or proceed to payment.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Menu',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart, color: Colors.white),
                if (_cart.isNotEmpty)
                  Positioned(
                    right: 0,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.redAccent,
                      child: Text(
                        _cart.length.toString(),
                        style: GoogleFonts.poppins(
                            fontSize: 10, color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _cart.isNotEmpty ? _showCartDialog : null,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                        value: 'veg',
                        label:
                            Text('Vegetarian', style: GoogleFonts.poppins())),
                    ButtonSegment(
                        value: 'non-veg',
                        label: Text('Non-Veg', style: GoogleFonts.poppins())),
                  ],
                  selected: {_selectedCategory},
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      _selectedCategory = newSelection.first;
                      _loadMenu();
                    });
                  },
                  style: SegmentedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.teal,
                    selectedForegroundColor: Colors.white,
                    selectedBackgroundColor: Colors.teal,
                  ),
                ),
                const SizedBox(height: 16),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                        value: 'all',
                        label: Text('All', style: GoogleFonts.poppins())),
                    ButtonSegment(
                        value: 'appetizer',
                        label:
                            Text('Appetizers', style: GoogleFonts.poppins())),
                    ButtonSegment(
                        value: 'main',
                        label:
                            Text('Main Course', style: GoogleFonts.poppins())),
                    ButtonSegment(
                        value: 'dessert',
                        label: Text('Desserts', style: GoogleFonts.poppins())),
                  ],
                  selected: {_selectedCourse},
                  onSelectionChanged: (newSelection) {
                    setState(() {
                      _selectedCourse = newSelection.first;
                      _loadMenu();
                    });
                  },
                  style: SegmentedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.teal,
                    selectedForegroundColor: Colors.white,
                    selectedBackgroundColor: Colors.teal,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _menuItems.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _menuItems.length,
                    itemBuilder: (context, index) {
                      final item = _menuItems[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: item['image_url'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item['image_url'],
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.error,
                                                color: Colors.red),
                                  ),
                                )
                              : const Icon(Icons.fastfood, color: Colors.teal),
                          title: Text(item['name'],
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600)),
                          subtitle: Text(
                              '\$${item['price'].toStringAsFixed(2)}',
                              style:
                                  GoogleFonts.poppins(color: Colors.grey[600])),
                          trailing: IconButton(
                            icon: const Icon(Icons.add_circle,
                                color: Colors.teal),
                            onPressed: () => _addToCart(item),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_cart.isNotEmpty)
            FloatingActionButton.extended(
              onPressed: _placeOrder,
              label: Text(
                'Place Order (\$${_totalAmount.toStringAsFixed(2)})',
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              backgroundColor: Colors.teal,
            ),
          const SizedBox(width: 10),
          FloatingActionButton.extended(
            onPressed: _showPhoneNumberDialog,
            label: Text(
              'Go to Payment',
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            backgroundColor: Colors.teal,
          ),
        ],
      ),
    );
  }

  void _showCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Your Cart',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold, color: Colors.teal)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: _cart.length,
                itemBuilder: (context, index) {
                  final item = _cart[index];
                  return ListTile(
                    title: Text(item['name'], style: GoogleFonts.poppins()),
                    subtitle: Text('Qty: ${item['quantity']}',
                        style: GoogleFonts.poppins(color: Colors.grey[600])),
                    trailing: Text(
                        '\$${(item['price'] * item['quantity']).toStringAsFixed(2)}',
                        style:
                            GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  );
                },
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total:',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                  Text('\$${_totalAmount.toStringAsFixed(2)}',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, color: Colors.teal)),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text('Close', style: GoogleFonts.poppins(color: Colors.teal)),
          ),
          ElevatedButton(
            onPressed: _placeOrder,
            child: Text('Place Order',
                style: GoogleFonts.poppins(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
