import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_daily_summary.dart';
import '../models/saved_article.dart';

class ApiService {
  // ignore: prefer_const_constructors
  static final String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  // Get headers with authentication
  static Map<String, String> _getAuthHeaders() {
    final user = FirebaseAuth.instance.currentUser;
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (user != null) {
      headers['X-User-UID'] = user.uid;
    }

    return headers;
  }

  Future<Map<String, dynamic>> fetchSavedArticles({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/saved-articles?page=$page&limit=$limit'),
        headers: _getAuthHeaders(),
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
        headers: _getAuthHeaders(),
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
        headers: _getAuthHeaders(),
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

  Future<Map<String, dynamic>> fetchUserDailySummaries({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/user-daily-summaries?page=$page&limit=$limit'),
        headers: _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data as Map<String, dynamic>;
      } else {
        throw Exception(
          'Failed to load daily summaries: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching daily summaries: $e');
    }
  }

  Future<UserDailySummary> fetchUserDailySummaryById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/user-daily-summaries/$id'),
        headers: _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return UserDailySummary.fromJson(data['data'] as Map<String, dynamic>);
      } else {
        throw Exception('Failed to load daily summary: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching daily summary: $e');
    }
  }

  Future<SavedArticle> fetchSavedArticleById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/saved-articles/$id'),
        headers: _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return SavedArticle.fromJson(data['data'] as Map<String, dynamic>);
      } else {
        throw Exception('Failed to load saved article: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching saved article: $e');
    }
  }

  // ユーザー認証API（UIDで検索、存在しなければ作成）
  static Future<Map<String, dynamic>?> authenticateUser({
    required String uid,
    required String name,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/users/auth'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'uid': uid,
          'name': name,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        // TODO: Use proper logging framework
        print('Failed to authenticate user: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      // TODO: Use proper logging framework
      print('Error authenticating user: $e');
      return null;
    }
  }

  // ユーザー情報取得API
  static Future<Map<String, dynamic>?> getUser(String uid) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/users/$uid'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        // User not found is expected behavior
        return null;
      } else {
        // TODO: Use proper logging framework
        print('Failed to get user: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      // TODO: Use proper logging framework
      print('Error getting user: $e');
      return null;
    }
  }
}
