/// プレイヤーの再生状態を表すモデル
class PlaybackState {
  /// 再生状態
  final PlayerState playerState;

  /// 現在の再生位置（秒）
  final Duration position;

  /// 総再生時間（秒）
  final Duration? duration;

  /// 音量（0.0〜1.0）
  final double volume;

  /// 再生速度（0.5〜2.0）
  final double speed;

  /// ミュートかどうか
  final bool isMuted;

  /// ローディング中かどうか
  final bool isLoading;

  /// エラーメッセージ
  final String? error;

  /// 最後に更新された時刻
  final DateTime lastUpdated;

  const PlaybackState({
    this.playerState = PlayerState.stopped,
    this.position = Duration.zero,
    this.duration,
    this.volume = 1.0,
    this.speed = 1.0,
    this.isMuted = false,
    this.isLoading = false,
    this.error,
    required this.lastUpdated,
  });

  /// 初期状態のPlaybackStateを作成
  factory PlaybackState.initial() {
    return PlaybackState(
      lastUpdated: DateTime.now(),
    );
  }

  /// JSONからPlaybackStateを作成
  factory PlaybackState.fromJson(Map<String, dynamic> json) {
    return PlaybackState(
      playerState: PlayerState.values[json['playerState'] as int? ?? 0],
      position: Duration(seconds: json['position'] as int? ?? 0),
      duration: json['duration'] != null
          ? Duration(seconds: json['duration'] as int)
          : null,
      volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
      speed: (json['speed'] as num?)?.toDouble() ?? 1.0,
      isMuted: json['isMuted'] as bool? ?? false,
      isLoading: json['isLoading'] as bool? ?? false,
      error: json['error'] as String?,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  /// PlaybackStateをJSONに変換
  Map<String, dynamic> toJson() {
    return {
      'playerState': playerState.index,
      'position': position.inSeconds,
      'duration': duration?.inSeconds,
      'volume': volume,
      'speed': speed,
      'isMuted': isMuted,
      'isLoading': isLoading,
      'error': error,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// 再生中かどうか
  bool get isPlaying => playerState == PlayerState.playing;

  /// 一時停止中かどうか
  bool get isPaused => playerState == PlayerState.paused;

  /// 停止中かどうか
  bool get isStopped => playerState == PlayerState.stopped;

  /// 再生進捗率（0.0〜1.0）
  double get progress {
    if (duration == null || duration!.inMilliseconds == 0) return 0.0;
    final progress = position.inMilliseconds / duration!.inMilliseconds;
    return progress.clamp(0.0, 1.0);
  }

  /// 残り時間
  Duration get remainingTime {
    if (duration == null) return Duration.zero;
    final remaining = duration! - position;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// エラー状態かどうか
  bool get hasError => error != null && error!.isNotEmpty;

  /// PlaybackStateのコピーを作成（一部プロパティを変更）
  PlaybackState copyWith({
    PlayerState? playerState,
    Duration? position,
    Duration? duration,
    double? volume,
    double? speed,
    bool? isMuted,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return PlaybackState(
      playerState: playerState ?? this.playerState,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      volume: volume ?? this.volume,
      speed: speed ?? this.speed,
      isMuted: isMuted ?? this.isMuted,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }

  /// エラーをクリア
  PlaybackState clearError() {
    return copyWith(error: null);
  }

  /// ローディング状態を設定
  PlaybackState setLoading(bool loading) {
    return copyWith(isLoading: loading);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlaybackState &&
        other.playerState == playerState &&
        other.position == position &&
        other.duration == duration &&
        other.volume == volume &&
        other.speed == speed &&
        other.isMuted == isMuted &&
        other.isLoading == isLoading &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(
      playerState,
      position,
      duration,
      volume,
      speed,
      isMuted,
      isLoading,
      error,
    );
  }

  @override
  String toString() {
    return 'PlaybackState(state: $playerState, position: $position, duration: $duration, volume: $volume, speed: $speed)';
  }
}

/// プレイヤーの状態
enum PlayerState {
  /// 停止中
  stopped,

  /// 再生中
  playing,

  /// 一時停止中
  paused,

  /// バッファリング中
  buffering,

  /// 完了
  completed,
}

extension PlayerStateExtension on PlayerState {
  /// プレイヤー状態の表示名
  String get displayName {
    switch (this) {
      case PlayerState.stopped:
        return '停止';
      case PlayerState.playing:
        return '再生中';
      case PlayerState.paused:
        return '一時停止';
      case PlayerState.buffering:
        return 'バッファリング中';
      case PlayerState.completed:
        return '完了';
    }
  }

  /// プレイヤー状態のアイコン名
  String get iconName {
    switch (this) {
      case PlayerState.stopped:
        return 'stop';
      case PlayerState.playing:
        return 'pause';
      case PlayerState.paused:
        return 'play_arrow';
      case PlayerState.buffering:
        return 'hourglass_empty';
      case PlayerState.completed:
        return 'replay';
    }
  }
}
