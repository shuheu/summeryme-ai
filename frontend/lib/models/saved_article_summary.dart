class SavedArticleSummary {
  final int id;
  final int savedArticleId;
  final String summary;
  final DateTime createdAt;
  final DateTime updatedAt;

  SavedArticleSummary({
    required this.id,
    required this.savedArticleId,
    required this.summary,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SavedArticleSummary.fromJson(Map<String, dynamic> json) {
    return SavedArticleSummary(
      id: json['id'] as int,
      savedArticleId: json['savedArticleId'] as int,
      summary: json['summary'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'savedArticleId': savedArticleId,
      'summary': summary,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
