import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080';

  Future<Map<String, dynamic>> fetchSavedArticles(
      {int page = 1, int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/saved-articles?page=$page&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] as Map<String, dynamic>;
      } else {
        throw Exception(
            'Failed to load saved articles: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching saved articles: $e');
    }
  }

  Future<void> deleteSavedArticle(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/saved-articles/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete article: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting article: $e');
    }
  }

  Future<Map<String, dynamic>> createSavedArticle({
    required String title,
    required String url,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/saved-articles'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'title': title,
          'url': url,
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data['data'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to save article: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error saving article: $e');
    }
  }
}
