class Article {
  Article({
    required this.id,
    required this.title,
    required this.source,
    required this.timeAgo,
    required this.summary,
    this.url,
    this.createdAt,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.parse(json['createdAt'] as String);
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    String timeAgo;
    if (difference.inDays > 7) {
      timeAgo = '${(difference.inDays / 7).floor()}週間前';
    } else if (difference.inDays > 0) {
      timeAgo = '${difference.inDays}日前';
    } else if (difference.inHours > 0) {
      timeAgo = '${difference.inHours}時間前';
    } else if (difference.inMinutes > 0) {
      timeAgo = '${difference.inMinutes}分前';
    } else {
      timeAgo = 'たった今';
    }

    // Extract source from URL or use a default
    String source = 'Web';
    if (json['url'] != null) {
      final uri = Uri.tryParse(json['url'] as String);
      if (uri != null) {
        source = uri.host.replaceAll('www.', '');
      }
    }

    // Get summary from savedArticleSummary if available
    String summary = '';
    if (json['savedArticleSummary'] != null &&
        json['savedArticleSummary'] is List &&
        (json['savedArticleSummary'] as List).isNotEmpty) {
      summary =
          (json['savedArticleSummary'] as List)[0]['summary'] as String? ?? '';
    }

    return Article(
      id: json['id'].toString(),
      title: json['title'] as String? ?? '',
      source: source,
      timeAgo: timeAgo,
      summary: summary,
      url: json['url'] as String?,
      createdAt: createdAt,
    );
  }

  final String id;
  final String title;
  final String source;
  final String timeAgo;
  final String summary;
  final String? url;
  final DateTime? createdAt;

  Article copyWith({
    String? id,
    String? title,
    String? source,
    String? timeAgo,
    String? summary,
    String? url,
    DateTime? createdAt,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      source: source ?? this.source,
      timeAgo: timeAgo ?? this.timeAgo,
      summary: summary ?? this.summary,
      url: url ?? this.url,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
