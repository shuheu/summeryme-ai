import 'package:flutter/material.dart';
import '../models/article.dart';
import '../screens/digest_detail_screen.dart';
import '../themes/app_theme.dart';

class TodayDigestScreen extends StatefulWidget {
  const TodayDigestScreen({super.key});

  @override
  State<TodayDigestScreen> createState() => _TodayDigestScreenState();
}

class _TodayDigestScreenState extends State<TodayDigestScreen> {
  final _urlController = TextEditingController();
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final maxWidth = isTablet ? 800.0 : double.infinity;

    final List<Article> digestArticles = [
      Article(
        id: '1',
        title: '2024年のテクノロジートレンド：AIと働き方の変化',
        source: '日経新聞',
        timeAgo: '5分で読める',
        summary:
            '人工知能技術の急速な発展により、リモートワークやデジタル変革が加速しています。企業の働き方改革と生産性向上に向けた最新の取り組みを詳しく解説します。',
        imageUrl: '',
        readTime: '5分で読める',
      ),
      Article(
        id: '2',
        title: '医療分野におけるAI活用：診断から治療まで',
        source: 'ITmedia',
        timeAgo: '7分で読める',
        summary:
            '医療現場でのAI導入が進む中、画像診断の精度向上や個別化医療の実現が期待されています。最新の研究成果と実用化に向けた課題について詳しく紹介します。',
        imageUrl: '',
        readTime: '7分で読める',
      ),
      Article(
        id: '3',
        title: 'サイバーセキュリティの最新動向と対策',
        source: 'CNET Japan',
        timeAgo: '6分で読める',
        summary:
            'ランサムウェアやフィッシング攻撃が巧妙化する中、企業や個人が取るべきセキュリティ対策について専門家が解説。最新の脅威情報と効果的な防御策を紹介します。',
        imageUrl: '',
        readTime: '6分で読める',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('For You', style: AppTextStyles.headline2(isTablet)),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: ListView.builder(
            padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
            itemCount: digestArticles.length,
            itemBuilder: (context, index) {
              final article = digestArticles[index];
              return _buildDigestCard(context, article, index == 0);
            },
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

  Widget _buildDigestCard(BuildContext context, Article article, bool isFirst) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.light,
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (context) => DigestDetailScreen(article: article),
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
                        : article.source == 'TechCrunch'
                            ? [const Color(0xFF4A90A4), const Color(0xFF357A8A)]
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

              // Article title
              Text(
                article.title,
                style: const TextStyle(
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
                  const Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '2024年12月20日',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppColors.textSecondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    article.source,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppColors.textSecondary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    article.timeAgo,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Article summary
              Text(
                article.summary,
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
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: AppGradients.primary,
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
                  onPressed: () {
                    // TODO: 音声サマリー再生機能を実装
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('🎧 音声サマリーを再生します'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.headphones,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '音声で聞く',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
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
                        child: const Text(
                          '約3分',
                          style: TextStyle(fontSize: 12, color: Colors.white),
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
                  ),
                ),
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

  void _addArticle(BuildContext context) {
    if (_urlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URLを入力してください'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // TODO: 実際の記事追加処理をここに実装
    // 例: API呼び出し、ローカルストレージへの保存など

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('記事を追加しました'),
        backgroundColor: AppColors.success,
      ),
    );

    _urlController.clear();
    _titleController.clear();
    Navigator.pop(context);
  }
}
