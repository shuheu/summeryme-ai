import 'saved_article.dart';

class UserDailySummarySavedArticle {
  final int id;
  final int userDailySummaryId;
  final int savedArticleId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SavedArticle? savedArticle;

  UserDailySummarySavedArticle({
    required this.id,
    required this.userDailySummaryId,
    required this.savedArticleId,
    required this.createdAt,
    required this.updatedAt,
    this.savedArticle,
  });

  factory UserDailySummarySavedArticle.fromJson(Map<String, dynamic> json) {
    return UserDailySummarySavedArticle(
      id: json['id'] as int,
      userDailySummaryId: json['userDailySummaryId'] as int,
      savedArticleId: json['savedArticleId'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      savedArticle: json['savedArticle'] != null
          ? SavedArticle.fromJson(json['savedArticle'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userDailySummaryId': userDailySummaryId,
      'savedArticleId': savedArticleId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'savedArticle': savedArticle?.toJson(),
    };
  }
}
