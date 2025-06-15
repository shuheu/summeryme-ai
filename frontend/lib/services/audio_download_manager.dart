import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../models/audio_track.dart';

/// 音声ファイルのダウンロード状態
enum DownloadStatus {
  /// 未ダウンロード
  notDownloaded,

  /// ダウンロード中
  downloading,

  /// ダウンロード完了
  downloaded,

  /// ダウンロード失敗
  failed,

  /// 一時停止中
  paused,
}

/// ダウンロード進捗情報
class DownloadProgress {
  /// ダウンロード状態
  final DownloadStatus status;

  /// ダウンロード済みバイト数
  final int downloadedBytes;

  /// 総バイト数
  final int totalBytes;

  /// エラーメッセージ
  final String? error;

  const DownloadProgress({
    required this.status,
    this.downloadedBytes = 0,
    this.totalBytes = 0,
    this.error,
  });

  /// ダウンロード進捗率（0.0〜1.0）
  double get progress {
    if (totalBytes == 0) return 0.0;
    return (downloadedBytes / totalBytes).clamp(0.0, 1.0);
  }

  /// ダウンロード完了かどうか
  bool get isCompleted => status == DownloadStatus.downloaded;

  /// ダウンロード中かどうか
  bool get isDownloading => status == DownloadStatus.downloading;

  /// エラー状態かどうか
  bool get hasError => error != null && error!.isNotEmpty;

  DownloadProgress copyWith({
    DownloadStatus? status,
    int? downloadedBytes,
    int? totalBytes,
    String? error,
  }) {
    return DownloadProgress(
      status: status ?? this.status,
      downloadedBytes: downloadedBytes ?? this.downloadedBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      error: error ?? this.error,
    );
  }
}

/// 音声ファイルのダウンロード管理サービス
class AudioDownloadManager extends ChangeNotifier {
  /// ダウンロード進捗状況のマップ（トラックID -> 進捗情報）
  final Map<String, DownloadProgress> _downloadProgress = {};

  /// アクティブなダウンロードのキャンセル用トークン
  final Map<String, http.Client> _activeDownloads = {};

  /// 音声ファイル保存用ディレクトリ
  Directory? _audioDirectory;

  /// 初期化
  Future<void> initialize() async {
    await _ensureAudioDirectory();
  }

  /// ダウンロード進捗状況を取得
  DownloadProgress getDownloadProgress(String trackId) {
    return _downloadProgress[trackId] ??
        const DownloadProgress(status: DownloadStatus.notDownloaded);
  }

  /// すべてのダウンロード進捗状況を取得
  Map<String, DownloadProgress> getAllDownloadProgress() {
    return Map.unmodifiable(_downloadProgress);
  }

  /// 音声ファイルをダウンロード
  Future<String?> downloadAudioTrack(AudioTrack track) async {
    final trackId = track.id;

    // 既にダウンロード済みの場合
    if (_downloadProgress[trackId]?.isCompleted == true) {
      return _getLocalFilePath(trackId);
    }

    // 既にダウンロード中の場合
    if (_downloadProgress[trackId]?.isDownloading == true) {
      return null;
    }

    try {
      await _ensureAudioDirectory();

      // ダウンロード開始
      _updateProgress(
          trackId,
          const DownloadProgress(
            status: DownloadStatus.downloading,
          ));

      final client = http.Client();
      _activeDownloads[trackId] = client;

      final response = await client.get(Uri.parse(track.url));

      if (response.statusCode == 200) {
        final fileName = _generateFileName(trackId, track.title);
        final filePath = '${_audioDirectory!.path}/$fileName';
        final file = File(filePath);

        await file.writeAsBytes(response.bodyBytes);

        // ダウンロード完了
        _updateProgress(
            trackId,
            DownloadProgress(
              status: DownloadStatus.downloaded,
              downloadedBytes: response.bodyBytes.length,
              totalBytes: response.bodyBytes.length,
            ));

        _activeDownloads.remove(trackId);
        return filePath;
      } else {
        throw Exception(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      _updateProgress(
          trackId,
          DownloadProgress(
            status: DownloadStatus.failed,
            error: 'ダウンロードに失敗しました: $e',
          ));
      _activeDownloads.remove(trackId);
      return null;
    }
  }

  /// 大きなファイルのダウンロード（進捗付き）
  Future<String?> downloadAudioTrackWithProgress(AudioTrack track) async {
    final trackId = track.id;

    // 既にダウンロード済みの場合
    if (_downloadProgress[trackId]?.isCompleted == true) {
      return _getLocalFilePath(trackId);
    }

    // 既にダウンロード中の場合
    if (_downloadProgress[trackId]?.isDownloading == true) {
      return null;
    }

    try {
      await _ensureAudioDirectory();

      final client = http.Client();
      _activeDownloads[trackId] = client;

      final request = http.Request('GET', Uri.parse(track.url));
      final response = await client.send(request);

      if (response.statusCode == 200) {
        final totalBytes = response.contentLength ?? 0;
        final fileName = _generateFileName(trackId, track.title);
        final filePath = '${_audioDirectory!.path}/$fileName';
        final file = File(filePath);

        // ファイルストリーム書き込み用
        final sink = file.openWrite();
        int downloadedBytes = 0;

        // 初期進捗更新
        _updateProgress(
            trackId,
            DownloadProgress(
              status: DownloadStatus.downloading,
              downloadedBytes: 0,
              totalBytes: totalBytes,
            ));

        // ストリーミングダウンロード
        await for (final chunk in response.stream) {
          sink.add(chunk);
          downloadedBytes += chunk.length;

          // 進捗更新（1KB毎または完了時）
          if (downloadedBytes % 1024 == 0 || downloadedBytes == totalBytes) {
            _updateProgress(
                trackId,
                DownloadProgress(
                  status: DownloadStatus.downloading,
                  downloadedBytes: downloadedBytes,
                  totalBytes: totalBytes,
                ));
          }
        }

        await sink.close();

        // ダウンロード完了
        _updateProgress(
            trackId,
            DownloadProgress(
              status: DownloadStatus.downloaded,
              downloadedBytes: downloadedBytes,
              totalBytes: totalBytes,
            ));

        _activeDownloads.remove(trackId);
        return filePath;
      } else {
        throw Exception(
            'HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      _updateProgress(
          trackId,
          DownloadProgress(
            status: DownloadStatus.failed,
            error: 'ダウンロードに失敗しました: $e',
          ));
      _activeDownloads.remove(trackId);
      return null;
    }
  }

  /// ダウンロードをキャンセル
  Future<void> cancelDownload(String trackId) async {
    final client = _activeDownloads[trackId];
    if (client != null) {
      client.close();
      _activeDownloads.remove(trackId);

      _updateProgress(
          trackId,
          const DownloadProgress(
            status: DownloadStatus.notDownloaded,
          ));
    }
  }

  /// ダウンロード済みファイルを削除
  Future<bool> deleteDownloadedTrack(String trackId) async {
    try {
      final filePath = _getLocalFilePath(trackId);
      if (filePath != null) {
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
          _downloadProgress.remove(trackId);
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 指定トラックがダウンロード済みかチェック
  Future<bool> isTrackDownloaded(String trackId) async {
    final filePath = _getLocalFilePath(trackId);
    if (filePath == null) return false;

    final file = File(filePath);
    return await file.exists();
  }

  /// ダウンロード済みファイルのパスを取得
  String? getDownloadedTrackPath(String trackId) {
    if (_downloadProgress[trackId]?.isCompleted == true) {
      return _getLocalFilePath(trackId);
    }
    return null;
  }

  /// すべてのダウンロード済みファイルを取得
  Future<List<FileSystemEntity>> getAllDownloadedFiles() async {
    await _ensureAudioDirectory();
    return await _audioDirectory!.list().toList();
  }

  /// ダウンロード済みファイルの総サイズを取得
  Future<int> getTotalDownloadedSize() async {
    int totalSize = 0;
    final files = await getAllDownloadedFiles();

    for (final file in files) {
      if (file is File) {
        final stat = await file.stat();
        totalSize += stat.size;
      }
    }

    return totalSize;
  }

  /// すべてのダウンロード済みファイルを削除
  Future<void> clearAllDownloads() async {
    await _ensureAudioDirectory();
    final files = await _audioDirectory!.list().toList();

    for (final file in files) {
      if (file is File) {
        await file.delete();
      }
    }

    _downloadProgress.clear();
    notifyListeners();
  }

  /// 進捗状況を更新
  void _updateProgress(String trackId, DownloadProgress progress) {
    _downloadProgress[trackId] = progress;
    notifyListeners();
  }

  /// 音声ファイル保存ディレクトリを確保
  Future<void> _ensureAudioDirectory() async {
    if (_audioDirectory != null) return;

    final appDir = await getApplicationDocumentsDirectory();
    _audioDirectory = Directory('${appDir.path}/audio');

    if (!await _audioDirectory!.exists()) {
      await _audioDirectory!.create(recursive: true);
    }
  }

  /// ローカルファイルパスを生成
  String? _getLocalFilePath(String trackId) {
    if (_audioDirectory == null) return null;
    // 実際のファイル名を検索（拡張子が不明な場合）
    final files = _audioDirectory!.listSync();
    for (final file in files) {
      if (file.path.contains(trackId)) {
        return file.path;
      }
    }
    return null;
  }

  /// ファイル名を生成
  String _generateFileName(String trackId, String title) {
    // ファイル名に使えない文字を除去
    final cleanTitle = title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
    return '${trackId}_$cleanTitle.wav';
  }

  @override
  void dispose() {
    // すべてのアクティブダウンロードをキャンセル
    for (final client in _activeDownloads.values) {
      client.close();
    }
    _activeDownloads.clear();
    super.dispose();
  }
}
