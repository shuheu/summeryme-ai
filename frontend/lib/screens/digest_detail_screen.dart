import 'package:flutter/material.dart';
import '../models/user_daily_summary.dart';
import '../models/article.dart';
import '../models/saved_article.dart';
import '../services/api_service.dart';
import '../themes/app_theme.dart';
import '../widgets/app_scaffold.dart';
import 'package:provider/provider.dart';
import '../services/audio_player_service.dart';
import '../models/playlist.dart';
import 'article_detail_screen.dart';

class DigestDetailScreen extends StatefulWidget {
  const DigestDetailScreen({super.key, required this.digestId});
  final int digestId;

  @override
  State<DigestDetailScreen> createState() => _DigestDetailScreenState();
}

class _DigestDetailScreenState extends State<DigestDetailScreen> {
  final ApiService _apiService = ApiService();
  UserDailySummary? _userDailySummary;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDigestDetail();
  }

  Future<void> _loadDigestDetail() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final userDailySummary =
          await _apiService.fetchUserDailySummaryById(widget.digestId);

      setState(() {
        _userDailySummary = userDailySummary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'ダイジェストの読み込みに失敗しました: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = AppResponsive.isTablet(context);
    final maxWidth = AppResponsive.getMaxWidth(context);

    if (_isLoading) {
      return AppScaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return AppScaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDigestDetail,
                child: const Text('再試行'),
              ),
            ],
          ),
        ),
      );
    }

    final userDailySummary = _userDailySummary!;
    final dateFormat =
        '${userDailySummary.generatedDate.year}年${userDailySummary.generatedDate.month}月${userDailySummary.generatedDate.day}日';

    return AppScaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Hero section with gradient
          SliverAppBar(
            expandedHeight: isTablet ? 300 : 250,
            pinned: true,
            backgroundColor: AppColors.surface,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                  ),
                ),
                child: Stack(
                  children: [
                    // Main content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.auto_awesome,
                              size: isTablet ? 80 : 60,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'AI Digest',
                            style: AppTextStyles.headline2(isTablet).copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content section
          SliverToBoxAdapter(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              margin: EdgeInsets.symmetric(horizontal: isTablet ? 48.0 : 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // Article metadata
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppShadows.light,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF4A90E2),
                                    Color(0xFF357ABD),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'AI要約',
                                style: AppTextStyles.bodySmall(
                                  isTablet,
                                ).copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Spacer(),
                            const SizedBox(width: 4),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'デイリーダイジェスト',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Spacer(),
                            const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              dateFormat,
                              style: AppTextStyles.bodySmall(
                                isTablet,
                              ).copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // AI Summary section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.05),
                          AppColors.primary.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.auto_awesome,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'AI Generated Summary',
                              style: AppTextStyles.headline3(
                                isTablet,
                              ).copyWith(color: AppColors.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          userDailySummary.summary,
                          style: AppTextStyles.bodyLarge(
                            isTablet,
                          ).copyWith(height: 1.7),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Play Audio - Main Action
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.1),
                          AppColors.primary.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Audio icon with animation placeholder
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: AppGradients.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        const SizedBox(height: 20),

                        Text(
                          'Audio Summary',
                          style: AppTextStyles.headline3(
                            isTablet,
                          ).copyWith(color: AppColors.primary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'AIが生成した音声サマリーを聞く',
                          style: AppTextStyles.bodyMedium(
                            isTablet,
                          ).copyWith(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // Play button
                        Consumer<AudioPlayerService>(
                          builder: (context, audioPlayerService, child) {
                            final currentPlaylistId =
                                'daily_summary_${userDailySummary.id}';
                            final isCurrentlyPlaying =
                                audioPlayerService.currentPlaylist?.id ==
                                    currentPlaylistId;
                            final isPlaying = audioPlayerService.isPlaying;
                            final isLoading = audioPlayerService.isLoading;

                            // ボタンの状態を決定
                            final bool isButtonEnabled =
                                !isCurrentlyPlaying || !isPlaying;
                            final bool showPlayingState =
                                isCurrentlyPlaying && (isPlaying || isLoading);

                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: isButtonEnabled
                                    ? () => _playAudioSummary(
                                          context,
                                          userDailySummary,
                                        )
                                    : null,
                                icon: showPlayingState
                                    ? (isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                            ),
                                          )
                                        : const Icon(Icons.volume_up, size: 24))
                                    : const Icon(Icons.headphones, size: 24),
                                label: Text(
                                  showPlayingState
                                      ? (isLoading ? '読み込み中...' : '再生中')
                                      : '音声で聞く',
                                  style: AppTextStyles.labelLarge(isTablet)
                                      .copyWith(
                                    color: isButtonEnabled
                                        ? Colors.white
                                        : Colors.white70,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: showPlayingState
                                      ? const Color(0xFF4CAF50)
                                      : AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 18),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                  disabledBackgroundColor:
                                      AppColors.primary.withValues(alpha: 0.6),
                                  disabledForegroundColor: Colors.white70,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Related Articles section
                  if (userDailySummary.userDailySummarySavedArticles != null &&
                      userDailySummary
                          .userDailySummarySavedArticles!.isNotEmpty) ...[
                    Text(
                      '要約元の記事',
                      style: AppTextStyles.headline3(isTablet),
                    ),
                    const SizedBox(height: 16),
                    ...userDailySummary.userDailySummarySavedArticles!
                        .map((article) {
                      final savedArticle = article.savedArticle;
                      if (savedArticle == null) return const SizedBox.shrink();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppShadows.light,
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              _navigateToArticleDetail(context, savedArticle);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          Icons.article_outlined,
                                          color: AppColors.primary,
                                          size: isTablet ? 24 : 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          savedArticle.title,
                                          style:
                                              AppTextStyles.bodyLarge(isTablet)
                                                  .copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.link,
                                        size: 16,
                                        color: AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          savedArticle.url,
                                          style:
                                              AppTextStyles.bodySmall(isTablet)
                                                  .copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],

                  SizedBox(
                    height: 48 + MediaQuery.of(context).padding.bottom,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _calculateTimeAgo(DateTime createdAt) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()}週間前';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}日前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}時間前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分前';
    } else {
      return 'たった今';
    }
  }

  String _extractSourceFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host.replaceAll('www.', '');
    } catch (e) {
      return 'Web';
    }
  }

  void _navigateToArticleDetail(
    BuildContext context,
    SavedArticle savedArticle,
  ) {
    try {
      final article = Article(
        id: savedArticle.id.toString(),
        title: savedArticle.title,
        source: _extractSourceFromUrl(savedArticle.url),
        timeAgo: _calculateTimeAgo(savedArticle.createdAt),
        summary: savedArticle.savedArticleSummary?.summary ?? '',
        url: savedArticle.url,
        createdAt: savedArticle.createdAt,
      );

      Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (context) => ArticleDetailScreen(article: article),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('記事の表示に失敗しました: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _playAudioSummary(
    BuildContext context,
    UserDailySummary userDailySummary,
  ) async {
    try {
      // ローディング表示
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // 音声URLを取得
      final audioTracks = await _apiService.fetchAudioUrlsForDailySummary(
        userDailySummary.id,
      );

      // ローディング閉じる
      if (context.mounted) {
        Navigator.pop(context);
      }

      if (audioTracks.isEmpty) {
        // 音声ファイルが存在しない場合
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('この記事には音声サマリーがありません'),
              backgroundColor: AppColors.textSecondary,
            ),
          );
        }
        return;
      }

      // 音声プレイヤーサービスで再生
      if (context.mounted) {
        final audioPlayerService = Provider.of<AudioPlayerService>(
          context,
          listen: false,
        );

        // AudioTrackのリストからPlaylistを作成
        final playlist = Playlist(
          id: 'daily_summary_${userDailySummary.id}',
          title: 'デイリーサマリー ${userDailySummary.id}',
          tracks: audioTracks,
          currentIndex: 0,
          createdAt: DateTime.now(),
        );

        await audioPlayerService.playPlaylist(playlist);
      }
    } catch (e) {
      // エラーが発生した場合
      if (context.mounted) {
        // ローディング画面が表示されている場合は閉じる
        Navigator.of(context).popUntil((route) => route.isFirst);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('音声の再生に失敗しました: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
