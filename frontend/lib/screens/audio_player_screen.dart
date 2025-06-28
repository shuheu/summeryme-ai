import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_player_service.dart';
import '../models/playback_state.dart' as models;
import '../models/audio_track.dart';
import '../themes/app_theme.dart';

class AudioPlayerScreen extends StatelessWidget {
  const AudioPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        // title: Text(
        //   '音声プレイヤー',
        //   style: AppTextStyles.headline3(isTablet),
        // ),
        centerTitle: true,
      ),
      body: Consumer<AudioPlayerService>(
        builder: (context, audioService, child) {
          final currentTrack = audioService.currentTrack;
          final playbackState = audioService.playbackState;

          if (currentTrack == null) {
            return const Center(
              child: Text(
                '再生中のトラックがありません',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            );
          }

          return Padding(
            padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
            child: Column(
              children: [
                const Spacer(),

                // アルバムアート風デザイン
                _buildAlbumArt(isTablet),

                const SizedBox(height: 32),

                // トラック情報
                _buildTrackInfo(currentTrack, isTablet),

                const SizedBox(height: 32),

                // 進捗バー
                _buildProgressBar(context, audioService, playbackState),

                const SizedBox(height: 32),

                // コントロールボタン
                _buildControlButtons(audioService, playbackState),

                // const Spacer(),

                // 追加コントロール
                // _buildAdditionalControls(audioService, playbackState, isTablet),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAlbumArt(bool isTablet) {
    final size = isTablet ? 300.0 : 250.0;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: AppGradients.primary,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.headphones,
          size: 80,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTrackInfo(AudioTrack currentTrack, bool isTablet) {
    return Column(
      children: [
        Text(
          currentTrack.title,
          style: TextStyle(
            fontSize: isTablet ? 24 : 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        // const SizedBox(height: 8),
        // Text(
        //   currentTrack.description ?? 'デイリーサマリー',
        //   style: TextStyle(
        //     fontSize: isTablet ? 16 : 14,
        //     color: AppColors.textSecondary,
        //   ),
        //   textAlign: TextAlign.center,
        //   maxLines: 1,
        //   overflow: TextOverflow.ellipsis,
        // ),
      ],
    );
  }

  Widget _buildProgressBar(BuildContext context,
      AudioPlayerService audioService, models.PlaybackState playbackState) {
    final position = playbackState.position;
    final duration = playbackState.duration;
    final progress = duration != null && duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.border,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.2),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: progress.clamp(0.0, 1.0),
            onChanged: (value) {
              if (duration != null) {
                final newPosition = Duration(
                  milliseconds: (value * duration.inMilliseconds).round(),
                );
                audioService.seek(newPosition);
              }
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(position),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                _formatDuration(duration ?? Duration.zero),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildControlButtons(
      AudioPlayerService audioService, models.PlaybackState playbackState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // 前のトラック
        // IconButton(
        //   onPressed: audioService.currentPlaylist?.hasPrevious == true
        //       ? () => audioService.previous()
        //       : null,
        //   icon: const Icon(Icons.skip_previous),
        //   iconSize: 40,
        //   color: audioService.currentPlaylist?.hasPrevious == true
        //       ? AppColors.textPrimary
        //       : AppColors.textTertiary,
        // ),

        // 15秒戻る
        IconButton(
          onPressed: () {
            final currentPosition = playbackState.position;
            final newPosition = currentPosition - const Duration(seconds: 15);
            audioService
                .seek(newPosition.isNegative ? Duration.zero : newPosition);
          },
          icon: const Icon(Icons.replay_10),
          iconSize: 32,
          color: AppColors.textSecondary,
        ),

        // 再生/一時停止
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppGradients.primary,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: IconButton(
            onPressed: playbackState.isLoading
                ? null
                : () {
                    if (audioService.isPlaying) {
                      audioService.pause();
                    } else {
                      audioService.play();
                    }
                  },
            icon: playbackState.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(
                    audioService.isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 32,
                    color: Colors.white,
                  ),
            iconSize: 64,
          ),
        ),

        // 10秒進む
        IconButton(
          onPressed: () {
            final currentPosition = playbackState.position;
            final duration = playbackState.duration;
            final newPosition = currentPosition + const Duration(seconds: 10);
            if (duration != null && newPosition <= duration) {
              audioService.seek(newPosition);
            }
          },
          icon: const Icon(Icons.forward_10),
          iconSize: 32,
          color: AppColors.textSecondary,
        ),

        // 次のトラック
        // IconButton(
        //   onPressed: audioService.currentPlaylist?.hasNext == true
        //       ? () => audioService.next()
        //       : null,
        //   icon: const Icon(Icons.skip_next),
        //   iconSize: 40,
        //   color: audioService.currentPlaylist?.hasNext == true
        //       ? AppColors.textPrimary
        //       : AppColors.textTertiary,
        // ),
      ],
    );
  }

  Widget _buildAdditionalControls(AudioPlayerService audioService,
      models.PlaybackState playbackState, bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // 再生速度
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.speed, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${playbackState.speed.toStringAsFixed(1)}x',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // 音量
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.volume_up,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                '${(playbackState.volume * 100).round()}%',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
