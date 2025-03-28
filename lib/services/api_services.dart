import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/menu_item.dart';
import '../models/reservation.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';

  static Future<List<MenuItem>> getMenu(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/menu?category=$category'),
      );
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => MenuItem.fromJson(item)).toList();
      }
      throw Exception('Failed to load menu');
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<bool> createReservation(Reservation reservation) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reservations'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(reservation.toJson()),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
