// API Service
// Handles all network calls to the DummyJSON Products API.
// https://dummyjson.com/products

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

// Simple custom exception so screens can show a friendly error message.
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  static const String baseUrl = 'https://dummyjson.com/products';

  // Fetch a page of products.
  // limit = how many products to fetch, skip = how many to skip (for pagination).
  Future<List<Product>> fetchProducts({int limit = 10, int skip = 0}) async {
    final url = Uri.parse('$baseUrl?limit=$limit&skip=$skip');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List productsJson = data['products'];
        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        throw ApiException('Server error: ${response.statusCode}');
      }
    } catch (e) {
      // Covers no internet, timeout, and any parsing errors.
      throw ApiException('Failed to load products. Please check your internet connection.');
    }
  }

  // Search products by a text query using DummyJSON's search endpoint.
  Future<List<Product>> searchProducts(String query) async {
    final url = Uri.parse('$baseUrl/search?q=$query');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List productsJson = data['products'];
        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        throw ApiException('Server error: ${response.statusCode}');
      }
    } catch (e) {
      throw ApiException('Search failed. Please check your internet connection.');
    }
  }
}
