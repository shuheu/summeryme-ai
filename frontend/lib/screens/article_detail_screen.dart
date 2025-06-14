import 'package:flutter/material.dart';
import '../models/article.dart';
import '../models/saved_article.dart';
import '../services/api_service.dart';
import '../themes/app_theme.dart';

class ArticleDetailScreen extends StatefulWidget {
  const ArticleDetailScreen({super.key, required this.article});
  final Article article;

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  final ApiService _apiService = ApiService();
  SavedArticle? _savedArticle;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadArticleDetail();
  }

  Future<void> _loadArticleDetail() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final savedArticle = await _apiService.fetchSavedArticleById(int.parse(widget.article.id));
      
      setState(() {
        _savedArticle = savedArticle;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '記事の読み込みに失敗しました: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = AppResponsive.isTablet(context);
    final maxWidth = AppResponsive.getMaxWidth(context);

    if (_isLoading) {
      return Scaffold(
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
      return Scaffold(
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
                onPressed: _loadArticleDetail,
                child: const Text('再試行'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Hero image at the top
          SliverAppBar(
            expandedHeight: isTablet ? 350 : 280,
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
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: _getSourceGradient(widget.article.source),
                ),
                child: Center(
                  child: Icon(
                    Icons.article_outlined,
                    size: isTablet ? 120 : 100,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),
          ),

          // Article content
          SliverToBoxAdapter(
            child: Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: maxWidth),
                margin: AppResponsive.getHorizontalPadding(context),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: isTablet ? 32 : 24),

                    // Article metadata
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.article.source,
                            style: AppTextStyles.bodySmall(isTablet).copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          widget.article.timeAgo,
                          style: AppTextStyles.bodySmall(isTablet),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Article title
                    Text(
                      _savedArticle?.title ?? widget.article.title,
                      style: AppTextStyles.headline1(
                        isTablet,
                      ).copyWith(fontSize: isTablet ? 36 : 32),
                    ),
                    const SizedBox(height: 24),

                    // Article summary/intro
                    Container(
                      padding: EdgeInsets.all(isTablet ? 24 : 20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
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
                              Icon(
                                Icons.auto_awesome,
                                color: AppColors.primary,
                                size: isTablet ? 24 : 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'AI Summary',
                                style: AppTextStyles.labelMedium(
                                  isTablet,
                                ).copyWith(color: AppColors.primary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _savedArticle?.savedArticleSummary?.summary ?? widget.article.summary,
                            style: AppTextStyles.bodyMedium(isTablet).copyWith(
                              height: 1.6,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Original article link section
                    Container(
                      padding: EdgeInsets.all(isTablet ? 24 : 20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                        border: Border.all(color: AppColors.border, width: 1),
                        boxShadow: AppShadows.light,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.link,
                                color: AppColors.primary,
                                size: isTablet ? 24 : 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '元記事を読む',
                                style: AppTextStyles.labelMedium(
                                  isTablet,
                                ).copyWith(color: AppColors.primary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // OGP preview
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(
                                isTablet ? 12 : 8,
                              ),
                              border: Border.all(
                                color: AppColors.borderLight,
                                width: 1,
                              ),
                            ),
                            child: InkWell(
                              onTap: () {
                                // TODO: 元記事のURLを開く
                                final url = _savedArticle?.url ?? widget.article.url;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('元記事を開きます: $url')),
                                );
                              },
                              borderRadius: BorderRadius.circular(
                                isTablet ? 12 : 8,
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(isTablet ? 20 : 16),
                                child: Row(
                                  children: [
                                    // OGP image placeholder
                                    Container(
                                      width: isTablet ? 96 : 80,
                                      height: isTablet ? 96 : 80,
                                      decoration: BoxDecoration(
                                        gradient: _getSourceGradient(
                                          widget.article.source,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          isTablet ? 12 : 8,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.article_outlined,
                                        color: Colors.white.withValues(
                                          alpha: 0.8,
                                        ),
                                        size: isTablet ? 40 : 32,
                                      ),
                                    ),
                                    SizedBox(width: isTablet ? 20 : 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _savedArticle?.title ?? widget.article.title,
                                            style: AppTextStyles.bodyMedium(
                                              isTablet,
                                            ).copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            widget.article.source,
                                            style: AppTextStyles.bodySmall(
                                              isTablet,
                                            ).copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.open_in_new,
                                                size: isTablet ? 18 : 16,
                                                color: AppColors.primary,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                '記事を読む',
                                                style: AppTextStyles.bodySmall(
                                                  isTablet,
                                                ).copyWith(
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isTablet ? 64 : 48),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  LinearGradient _getSourceGradient(String source) {
    switch (source) {
      case 'TechCrunch':
        return AppGradients.accent;
      case 'The Verge':
        return AppGradients.primary;
      case 'Wired':
        return AppGradients.success;
      case 'The New York Times':
        return AppGradients.secondary;
      case 'The Economist':
        return const LinearGradient(
          colors: [Color(0xFF8B5A3C), Color(0xFF6B4226)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Nature':
        return const LinearGradient(
          colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return AppGradients.primary;
    }
  }
}
