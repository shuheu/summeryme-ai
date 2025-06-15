/// 音声トラック情報を表すモデル
class AudioTrack {
  /// 一意のID
  final String id;

  /// トラックのタイトル
  final String title;

  /// 音声ファイルのURL（認証付きURL）
  final String url;

  /// 音声の長さ（秒）
  final Duration? duration;

  /// ローカルダウンロードパス（オフライン再生用）
  final String? downloadPath;

  /// トラックの説明・概要
  final String? description;

  /// アートワーク画像URL
  final String? artworkUrl;

  /// 作成日時
  final DateTime createdAt;

  const AudioTrack({
    required this.id,
    required this.title,
    required this.url,
    this.duration,
    this.downloadPath,
    this.description,
    this.artworkUrl,
    required this.createdAt,
  });

  /// JSONからAudioTrackを作成
  factory AudioTrack.fromJson(Map<String, dynamic> json) {
    return AudioTrack(
      id: json['id'] as String,
      title: json['title'] as String,
      url: json['url'] as String,
      duration: json['duration'] != null
          ? Duration(seconds: json['duration'] as int)
          : null,
      downloadPath: json['downloadPath'] as String?,
      description: json['description'] as String?,
      artworkUrl: json['artworkUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// AudioTrackをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'duration': duration?.inSeconds,
      'downloadPath': downloadPath,
      'description': description,
      'artworkUrl': artworkUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// オフライン再生可能かどうか
  bool get isOfflineAvailable =>
      downloadPath != null && downloadPath!.isNotEmpty;

  /// トラックのコピーを作成（一部プロパティを変更）
  AudioTrack copyWith({
    String? id,
    String? title,
    String? url,
    Duration? duration,
    String? downloadPath,
    String? description,
    String? artworkUrl,
    DateTime? createdAt,
  }) {
    return AudioTrack(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      duration: duration ?? this.duration,
      downloadPath: downloadPath ?? this.downloadPath,
      description: description ?? this.description,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AudioTrack && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AudioTrack(id: $id, title: $title, duration: $duration)';
  }
}
