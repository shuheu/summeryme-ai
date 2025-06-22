import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_daily_summary.dart';
import '../models/playlist.dart';
import '../screens/digest_detail_screen.dart';
import '../services/api_service.dart';
import '../services/audio_player_service.dart';
import '../themes/app_theme.dart';
import '../widgets/app_scaffold.dart';

class SummaryListScreen extends StatefulWidget {
  const SummaryListScreen({super.key});

  @override
  State<SummaryListScreen> createState() => _SummaryListScreenState();
}

class _SummaryListScreenState extends State<SummaryListScreen> {
  final ApiService _apiService = ApiService();
  final _urlController = TextEditingController();
  final _titleController = TextEditingController();

  List<UserDailySummary> _userDailySummaryList = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _loadDigests();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _loadDigests() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await _apiService.fetchUserDailySummaries(
        page: _currentPage,
        limit: 10,
      );

      final List<dynamic> digestData = response['data'] as List<dynamic>;
      final List<UserDailySummary> newDigests = digestData
          .map(
            (json) => UserDailySummary.fromJson(json as Map<String, dynamic>),
          )
          .toList();

      final pagination = response['pagination'] as Map<String, dynamic>;
      final hasNextPage = pagination['hasNextPage'] as bool;

      setState(() {
        if (_currentPage == 1) {
          _userDailySummaryList = newDigests;
        } else {
          _userDailySummaryList.addAll(newDigests);
        }
        _hasMoreData = hasNextPage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'ダイジェストの読み込みに失敗しました: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshDigests() async {
    _currentPage = 1;
    await _loadDigests();
  }

  Future<void> _loadMoreDigests() async {
    if (_hasMoreData && !_isLoading) {
      _currentPage++;
      await _loadDigests();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final maxWidth = isTablet ? 800.0 : double.infinity;

    if (_isLoading && _userDailySummaryList.isEmpty) {
      return AppScaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title:
              Text('Daily Summary', style: AppTextStyles.headline2(isTablet)),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null && _userDailySummaryList.isEmpty) {
      return AppScaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title:
              Text('Daily Summary', style: AppTextStyles.headline2(isTablet)),
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
                onPressed: _refreshDigests,
                child: const Text('再試行'),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state: no loading, no error, but no data
    if (!_isLoading && _errorMessage == null && _userDailySummaryList.isEmpty) {
      return AppScaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title:
              Text('Daily Summary', style: AppTextStyles.headline2(isTablet)),
        ),
        body: SafeArea(
          bottom: true,
          child: _buildEmptyState(isTablet),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddArticleModal(context),
          backgroundColor: AppColors.primary,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      );
    }

    return AppScaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Daily Summary', style: AppTextStyles.headline2(isTablet)),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: RefreshIndicator(
            onRefresh: _refreshDigests,
            child: ListView.builder(
              padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
              itemCount: _userDailySummaryList.length + (_hasMoreData ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _userDailySummaryList.length) {
                  // Load more button/indicator
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: _isLoading
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _loadMoreDigests,
                              child: const Text('さらに読み込む'),
                            ),
                    ),
                  );
                }
                final userDailySummary = _userDailySummaryList[index];
                return _buildDigestCard(context, userDailySummary, index == 0);
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddArticleModal(context),
        backgroundColor: AppColors.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildDigestCard(
    BuildContext context,
    UserDailySummary userDailySummary,
    bool isFirst,
  ) {
    // Format date for display
    final dateFormat =
        '${userDailySummary.generatedDate.year}年${userDailySummary.generatedDate.month}月${userDailySummary.generatedDate.day}日';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.light,
      ),
      child: InkWell(
        onTap: () {
          // Navigate to digest detail with digest ID
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => DigestDetailScreen(
                digestId: userDailySummary.id,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Article image
              Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isFirst
                        ? [const Color(0xFF4A90E2), const Color(0xFF357ABD)]
                        : [
                            const Color(0xFF6B8E23),
                            const Color(0xFF556B2F),
                          ],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.business, size: 48, color: Colors.white70),
                ),
              ),
              const SizedBox(height: 16),

              // Digest title
              const Text(
                'デイリーダイジェスト',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              // Article date and metadata
              Row(
                children: [
                  const Spacer(),
                  const Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Digest summary
              Text(
                userDailySummary.summary,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),

              // Play Summary button - MAIN FEATURE
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

                  return Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: AppGradients.primary, // 常に青いグラデーション
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: isButtonEnabled
                          ? () => _playAudioSummary(context, userDailySummary)
                          : null,
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: showPlayingState
                            ? (isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.volume_up,
                                    size: 20,
                                    color: Colors.white,
                                  ))
                            : const Icon(
                                Icons.headphones,
                                size: 20,
                                color: Colors.white,
                              ),
                      ),
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            showPlayingState
                                ? (isLoading ? '読み込み中...' : '再生中')
                                : '音声で聞く',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isButtonEnabled
                                  ? Colors.white
                                  : Colors.white70,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              showPlayingState ? '🎵' : '約3分',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.transparent,
                        disabledForegroundColor: Colors.white70,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddArticleModal(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 32.0 : 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text('新しい記事を追加', style: AppTextStyles.headline3(isTablet)),
              const SizedBox(height: 8),
              Text(
                '後で読みたい記事のURLを追加してください',
                style: AppTextStyles.bodyMedium(
                  isTablet,
                ).copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),

              // URL input
              Text('記事URL', style: AppTextStyles.labelMedium(isTablet)),
              const SizedBox(height: 8),
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  hintText: 'https://example.com/article',
                  prefixIcon: const Icon(Icons.link),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 24),

              // Title input (optional)
              Text(
                'タイトル（オプション）',
                style: AppTextStyles.labelMedium(isTablet),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: '記事のタイトルを入力',
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                ),
              ),
              const Spacer(),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _urlController.clear();
                        _titleController.clear();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'キャンセル',
                        style: AppTextStyles.labelMedium(
                          isTablet,
                        ).copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _addArticle(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        '追加',
                        style: AppTextStyles.labelMedium(
                          isTablet,
                        ).copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
            ],
          ),
        ),
      ),
    );
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

  Future<void> _addArticle(BuildContext context) async {
    if (_urlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URLを入力してください'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Show loading indicator
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final title = _titleController.text.trim().isNotEmpty
          ? _titleController.text.trim()
          : 'Untitled Article';

      await _apiService.createSavedArticle(
        title: title,
        url: _urlController.text.trim(),
      );

      // Check if widget is still mounted before using context
      if (!context.mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('記事を追加しました'),
          backgroundColor: AppColors.success,
        ),
      );

      _urlController.clear();
      _titleController.clear();
      Navigator.pop(context);
    } catch (e) {
      // Check if widget is still mounted before using context
      if (!context.mounted) return;

      // Close loading dialog
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('記事の追加に失敗しました: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// 空状態表示を構築
  Widget _buildEmptyState(bool isTablet) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 48.0 : 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // メインアイコン
            Container(
              padding: EdgeInsets.all(isTablet ? 32 : 24),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                size: isTablet ? 80 : 64,
                color: AppColors.primary,
              ),
            ),

            SizedBox(height: isTablet ? 32 : 24),

            // タイトル
            Text(
              'AIダイジェストへようこそ！',
              style: AppTextStyles.headline2(isTablet),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: isTablet ? 24 : 16),

            // サブタイトル
            Text(
              '記事を追加してAIによる自動要約を体験しましょう',
              style: AppTextStyles.bodyLarge(isTablet).copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: isTablet ? 40 : 32),

            // 機能リスト
            _buildFeatureList(isTablet),

            SizedBox(height: isTablet ? 40 : 32),

            // CTAボタン
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showAddArticleModal(context),
                icon: const Icon(Icons.add),
                label: const Text('最初の記事を追加'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 20 : 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 機能リストを構築
  Widget _buildFeatureList(bool isTablet) {
    final features = [
      {
        'icon': Icons.auto_awesome,
        'title': '記事の自動要約',
        'description': 'URLを追加するだけでAIが要約を生成\n（朝昼夕のタイミングでお届け）',
      },
      {
        'icon': Icons.headphones,
        'title': '音声再生',
        'description': '要約を音声で聞くことができる',
      },
      {
        'icon': Icons.view_list,
        'title': '記事ダイジェスト',
        'description': '記事の要約をまとめて確認',
      },
      {
        'icon': Icons.bookmark,
        'title': '記事保存',
        'description': '気になる記事を保存・あとで読む',
      },
    ];

    return Column(
      children: features
          .map(
            (feature) => _buildFeatureItem(
              feature['icon'] as IconData,
              feature['title'] as String,
              feature['description'] as String,
              isTablet,
            ),
          )
          .toList(),
    );
  }

  /// 機能アイテムを構築
  Widget _buildFeatureItem(
    IconData icon,
    String title,
    String description,
    bool isTablet,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: isTablet ? 20 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 12 : 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: isTablet ? 24 : 20,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge(isTablet).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.bodyMedium(isTablet).copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
