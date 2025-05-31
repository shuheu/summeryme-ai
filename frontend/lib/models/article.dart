class Article {
  Article({
    required this.id,
    required this.title,
    required this.source,
    required this.timeAgo,
    required this.summary,
    required this.imageUrl,
    this.isRead = false,
    this.isSaved = false,
    required this.readTime,
  });
  final String id;
  final String title;
  final String source;
  final String timeAgo;
  final String summary;
  final String imageUrl;
  final bool isRead;
  final bool isSaved;
  final String readTime;

  Article copyWith({
    String? id,
    String? title,
    String? source,
    String? timeAgo,
    String? summary,
    String? imageUrl,
    bool? isRead,
    bool? isSaved,
    String? readTime,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      source: source ?? this.source,
      timeAgo: timeAgo ?? this.timeAgo,
      summary: summary ?? this.summary,
      imageUrl: imageUrl ?? this.imageUrl,
      isRead: isRead ?? this.isRead,
      isSaved: isSaved ?? this.isSaved,
      readTime: readTime ?? this.readTime,
    );
  }
}
