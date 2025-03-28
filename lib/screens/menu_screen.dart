import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'payment_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<dynamic> _menuItems = [];
  String _selectedCategory = 'veg';
  final List<Map<String, dynamic>> _cart = [];

  Future<void> _loadMenu() async {
    final response = await http.get(
      Uri.parse('http://localhost:5000/api/menu?category=$_selectedCategory'),
    );
    setState(() => _menuItems = json.decode(response.body));
  }

  void _addToCart(item) {
    setState(
      () => _cart.add({
        'id': item['id'],
        'name': item['name'],
        'price': item['price'],
        'quantity': 1,
      }),
    );
  }

  double get _totalAmount {
    return _cart.fold(
      0,
      (sum, item) => sum + (item['price'] * item['quantity']),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => _showCartDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'veg', label: Text('Vegetarian')),
                ButtonSegment(value: 'non-veg', label: Text('Non-Veg')),
              ],
              selected: <String>{_selectedCategory},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedCategory = newSelection.first;
                  _loadMenu();
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                return ListTile(
                  leading: item['image_url'] != null
                      ? Image.network(
                          item['image_url'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.error),
                        )
                      : const Icon(Icons.fastfood),
                  title: Text(item['name']),
                  subtitle: Text('\$${item['price']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle),
                    color: Colors.green,
                    onPressed: () => _addToCart(item),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentScreen(
              cartItems: _cart,
              totalAmount: _totalAmount,
            ),
          ),
        ),
        label: const Text('Checkout'),
        icon: const Icon(Icons.payment),
      ),
    );
  }

  void _showCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your Cart'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var item in _cart)
              ListTile(
                title: Text(item['name']),
                trailing: Text('\$${item['price']}'),
              ),
            const Divider(),
            Text('Total: \$$_totalAmount'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
