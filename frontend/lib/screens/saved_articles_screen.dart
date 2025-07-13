import 'package:flutter/material.dart';
import '../models/article.dart';
import '../screens/article_detail_screen.dart';
import '../services/api_service.dart';
import '../themes/app_theme.dart';

class SavedArticlesScreen extends StatefulWidget {
  const SavedArticlesScreen({super.key});

  @override
  State<SavedArticlesScreen> createState() => _SavedArticlesScreenState();
}

class _SavedArticlesScreenState extends State<SavedArticlesScreen> {
  final ApiService _apiService = ApiService();
  final _urlController = TextEditingController();
  final _titleController = TextEditingController();
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Map<String, List<Article>> groupedArticles = {};
  Map<String, List<Article>> filteredGroupedArticles = {};
  List<Article> allArticles = []; // Keep track of all loaded articles
  bool isLoading = true;
  bool isLoadingMore = false;
  String? errorMessage;
  int currentPage = 1;
  int totalPages = 1;
  bool hasMorePages = false;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadSavedArticles();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !isLoadingMore &&
        hasMorePages &&
        searchQuery.isEmpty) {
      _loadMoreArticles();
    }
  }

  Future<void> _loadSavedArticles() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      currentPage = 1;
      allArticles = [];
    });

    try {
      final response = await _apiService.fetchSavedArticles(page: currentPage);
      final savedArticlesList = response['savedArticles'] as List<dynamic>;
      final pagination = response['pagination'] as Map<String, dynamic>;

      final articles = savedArticlesList
          .map((json) => Article.fromJson(json as Map<String, dynamic>))
          .toList();

      setState(() {
        allArticles = articles;
        totalPages = pagination['totalPages'] as int;
        hasMorePages = pagination['hasNextPage'] as bool;
        isLoading = false;
      });

      _updateGroupedArticles();

      // Apply current search filter
      if (searchQuery.isNotEmpty) {
        _filterArticles(searchQuery);
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load articles: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _loadMoreArticles() async {
    if (isLoadingMore || !hasMorePages) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      final nextPage = currentPage + 1;
      final response = await _apiService.fetchSavedArticles(page: nextPage);
      final savedArticlesList = response['savedArticles'] as List<dynamic>;
      final pagination = response['pagination'] as Map<String, dynamic>;

      final newArticles = savedArticlesList
          .map((json) => Article.fromJson(json as Map<String, dynamic>))
          .toList();

      setState(() {
        allArticles.addAll(newArticles);
        currentPage = nextPage;
        totalPages = pagination['totalPages'] as int;
        hasMorePages = pagination['hasNextPage'] as bool;
        isLoadingMore = false;
      });

      _updateGroupedArticles();

      // Apply current search filter
      if (searchQuery.isNotEmpty) {
        _filterArticles(searchQuery);
      }
    } catch (e) {
      setState(() {
        isLoadingMore = false;
      });
      // Show error message but don't interrupt the user experience
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('追加の記事の読み込みに失敗しました: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _updateGroupedArticles() {
    // Group all articles by date
    final grouped = <String, List<Article>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekStart = today.subtract(Duration(days: today.weekday - 1));

    for (final article in allArticles) {
      if (article.createdAt != null) {
        final articleDate = DateTime(
          article.createdAt!.year,
          article.createdAt!.month,
          article.createdAt!.day,
        );

        String dateGroup;
        if (articleDate == today) {
          dateGroup = '今日';
        } else if (articleDate == yesterday) {
          dateGroup = '昨日';
        } else if (articleDate.isAfter(weekStart)) {
          dateGroup = '今週';
        } else {
          dateGroup = '以前';
        }

        grouped[dateGroup] ??= [];
        grouped[dateGroup]!.add(article);
      }
    }

    setState(() {
      groupedArticles = grouped;
      filteredGroupedArticles = grouped;
    });
  }

  void _filterArticles(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredGroupedArticles = groupedArticles;
      } else {
        final filteredGroups = <String, List<Article>>{};
        final lowerQuery = query.toLowerCase();

        groupedArticles.forEach((dateGroup, articles) {
          final filteredArticles = articles.where((article) {
            return article.title.toLowerCase().contains(lowerQuery) ||
                (article.url?.toLowerCase().contains(lowerQuery) ?? false) ||
                article.source.toLowerCase().contains(lowerQuery);
          }).toList();

          if (filteredArticles.isNotEmpty) {
            filteredGroups[dateGroup] = filteredArticles;
          }
        });

        filteredGroupedArticles = filteredGroups;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = AppResponsive.isTablet(context);
    final maxWidth = AppResponsive.getMaxWidth(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Saved', style: AppTextStyles.headline2(isTablet)),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            children: [
              // Search bar
              Padding(
                padding: AppResponsive.getPadding(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterArticles,
                    decoration: InputDecoration(
                      hintText: '検索',
                      hintStyle:
                          const TextStyle(color: AppColors.textSecondary),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                      ),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear,
                                color: AppColors.textSecondary,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _filterArticles('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(errorMessage!),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadSavedArticles,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        : filteredGroupedArticles.isEmpty
                            ? SafeArea(
                                bottom: true,
                                child: searchQuery.isNotEmpty
                                    ? _buildSearchEmptyState(isTablet)
                                    : _buildEmptyState(isTablet),
                              )
                            : RefreshIndicator(
                                onRefresh: _loadSavedArticles,
                                child: ListView.builder(
                                  controller: _scrollController,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isTablet ? 24.0 : 16.0,
                                  ),
                                  itemCount: filteredGroupedArticles
                                          .keys
                                          .length +
                                      (isLoadingMore && searchQuery.isEmpty
                                          ? 1
                                          : 0),
                                  itemBuilder: (context, index) {
                                    // Show loading indicator at the bottom
                                    if (index == filteredGroupedArticles.keys.length) {
                                      return Padding(
                                        padding: const EdgeInsets.all(20.0),
                                        child: Center(
                                          child: Column(
                                            children: [
                                              const CircularProgressIndicator(),
                                              const SizedBox(height: 12),
                                              Text(
                                                '記事を読み込み中...',
                                                style: AppTextStyles.bodyMedium(
                                                        isTablet)
                                                    .copyWith(
                                                  color: AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }

                                    final dateGroup = filteredGroupedArticles
                                        .keys
                                        .elementAt(index);
                                    final articles =
                                        filteredGroupedArticles[dateGroup]!;

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Date header
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 16,
                                            bottom: 12,
                                          ),
                                          child: Text(
                                            dateGroup,
                                            style: AppTextStyles.headline3(
                                              isTablet,
                                            ).copyWith(
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ),

                                        // Articles for this date
                                        ...articles.map(
                                          (article) => _buildArticleCard(article),
                                        ),

                                        const SizedBox(height: 8),
                                      ],
                                    );
                                  },
                                ),
                              ),
              ),
            ],
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

  Widget _buildArticleCard(Article article) {
    final isTablet = AppResponsive.isTablet(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppShadows.light,
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => ArticleDetailScreen(article: article),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            // Article icon with gradient
            Container(
              width: isTablet ? 56 : 48,
              height: isTablet ? 56 : 48,
              decoration: BoxDecoration(
                gradient: _getSourceGradient(article.source),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.article_outlined,
                color: Colors.white,
                size: isTablet ? 28 : 24,
              ),
            ),
            const SizedBox(width: 16),

            // Article info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          article.title,
                          style:
                              AppTextStyles.labelMedium(isTablet).copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Read status indicator
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '${article.source} • ${article.timeAgo}',
                        style: AppTextStyles.bodySmall(isTablet),
                      ),
                      const Spacer(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  LinearGradient _getSourceGradient(String source) {
    switch (source) {
      case 'Engadget日本版':
        return AppGradients.accent;
      case 'ITmedia':
        return AppGradients.primary;
      case 'CNET Japan':
        return AppGradients.success;
      case '日経新聞':
        return AppGradients.secondary;
      case '東洋経済オンライン':
        return const LinearGradient(
          colors: [Color(0xFF8B5A3C), Color(0xFF6B4226)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'ナショナルジオグラフィック':
        return const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return AppGradients.primary;
    }
  }

  void _showAddArticleModal(BuildContext context) {
    final isTablet = AppResponsive.isTablet(context);

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
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  prefixIcon:
                      const Icon(Icons.link, color: AppColors.textSecondary),
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
                  hintStyle: const TextStyle(color: AppColors.textSecondary),
                  prefixIcon:
                      const Icon(Icons.title, color: AppColors.textSecondary),
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
          : '';

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

      // 記事リストを再読み込み（新しい記事が最上部に表示されるように）
      _loadSavedArticles();
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
                Icons.bookmark_border,
                size: isTablet ? 80 : 64,
                color: AppColors.primary,
              ),
            ),

            SizedBox(height: isTablet ? 32 : 24),

            // タイトル
            Text(
              '保存された記事はまだありません',
              style: AppTextStyles.headline2(isTablet),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: isTablet ? 24 : 16),

            // サブタイトル
            Text(
              '気になる記事を保存して、いつでも読み返しましょう',
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
                label: const Text('記事を追加'),
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
        'icon': Icons.bookmark_add,
        'title': '記事の保存',
        'description': 'URLを追加して記事を保存・整理',
      },
      {
        'icon': Icons.auto_awesome,
        'title': 'AI要約',
        'description': '保存した記事をAIが自動要約',
      },
      {
        'icon': Icons.search,
        'title': '検索機能',
        'description': '保存した記事をすぐに見つけられる',
      },
      {
        'icon': Icons.folder_outlined,
        'title': '時系列整理',
        'description': '今日・今週・以前で自動分類',
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

  /// 検索結果が空の場合の表示を構築
  Widget _buildSearchEmptyState(bool isTablet) {
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
                color: AppColors.textSecondary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off,
                size: isTablet ? 80 : 64,
                color: AppColors.textSecondary,
              ),
            ),

            SizedBox(height: isTablet ? 32 : 24),

            // タイトル
            Text(
              '検索結果が見つかりません',
              style: AppTextStyles.headline2(isTablet).copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: isTablet ? 24 : 16),

            // サブタイトル
            Text(
              '「$searchQuery」に一致する記事がありません。\n別のキーワードで検索してみてください。',
              style: AppTextStyles.bodyLarge(isTablet).copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: isTablet ? 40 : 32),

            // クリアボタン
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _searchController.clear();
                  _filterArticles('');
                },
                icon: const Icon(Icons.clear),
                label: const Text('検索をクリア'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: BorderSide(
                    color: AppColors.textSecondary.withValues(alpha: 0.3),
                  ),
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
}
