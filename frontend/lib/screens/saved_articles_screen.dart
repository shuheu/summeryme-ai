import 'package:flutter/material.dart';
import '../models/article.dart';
import '../screens/article_detail_screen.dart';
import '../themes/app_theme.dart';

class SavedArticlesScreen extends StatefulWidget {
  const SavedArticlesScreen({super.key});

  @override
  State<SavedArticlesScreen> createState() => _SavedArticlesScreenState();
}

class _SavedArticlesScreenState extends State<SavedArticlesScreen> {
  // 日付ごとにグルーピングされた記事データ
  final Map<String, List<Article>> groupedArticles = {
    '今日': [
      Article(
        id: '1',
        title: '2024年最新ガジェット：注目の新製品レビュー',
        source: 'Engadget日本版',
        timeAgo: '2時間前',
        summary: '今年発表された革新的なガジェットと最新テクノロジーを詳しく紹介...',
        imageUrl: '',
        readTime: '5分で読める',
        isSaved: true,
        isRead: false,
      ),
      Article(
        id: '2',
        title: '医療AI革命：患者ケアの未来を変える技術',
        source: 'ITmedia',
        timeAgo: '4時間前',
        summary: '人工知能が医療現場にもたらす変革と今後の展望について...',
        imageUrl: '',
        readTime: '7分で読める',
        isSaved: true,
        isRead: true,
      ),
    ],
    '昨日': [
      Article(
        id: '3',
        title: '持続可能エネルギーの未来：再生可能エネルギー最前線',
        source: 'CNET Japan',
        timeAgo: '1日前',
        summary: '環境に優しい次世代エネルギー技術の最新動向を探る...',
        imageUrl: '',
        readTime: '6分で読める',
        isSaved: true,
        isRead: false,
      ),
      Article(
        id: '4',
        title: 'リモートワーク文化の台頭：働き方改革の現在',
        source: '日経新聞',
        timeAgo: '1日前',
        summary: 'テレワークが職場環境に与える影響と企業の対応策...',
        imageUrl: '',
        readTime: '8分で読める',
        isSaved: true,
        isRead: true,
      ),
    ],
    '今週': [
      Article(
        id: '5',
        title: '世界経済動向分析：2024年の市場予測',
        source: '東洋経済オンライン',
        timeAgo: '3日前',
        summary: '現在の世界経済パターンと今後の見通しについての詳細分析...',
        imageUrl: '',
        readTime: '10分で読める',
        isSaved: true,
        isRead: true,
      ),
      Article(
        id: '6',
        title: '気候変動対策2024：最新研究と解決策',
        source: 'ナショナルジオグラフィック',
        timeAgo: '5日前',
        summary: '地球温暖化対策の最新研究成果と効果的な緩和戦略...',
        imageUrl: '',
        readTime: '12分で読める',
        isSaved: true,
        isRead: false,
      ),
    ],
  };

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
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
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
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 24.0 : 16.0,
                  ),
                  itemCount: groupedArticles.keys.length,
                  itemBuilder: (context, index) {
                    final dateGroup = groupedArticles.keys.elementAt(index);
                    final articles = groupedArticles[dateGroup]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date header
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 12),
                          child: Text(
                            dateGroup,
                            style: AppTextStyles.headline3(
                              isTablet,
                            ).copyWith(color: AppColors.textPrimary),
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
            ],
          ),
        ),
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
                            color:
                                article.isRead
                                    ? AppColors.textSecondary
                                    : AppColors.textPrimary,
                            fontWeight:
                                article.isRead
                                    ? FontWeight.normal
                                    : FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Read status indicator
                      if (!article.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
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
                      if (article.isRead)
                        const Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: AppColors.success,
                        ),
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
}
