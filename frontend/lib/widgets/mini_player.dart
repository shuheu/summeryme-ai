import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../models/audio_track.dart';
import '../models/playback_state.dart';
import '../services/audio_player_service.dart';
import '../screens/audio_player_screen.dart';
import '../themes/app_theme.dart';

/// ミニプレイヤーWidget
/// 画面下部に固定表示され、基本的な音声コントロールを提供
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerService>(
      builder: (context, audioService, child) {
        // Web環境では条件を緩和
        if (kIsWeb) {
          // プレイリストがあれば表示
          if (audioService.currentPlaylist == null) {
            return const SizedBox.shrink();
          }
        } else {
          // モバイル環境では厳密な条件
          if (audioService.currentTrack == null) {
            return const SizedBox.shrink();
          }
        }

        final currentTrack = audioService.currentTrack;
        final playbackState = audioService.playbackState;
        final screenWidth = MediaQuery.of(context).size.width;
        final isTablet = screenWidth > 600;

        // currentTrackがnullの場合のフォールバック
        if (currentTrack == null && audioService.currentPlaylist != null) {
          final playlist = audioService.currentPlaylist!;
          if (playlist.tracks.isNotEmpty) {
            final fallbackTrack = playlist.tracks.first;
            return _buildMiniPlayerContent(
              context,
              fallbackTrack,
              playbackState,
              audioService,
              isTablet,
            );
          }
        }

        if (currentTrack == null) {
          return const SizedBox.shrink();
        }

        return _buildMiniPlayerContent(
          context,
          currentTrack,
          playbackState,
          audioService,
          isTablet,
        );
      },
    );
  }

  /// ミニプレイヤーのコンテンツを構築
  Widget _buildMiniPlayerContent(
    BuildContext context,
    AudioTrack currentTrack,
    PlaybackState playbackState,
    AudioPlayerService audioService,
    bool isTablet,
  ) {
    // Web用の特別なスタイリング
    final containerDecoration = kIsWeb
        ? BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(
                color: AppColors.border.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
          )
        : BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          );

    return Container(
      height: isTablet ? 80 : 70,
      width: double.infinity,
      decoration: containerDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToFullPlayer(context),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24.0 : 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                // アルバムアート（小）
                _buildAlbumArt(isTablet),
                const SizedBox(width: 12),

                // トラック情報
                Expanded(
                  child: _buildTrackInfo(currentTrack, playbackState, isTablet),
                ),

                // コントロールボタン
                _buildControls(context, audioService, isTablet),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// アルバムアート表示
  Widget _buildAlbumArt(bool isTablet) {
    final size = isTablet ? 56.0 : 48.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: AppGradients.primary,
      ),
      child: Icon(
        Icons.music_note,
        color: Colors.white,
        size: isTablet ? 28 : 24,
      ),
    );
  }

  /// トラック情報表示
  Widget _buildTrackInfo(
    AudioTrack currentTrack,
    PlaybackState playbackState,
    bool isTablet,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // トラックタイトル
        Text(
          currentTrack.title,
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),

        // 進捗バー
        _buildProgressBar(playbackState, isTablet),
      ],
    );
  }

  /// 進捗バー表示
  Widget _buildProgressBar(PlaybackState playbackState, bool isTablet) {
    final progress = (playbackState.duration?.inMilliseconds ?? 0) > 0
        ? playbackState.position.inMilliseconds /
            (playbackState.duration?.inMilliseconds ?? 1)
        : 0.0;

    return Container(
      height: isTablet ? 4.0 : 3.0,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  /// コントロールボタン表示
  Widget _buildControls(
    BuildContext context,
    AudioPlayerService audioService,
    bool isTablet,
  ) {
    final iconSize = isTablet ? 28.0 : 24.0;
    final buttonSize = isTablet ? 48.0 : 40.0;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 前のトラックボタン
        _buildControlButton(
          icon: Icons.skip_previous,
          iconSize: iconSize,
          buttonSize: buttonSize,
          onPressed: audioService.currentPlaylist?.hasPrevious == true
              ? () => audioService.previous()
              : null,
        ),
        const SizedBox(width: 8),

        // 再生/一時停止ボタン
        _buildControlButton(
          icon: audioService.isPlaying ? Icons.pause : Icons.play_arrow,
          iconSize: iconSize,
          buttonSize: buttonSize,
          onPressed: () {
            if (audioService.isPlaying) {
              audioService.pause();
            } else {
              audioService.play();
            }
          },
          isPrimary: true,
        ),
        const SizedBox(width: 8),

        // 次のトラックボタン
        _buildControlButton(
          icon: Icons.skip_next,
          iconSize: iconSize,
          buttonSize: buttonSize,
          onPressed: audioService.currentPlaylist?.hasNext == true
              ? () => audioService.next()
              : null,
        ),
      ],
    );
  }

  /// コントロールボタン作成
  Widget _buildControlButton({
    required IconData icon,
    required double iconSize,
    required double buttonSize,
    required VoidCallback? onPressed,
    bool isPrimary = false,
  }) {
    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          icon,
          size: iconSize,
          color: isPrimary
              ? AppColors.primary
              : (onPressed != null
                  ? AppColors.textPrimary
                  : AppColors.textTertiary),
        ),
        style: IconButton.styleFrom(
          backgroundColor: isPrimary
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          shape: const CircleBorder(),
        ),
      ),
    );
  }

  /// フルプレイヤー画面に遷移
  void _navigateToFullPlayer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const AudioPlayerScreen(),
        settings: const RouteSettings(name: '/audio_player'),
      ),
    );
  }
}
