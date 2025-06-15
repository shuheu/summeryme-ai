import 'audio_track.dart';

/// 複数の音声トラックを管理するプレイリスト
class Playlist {
  /// プレイリストのID
  final String id;

  /// プレイリストのタイトル
  final String title;

  /// プレイリストの説明
  final String? description;

  /// トラック一覧
  final List<AudioTrack> tracks;

  /// 現在再生中のトラックインデックス
  final int currentIndex;

  /// シャッフルモードかどうか
  final bool isShuffled;

  /// リピートモード
  final PlaylistRepeatMode repeatMode;

  /// 作成日時
  final DateTime createdAt;

  const Playlist({
    required this.id,
    required this.title,
    this.description,
    required this.tracks,
    this.currentIndex = 0,
    this.isShuffled = false,
    this.repeatMode = PlaylistRepeatMode.none,
    required this.createdAt,
  });

  /// JSONからPlaylistを作成
  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      tracks: (json['tracks'] as List<dynamic>)
          .map((trackJson) =>
              AudioTrack.fromJson(trackJson as Map<String, dynamic>))
          .toList(),
      currentIndex: json['currentIndex'] as int? ?? 0,
      isShuffled: json['isShuffled'] as bool? ?? false,
      repeatMode: PlaylistRepeatMode.values[json['repeatMode'] as int? ?? 0],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// PlaylistをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'tracks': tracks.map((track) => track.toJson()).toList(),
      'currentIndex': currentIndex,
      'isShuffled': isShuffled,
      'repeatMode': repeatMode.index,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// 現在のトラックを取得
  AudioTrack? get currentTrack {
    if (tracks.isEmpty || currentIndex < 0 || currentIndex >= tracks.length) {
      return null;
    }
    return tracks[currentIndex];
  }

  /// 次のトラックがあるかどうか
  bool get hasNext {
    if (repeatMode == PlaylistRepeatMode.all) return true;
    if (repeatMode == PlaylistRepeatMode.one) return true;
    return currentIndex < tracks.length - 1;
  }

  /// 前のトラックがあるかどうか
  bool get hasPrevious {
    if (repeatMode == PlaylistRepeatMode.all) return true;
    if (repeatMode == PlaylistRepeatMode.one) return true;
    return currentIndex > 0;
  }

  /// 次のトラックのインデックスを取得
  int? get nextIndex {
    if (tracks.isEmpty) return null;

    switch (repeatMode) {
      case PlaylistRepeatMode.none:
        return currentIndex < tracks.length - 1 ? currentIndex + 1 : null;
      case PlaylistRepeatMode.one:
        return currentIndex;
      case PlaylistRepeatMode.all:
        return (currentIndex + 1) % tracks.length;
    }
  }

  /// 前のトラックのインデックスを取得
  int? get previousIndex {
    if (tracks.isEmpty) return null;

    switch (repeatMode) {
      case PlaylistRepeatMode.none:
        return currentIndex > 0 ? currentIndex - 1 : null;
      case PlaylistRepeatMode.one:
        return currentIndex;
      case PlaylistRepeatMode.all:
        return currentIndex == 0 ? tracks.length - 1 : currentIndex - 1;
    }
  }

  /// 総再生時間を取得
  Duration get totalDuration {
    return tracks.fold<Duration>(
      Duration.zero,
      (total, track) => total + (track.duration ?? Duration.zero),
    );
  }

  /// オフライン再生可能なトラック数
  int get offlineTrackCount {
    return tracks.where((track) => track.isOfflineAvailable).length;
  }

  /// プレイリストのコピーを作成（一部プロパティを変更）
  Playlist copyWith({
    String? id,
    String? title,
    String? description,
    List<AudioTrack>? tracks,
    int? currentIndex,
    bool? isShuffled,
    PlaylistRepeatMode? repeatMode,
    DateTime? createdAt,
  }) {
    return Playlist(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      tracks: tracks ?? this.tracks,
      currentIndex: currentIndex ?? this.currentIndex,
      isShuffled: isShuffled ?? this.isShuffled,
      repeatMode: repeatMode ?? this.repeatMode,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Playlist && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Playlist(id: $id, title: $title, tracks: ${tracks.length}, currentIndex: $currentIndex)';
  }
}

/// プレイリストのリピートモード
enum PlaylistRepeatMode {
  /// リピートしない
  none,

  /// 1曲リピート
  one,

  /// 全曲リピート
  all,
}

extension PlaylistRepeatModeExtension on PlaylistRepeatMode {
  /// リピートモードの表示名
  String get displayName {
    switch (this) {
      case PlaylistRepeatMode.none:
        return 'リピートなし';
      case PlaylistRepeatMode.one:
        return '1曲リピート';
      case PlaylistRepeatMode.all:
        return '全曲リピート';
    }
  }

  /// リピートモードのアイコン名
  String get iconName {
    switch (this) {
      case PlaylistRepeatMode.none:
        return 'repeat';
      case PlaylistRepeatMode.one:
        return 'repeat_one';
      case PlaylistRepeatMode.all:
        return 'repeat';
    }
  }
}
