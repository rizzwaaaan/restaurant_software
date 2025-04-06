import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'payment_screen.dart';
import 'package:restaurant/models/orders.dart';
import 'speech_helper.dart';

class MenuScreen extends StatefulWidget {
  final String? phoneNumber;
  const MenuScreen({super.key, this.phoneNumber});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<dynamic> _menuItems = [];
  String _selectedCategory = 'veg';
  String _selectedCourse = 'all';
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
      _showErrorSnackBar('Error: $e');
    }
  }

  Future<void> _placeOrder() async {
    if (widget.phoneNumber == null || widget.phoneNumber!.isEmpty) {
      _showErrorSnackBar('Please make a reservation first');
      return;
    }
    if (_cart.isEmpty) {
      _showErrorSnackBar('Cart is empty');
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
            content: Text('Order placed successfully!',
                style: GoogleFonts.poppins()),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showErrorSnackBar('Failed to place order');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    }
  }

  void _addToCart(item) {
    setState(() {
      _cart.add({
        'id': item['id'],
        'name': item['name'],
        'price': item['price'],
        'quantity': 1
      });
    });
  }

  double get _totalAmount {
    return _cart.fold(
        0, (sum, item) => sum + (item['price'] * item['quantity']));
  }

  void _showPhoneNumberDialog() {
    if (widget.phoneNumber == null || widget.phoneNumber!.isEmpty) {
      _showErrorSnackBar('Please make a reservation first');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentScreen(phoneNumber: widget.phoneNumber!),
      ),
    );
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
    _loadMenu();
    SpeechHelper.speak(
        'This is the Menu Screen. Browse items and add them to your cart after making a reservation.');
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
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Menu',
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Stack(
                          children: [
                            IconButton(
                              icon: Icon(Icons.shopping_cart,
                                  color: Colors.white, size: 30),
                              onPressed:
                                  _cart.isNotEmpty ? _showCartDialog : null,
                            ),
                            if (_cart.isNotEmpty)
                              Positioned(
                                right: 0,
                                top: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    _cart.length.toString(),
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildSegmentedButton(
                          ['veg', 'non-veg'],
                          ['Vegetarian', 'Non-Veg'],
                          _selectedCategory,
                          (value) => setState(() {
                            _selectedCategory = value;
                            _loadMenu();
                          }),
                        ),
                        const SizedBox(height: 15),
                        _buildSegmentedButton(
                          ['all', 'appetizer', 'main', 'dessert'],
                          ['All', 'Appetizers', 'Main', 'Desserts'],
                          _selectedCourse,
                          (value) => setState(() {
                            _selectedCourse = value;
                            _loadMenu();
                          }),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _menuItems.isEmpty
                        ? Center(
                            child:
                                CircularProgressIndicator(color: Colors.white))
                        : ListView.builder(
                            padding: const EdgeInsets.all(20),
                            itemCount: _menuItems.length,
                            itemBuilder: (context, index) {
                              final item = _menuItems[index];
                              return Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                margin: const EdgeInsets.only(bottom: 15),
                                child: ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: item['image_url'] != null
                                        ? Image.network(
                                            item['image_url'],
                                            width: 60,
                                            height: 60,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Icon(
                                                Icons.error,
                                                color: Colors.red),
                                          )
                                        : Icon(Icons.fastfood,
                                            color: Colors.teal.shade700),
                                  ),
                                  title: Text(item['name'],
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600)),
                                  subtitle: Text(
                                      '\$${item['price'].toStringAsFixed(2)}',
                                      style: GoogleFonts.poppins(
                                          color: Colors.grey[600])),
                                  trailing: IconButton(
                                    icon: Icon(Icons.add_circle,
                                        color: Colors.teal.shade700),
                                    onPressed: () => _addToCart(item),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  if (_cart.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed:
                                widget.phoneNumber != null ? _placeOrder : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal.shade700,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                            ),
                            child: Text(
                              'Order (\$${_totalAmount.toStringAsFixed(2)})',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: _showPhoneNumberDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15)),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                            ),
                            child: Text(
                              'Pay Now',
                              style: GoogleFonts.poppins(
                                color: Colors.teal.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
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

  Widget _buildSegmentedButton(List<String> values, List<String> labels,
      String selected, Function(String) onChanged) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(values.length, (index) {
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(values[index]),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected == values[index]
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    labels[index],
                    style: GoogleFonts.poppins(
                      color: selected == values[index]
                          ? Colors.teal.shade700
                          : Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
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
                fontWeight: FontWeight.bold, color: Colors.teal.shade700)),
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
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade700)),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close',
                style: GoogleFonts.poppins(color: Colors.teal.shade700)),
          ),
          ElevatedButton(
            onPressed: widget.phoneNumber != null ? _placeOrder : null,
            child: Text('Place Order',
                style: GoogleFonts.poppins(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade700,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
