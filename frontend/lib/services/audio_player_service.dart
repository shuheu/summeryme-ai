import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../models/audio_track.dart';
import '../models/playlist.dart';
import '../models/playback_state.dart' as models;

/// 音声プレイヤーサービスの基底クラス
class AudioPlayerService extends ChangeNotifier {
  /// JustAudioのプレイヤーインスタンス
  late final AudioPlayer _audioPlayer;

  /// 現在のプレイリスト
  Playlist? _currentPlaylist;

  /// 現在の再生状態
  models.PlaybackState _playbackState = models.PlaybackState.initial();

  /// 再生位置の更新用ストリーム
  StreamSubscription<Duration>? _positionSubscription;

  /// プレイヤー状態の更新用ストリーム
  StreamSubscription<PlayerState>? _playerStateSubscription;

  /// 音声の長さ更新用ストリーム
  StreamSubscription<Duration?>? _durationSubscription;

  /// コンストラクタ
  AudioPlayerService() {
    _initializePlayer();
  }

  /// プレイヤーを初期化
  void _initializePlayer() {
    _audioPlayer = AudioPlayer();

    // プレイヤー状態の変更を監視
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      _updatePlayerState(state);
    });

    // 再生位置の変更を監視
    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      _updatePosition(position);
    });

    // 音声の長さの変更を監視
    _durationSubscription = _audioPlayer.durationStream.listen((duration) {
      _updateDuration(duration);
    });
  }

  /// 現在のプレイリスト
  Playlist? get currentPlaylist => _currentPlaylist;

  /// 現在の再生状態
  models.PlaybackState get playbackState => _playbackState;

  /// 現在のトラック
  AudioTrack? get currentTrack => _currentPlaylist?.currentTrack;

  /// 再生中かどうか
  bool get isPlaying => _playbackState.isPlaying;

  /// 一時停止中かどうか
  bool get isPaused => _playbackState.isPaused;

  /// 停止中かどうか
  bool get isStopped => _playbackState.isStopped;

  /// プレイリストを設定して再生を開始
  Future<void> playPlaylist(Playlist playlist) async {
    try {
      _setLoadingState(true);

      _currentPlaylist = playlist;

      if (playlist.tracks.isEmpty) {
        throw Exception('プレイリストが空です');
      }

      final currentTrack = playlist.currentTrack;
      if (currentTrack == null) {
        throw Exception('再生可能なトラックがありません');
      }

      await _loadAndPlayTrack(currentTrack);

      notifyListeners();
    } catch (e) {
      _setError('プレイリストの再生に失敗しました: $e');
    } finally {
      _setLoadingState(false);
    }
  }

  /// 再生を開始
  Future<void> play() async {
    try {
      await _audioPlayer.play();
    } catch (e) {
      _setError('再生に失敗しました: $e');
    }
  }

  /// 一時停止
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      _setError('一時停止に失敗しました: $e');
    }
  }

  /// 停止
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      _setError('停止に失敗しました: $e');
    }
  }

  /// 指定位置にシーク
  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      _setError('シークに失敗しました: $e');
    }
  }

  /// 次のトラックに移動
  Future<void> next() async {
    if (_currentPlaylist == null) return;

    final nextIndex = _currentPlaylist!.nextIndex;
    if (nextIndex != null) {
      _currentPlaylist = _currentPlaylist!.copyWith(currentIndex: nextIndex);
      final nextTrack = _currentPlaylist!.currentTrack;
      if (nextTrack != null) {
        await _loadAndPlayTrack(nextTrack);
        notifyListeners();
      }
    }
  }

  /// 前のトラックに移動
  Future<void> previous() async {
    if (_currentPlaylist == null) return;

    final previousIndex = _currentPlaylist!.previousIndex;
    if (previousIndex != null) {
      _currentPlaylist =
          _currentPlaylist!.copyWith(currentIndex: previousIndex);
      final previousTrack = _currentPlaylist!.currentTrack;
      if (previousTrack != null) {
        await _loadAndPlayTrack(previousTrack);
        notifyListeners();
      }
    }
  }

  /// 音量を設定（0.0〜1.0）
  Future<void> setVolume(double volume) async {
    try {
      final clampedVolume = volume.clamp(0.0, 1.0);
      await _audioPlayer.setVolume(clampedVolume);
      _playbackState = _playbackState.copyWith(volume: clampedVolume);
      notifyListeners();
    } catch (e) {
      _setError('音量設定に失敗しました: $e');
    }
  }

  /// 再生速度を設定（0.5〜2.0）
  Future<void> setSpeed(double speed) async {
    try {
      final clampedSpeed = speed.clamp(0.5, 2.0);
      await _audioPlayer.setSpeed(clampedSpeed);
      _playbackState = _playbackState.copyWith(speed: clampedSpeed);
      notifyListeners();
    } catch (e) {
      _setError('再生速度設定に失敗しました: $e');
    }
  }

  /// リピートモードを設定
  void setRepeatMode(PlaylistRepeatMode repeatMode) {
    if (_currentPlaylist != null) {
      _currentPlaylist = _currentPlaylist!.copyWith(repeatMode: repeatMode);
      notifyListeners();
    }
  }

  /// シャッフルモードを切り替え
  void toggleShuffle() {
    if (_currentPlaylist != null) {
      _currentPlaylist = _currentPlaylist!.copyWith(
        isShuffled: !_currentPlaylist!.isShuffled,
      );
      notifyListeners();
    }
  }

  /// トラックを読み込んで再生
  Future<void> _loadAndPlayTrack(AudioTrack track) async {
    try {
      _setLoadingState(true);

      // オフライン再生が可能な場合はローカルファイルを使用
      final audioSource = track.isOfflineAvailable
          ? AudioSource.file(track.downloadPath!)
          : AudioSource.uri(Uri.parse(track.url));

      await _audioPlayer.setAudioSource(audioSource);
      await _audioPlayer.play();
    } catch (e) {
      _setError('トラックの読み込みに失敗しました: $e');
    } finally {
      _setLoadingState(false);
    }
  }

  /// プレイヤー状態を更新
  void _updatePlayerState(PlayerState state) {
    models.PlayerState modelState;

    switch (state.processingState) {
      case ProcessingState.idle:
        modelState = models.PlayerState.stopped;
        break;
      case ProcessingState.loading:
      case ProcessingState.buffering:
        modelState = models.PlayerState.buffering;
        break;
      case ProcessingState.ready:
        modelState = state.playing
            ? models.PlayerState.playing
            : models.PlayerState.paused;
        break;
      case ProcessingState.completed:
        modelState = models.PlayerState.completed;
        _handleTrackCompleted();
        break;
    }

    _playbackState = _playbackState.copyWith(playerState: modelState);
    notifyListeners();
  }

  /// 再生位置を更新
  void _updatePosition(Duration position) {
    _playbackState = _playbackState.copyWith(position: position);
    notifyListeners();
  }

  /// 音声の長さを更新
  void _updateDuration(Duration? duration) {
    _playbackState = _playbackState.copyWith(duration: duration);
    notifyListeners();
  }

  /// トラック完了時の処理
  void _handleTrackCompleted() {
    if (_currentPlaylist?.repeatMode == PlaylistRepeatMode.one) {
      // 1曲リピートの場合は同じトラックを再生
      play();
    } else if (_currentPlaylist?.hasNext == true) {
      // 次のトラックがある場合は自動再生
      next();
    }
  }

  /// ローディング状態を設定
  void _setLoadingState(bool isLoading) {
    _playbackState = _playbackState.copyWith(isLoading: isLoading);
    notifyListeners();
  }

  /// エラー状態を設定
  void _setError(String error) {
    _playbackState = _playbackState.copyWith(error: error);
    notifyListeners();
  }

  /// エラーをクリア
  void clearError() {
    _playbackState = _playbackState.clearError();
    notifyListeners();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
