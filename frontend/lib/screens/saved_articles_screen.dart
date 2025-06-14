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
  Map<String, List<Article>> groupedArticles = {};
  bool isLoading = true;
  String? errorMessage;
  int currentPage = 1;
  int totalPages = 1;
  bool hasMorePages = false;

  @override
  void initState() {
    super.initState();
    _loadSavedArticles();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedArticles() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _apiService.fetchSavedArticles(page: currentPage);
      final savedArticlesList = response['savedArticles'] as List<dynamic>;
      final pagination = response['pagination'] as Map<String, dynamic>;

      final articles = savedArticlesList
          .map((json) => Article.fromJson(json as Map<String, dynamic>))
          .toList();

      // Group articles by date
      final grouped = <String, List<Article>>{};
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final weekStart = today.subtract(Duration(days: today.weekday - 1));

      for (final article in articles) {
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
        totalPages = pagination['totalPages'] as int;
        hasMorePages = pagination['hasNextPage'] as bool;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load articles: $e';
        isLoading = false;
      });
    }
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
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: '検索',
                      hintStyle: TextStyle(color: AppColors.textSecondary),
                      prefixIcon: Icon(
                        Icons.search,
                        color: AppColors.textSecondary,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
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
                        : groupedArticles.isEmpty
                            ? const Center(
                                child: Text(
                                  '保存された記事がありません',
                                  style:
                                      TextStyle(color: AppColors.textSecondary),
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _loadSavedArticles,
                                child: ListView.builder(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isTablet ? 24.0 : 16.0,
                                  ),
                                  itemCount: groupedArticles.keys.length,
                                  itemBuilder: (context, index) {
                                    final dateGroup =
                                        groupedArticles.keys.elementAt(index);
                                    final articles =
                                        groupedArticles[dateGroup]!;

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Date header
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 16, bottom: 12),
                                          child: Text(
                                            dateGroup,
                                            style: AppTextStyles.headline3(
                                              isTablet,
                                            ).copyWith(
                                                color: AppColors.textPrimary),
                                          ),
                                        ),

                                        // Articles for this date
                                        ...articles.map(
                                          (article) =>
                                              _buildArticleCard(article),
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
                          style: AppTextStyles.labelMedium(isTablet).copyWith(
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

      // 記事リストを再読み込み
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
}
