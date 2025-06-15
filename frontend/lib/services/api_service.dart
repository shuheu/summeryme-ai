import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_daily_summary.dart';
import '../models/saved_article.dart';

class ApiService {
  // 遅延初期化で環境変数を取得
  static String? _baseUrl;

  static String get baseUrl {
    // null の場合のみ初期化
    _baseUrl ??= const String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://localhost:8080',
    );
    return _baseUrl!;
  }

  Future<Map<String, dynamic>> fetchSavedArticles({
    int page = 1,
    int limit = 10,
  }) async {
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

  Future<Map<String, dynamic>> fetchUserDailySummaries({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/user-daily-summaries?page=$page&limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
        },
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
        headers: {
          'Content-Type': 'application/json',
        },
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
        headers: {
          'Content-Type': 'application/json',
        },
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
}
