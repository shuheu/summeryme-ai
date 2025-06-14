import 'user_daily_summary_saved_article.dart';

class UserDailySummary {
  final int id;
  final int userId;
  final String summary;
  final String? audioUrl;
  final DateTime generatedDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<UserDailySummarySavedArticle>? userDailySummarySavedArticles;

  UserDailySummary({
    required this.id,
    required this.userId,
    required this.summary,
    this.audioUrl,
    required this.generatedDate,
    required this.createdAt,
    required this.updatedAt,
    this.userDailySummarySavedArticles,
  });

  factory UserDailySummary.fromJson(Map<String, dynamic> json) {
    return UserDailySummary(
      id: json['id'] as int,
      userId: json['userId'] as int,
      summary: json['summary'] as String,
      audioUrl: json['audioUrl'] as String?,
      generatedDate: DateTime.parse(json['generatedDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      userDailySummarySavedArticles:
          json['userDailySummarySavedArticles'] != null
              ? (json['userDailySummarySavedArticles'] as List)
                  .map((e) => UserDailySummarySavedArticle.fromJson(
                      e as Map<String, dynamic>))
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'summary': summary,
      'audioUrl': audioUrl,
      'generatedDate': generatedDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'userDailySummarySavedArticles':
          userDailySummarySavedArticles?.map((e) => e.toJson()).toList(),
    };
  }

  UserDailySummary copyWith({
    int? id,
    int? userId,
    String? summary,
    String? audioUrl,
    DateTime? generatedDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<UserDailySummarySavedArticle>? userDailySummarySavedArticles,
  }) {
    return UserDailySummary(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      summary: summary ?? this.summary,
      audioUrl: audioUrl ?? this.audioUrl,
      generatedDate: generatedDate ?? this.generatedDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userDailySummarySavedArticles:
          userDailySummarySavedArticles ?? this.userDailySummarySavedArticles,
    );
  }
}
