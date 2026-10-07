import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/product.dart';

class ApiService {
  final String baseUrl = 'http://10.0.2.2:8000';
  final storage = const FlutterSecureStorage();

  Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/products'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);
        final List<dynamic> products = jsonData['data'];
        return products.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Gagal mengambil data');
      }
    } catch (error) {
      throw Exception('Terjadi kesalahan: $error');
    }
  }

  Future<void> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      await storage.write(key: 'token', value: token);
    } else {
      throw Exception('Login gagal');
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    final token = await storage.read(key: 'token');

    final response = await http.get(
      Uri.parse('$baseUrl/api/profile'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal mengambil profil');
    }
  }

  Future<void> logout() async {
    await storage.delete(key: 'token');
  }
}