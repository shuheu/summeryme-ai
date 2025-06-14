import 'saved_article_summary.dart';

class SavedArticle {
  final int id;
  final int userId;
  final String title;
  final String url;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SavedArticleSummary? savedArticleSummary;

  SavedArticle({
    required this.id,
    required this.userId,
    required this.title,
    required this.url,
    required this.createdAt,
    required this.updatedAt,
    this.savedArticleSummary,
  });

  factory SavedArticle.fromJson(Map<String, dynamic> json) {
    return SavedArticle(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String,
      url: json['url'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      savedArticleSummary: json['savedArticleSummary'] != null
          ? SavedArticleSummary.fromJson(
              json['savedArticleSummary'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'url': url,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'savedArticleSummary': savedArticleSummary?.toJson(),
    };
  }
}
