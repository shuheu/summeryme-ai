import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/playlist.dart';
import '../models/playback_state.dart';

/// 再生状態の永続化を管理するクラス
class PlaybackStateManager {
  static const String _keyCurrentPlaylist = 'current_playlist';
  static const String _keyPlaybackState = 'playback_state';
  static const String _keyLastPosition = 'last_position';
  static const String _keyCurrentTrackId = 'current_track_id';
  static const String _keyVolume = 'volume';
  static const String _keySpeed = 'speed';
  static const String _keyRepeatMode = 'repeat_mode';
  static const String _keyIsShuffled = 'is_shuffled';

  /// SharedPreferencesのインスタンス
  SharedPreferences? _prefs;

  /// SharedPreferencesを初期化
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// 現在のプレイリストを保存
  Future<void> saveCurrentPlaylist(Playlist playlist) async {
    await _ensureInitialized();
    await _prefs!.setString(_keyCurrentPlaylist, jsonEncode(playlist.toJson()));
  }

  /// 現在のプレイリストを読み込み
  Future<Playlist?> loadCurrentPlaylist() async {
    await _ensureInitialized();
    final playlistJson = _prefs!.getString(_keyCurrentPlaylist);
    if (playlistJson == null) return null;

    try {
      final playlistMap = jsonDecode(playlistJson) as Map<String, dynamic>;
      return Playlist.fromJson(playlistMap);
    } catch (e) {
      // JSONの解析に失敗した場合は削除
      await _prefs!.remove(_keyCurrentPlaylist);
      return null;
    }
  }

  /// 再生状態を保存
  Future<void> savePlaybackState(PlaybackState playbackState) async {
    await _ensureInitialized();
    await _prefs!
        .setString(_keyPlaybackState, jsonEncode(playbackState.toJson()));
  }

  /// 再生状態を読み込み
  Future<PlaybackState?> loadPlaybackState() async {
    await _ensureInitialized();
    final stateJson = _prefs!.getString(_keyPlaybackState);
    if (stateJson == null) return null;

    try {
      final stateMap = jsonDecode(stateJson) as Map<String, dynamic>;
      return PlaybackState.fromJson(stateMap);
    } catch (e) {
      // JSONの解析に失敗した場合は削除
      await _prefs!.remove(_keyPlaybackState);
      return null;
    }
  }

  /// 最後の再生位置を保存
  Future<void> saveLastPosition(String trackId, Duration position) async {
    await _ensureInitialized();
    final key = '${_keyLastPosition}_$trackId';
    await _prefs!.setInt(key, position.inSeconds);
  }

  /// 最後の再生位置を読み込み
  Future<Duration?> loadLastPosition(String trackId) async {
    await _ensureInitialized();
    final key = '${_keyLastPosition}_$trackId';
    final seconds = _prefs!.getInt(key);
    return seconds != null ? Duration(seconds: seconds) : null;
  }

  /// 現在のトラックIDを保存
  Future<void> saveCurrentTrackId(String trackId) async {
    await _ensureInitialized();
    await _prefs!.setString(_keyCurrentTrackId, trackId);
  }

  /// 現在のトラックIDを読み込み
  Future<String?> loadCurrentTrackId() async {
    await _ensureInitialized();
    return _prefs!.getString(_keyCurrentTrackId);
  }

  /// 音量設定を保存
  Future<void> saveVolume(double volume) async {
    await _ensureInitialized();
    await _prefs!.setDouble(_keyVolume, volume);
  }

  /// 音量設定を読み込み
  Future<double> loadVolume() async {
    await _ensureInitialized();
    return _prefs!.getDouble(_keyVolume) ?? 1.0;
  }

  /// 再生速度設定を保存
  Future<void> saveSpeed(double speed) async {
    await _ensureInitialized();
    await _prefs!.setDouble(_keySpeed, speed);
  }

  /// 再生速度設定を読み込み
  Future<double> loadSpeed() async {
    await _ensureInitialized();
    return _prefs!.getDouble(_keySpeed) ?? 1.0;
  }

  /// リピートモードを保存
  Future<void> saveRepeatMode(PlaylistRepeatMode repeatMode) async {
    await _ensureInitialized();
    await _prefs!.setInt(_keyRepeatMode, repeatMode.index);
  }

  /// リピートモードを読み込み
  Future<PlaylistRepeatMode> loadRepeatMode() async {
    await _ensureInitialized();
    final index = _prefs!.getInt(_keyRepeatMode) ?? 0;
    return PlaylistRepeatMode
        .values[index.clamp(0, PlaylistRepeatMode.values.length - 1)];
  }

  /// シャッフルモードを保存
  Future<void> saveIsShuffled(bool isShuffled) async {
    await _ensureInitialized();
    await _prefs!.setBool(_keyIsShuffled, isShuffled);
  }

  /// シャッフルモードを読み込み
  Future<bool> loadIsShuffled() async {
    await _ensureInitialized();
    return _prefs!.getBool(_keyIsShuffled) ?? false;
  }

  /// トラックの再生履歴を保存
  Future<void> saveTrackPlayHistory(String trackId) async {
    await _ensureInitialized();
    final key = 'play_history_$trackId';
    final now = DateTime.now().millisecondsSinceEpoch;
    await _prefs!.setInt(key, now);
  }

  /// トラックの再生履歴を読み込み
  Future<DateTime?> loadTrackPlayHistory(String trackId) async {
    await _ensureInitialized();
    final key = 'play_history_$trackId';
    final timestamp = _prefs!.getInt(key);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  /// 複数のトラックの再生位置を一括保存
  Future<void> saveMultipleTrackPositions(
      Map<String, Duration> positions) async {
    await _ensureInitialized();
    for (final entry in positions.entries) {
      final key = '${_keyLastPosition}_${entry.key}';
      await _prefs!.setInt(key, entry.value.inSeconds);
    }
  }

  /// 複数のトラックの再生位置を一括読み込み
  Future<Map<String, Duration>> loadMultipleTrackPositions(
      List<String> trackIds) async {
    await _ensureInitialized();
    final positions = <String, Duration>{};

    for (final trackId in trackIds) {
      final key = '${_keyLastPosition}_$trackId';
      final seconds = _prefs!.getInt(key);
      if (seconds != null) {
        positions[trackId] = Duration(seconds: seconds);
      }
    }

    return positions;
  }

  /// すべての保存データをクリア
  Future<void> clearAll() async {
    await _ensureInitialized();
    final keys = _prefs!.getKeys();
    final keysToRemove = keys.where((key) =>
        key.startsWith(_keyCurrentPlaylist) ||
        key.startsWith(_keyPlaybackState) ||
        key.startsWith(_keyLastPosition) ||
        key.startsWith(_keyCurrentTrackId) ||
        key.startsWith(_keyVolume) ||
        key.startsWith(_keySpeed) ||
        key.startsWith(_keyRepeatMode) ||
        key.startsWith(_keyIsShuffled) ||
        key.startsWith('play_history_'));

    for (final key in keysToRemove) {
      await _prefs!.remove(key);
    }
  }

  /// 古い再生履歴を削除（30日以上前）
  Future<void> cleanOldPlayHistory() async {
    await _ensureInitialized();
    final keys = _prefs!.getKeys();
    final historyKeys = keys.where((key) => key.startsWith('play_history_'));
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    for (final key in historyKeys) {
      final timestamp = _prefs!.getInt(key);
      if (timestamp != null) {
        final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (date.isBefore(thirtyDaysAgo)) {
          await _prefs!.remove(key);
        }
      }
    }
  }

  /// プレイリストの設定（リピート、シャッフル）を復元
  Future<Playlist?> restorePlaylistSettings(Playlist playlist) async {
    final repeatMode = await loadRepeatMode();
    final isShuffled = await loadIsShuffled();

    return playlist.copyWith(
      repeatMode: repeatMode,
      isShuffled: isShuffled,
    );
  }

  /// SharedPreferencesの初期化を確認
  Future<void> _ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
}
