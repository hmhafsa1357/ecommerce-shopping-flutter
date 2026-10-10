import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

/// An error with a message that is safe to show directly to the user.
class ProductException implements Exception {
  final String message;
  const ProductException(this.message);

  @override
  String toString() => message;
}

/// Talks to the free DummyJSON product API (no API key needed).
class ProductService {
  static const _host = 'dummyjson.com';

  final http.Client _client;

  ProductService({http.Client? client}) : _client = client ?? http.Client();

  /// Fetches the whole catalog in one request (limit=0 means "all").
  Future<List<Product>> fetchProducts() async {
    final uri = Uri.https(_host, '/products', {
      'limit': '0',
      'select':
      'title,description,category,price,rating,stock,brand,thumbnail,images',
    });

    try {
      final response =
      await _client.get(uri).timeout(const Duration(seconds: 20));
      if (response.statusCode != 200) {
        throw ProductException(
            'The store returned an error (${response.statusCode}). Please try again.');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final list = json['products'] as List;
      return list
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
    } on ProductException {
      rethrow;
    } on TimeoutException {
      throw const ProductException(
          'The request timed out. Check your connection and try again.');
    } on http.ClientException {
      throw const ProductException(
          'No internet connection. Check your network and try again.');
    } on FormatException {
      throw const ProductException(
          'Received unexpected data from the store.');
    } catch (_) {
      throw const ProductException('Something went wrong. Please try again.');
    }
  }
}