import 'package:flutter/material.dart';
import '../models/article.dart';
import '../themes/app_theme.dart';

class DigestDetailScreen extends StatelessWidget {
  const DigestDetailScreen({super.key, required this.article});
  final Article article;

  @override
  Widget build(BuildContext context) {
    final isTablet = AppResponsive.isTablet(context);
    final maxWidth = AppResponsive.getMaxWidth(context);

    return Scaffold(
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
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {},
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: _getSourceGradient(article.source),
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/pattern.png'),
                              repeat: ImageRepeat.repeat,
                            ),
                          ),
                        ),
                      ),
                    ),
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
                                gradient: _getSourceGradient(article.source),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                article.source,
                                style: AppTextStyles.bodySmall(
                                  isTablet,
                                ).copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.schedule,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              article.readTime,
                              style: AppTextStyles.bodySmall(isTablet),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          article.title,
                          style: AppTextStyles.headline2(isTablet),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '2024年12月20日',
                              style: AppTextStyles.bodySmall(
                                isTablet,
                              ).copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.access_time,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Published ${article.timeAgo}',
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
                          article.summary,
                          style: AppTextStyles.bodyLarge(
                            isTablet,
                          ).copyWith(height: 1.7, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Key insights
                  Text(
                    'Key Insights',
                    style: AppTextStyles.headline3(isTablet),
                  ),
                  const SizedBox(height: 16),

                  ..._getKeyInsights().asMap().entries.map((entry) {
                    final index = entry.key;
                    final insight = entry.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppShadows.light,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              gradient: _getSourceGradient(article.source),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: AppTextStyles.labelMedium(
                                  isTablet,
                                ).copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              insight,
                              style: AppTextStyles.bodyMedium(
                                isTablet,
                              ).copyWith(height: 1.6),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

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
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // TODO: 音声再生機能を実装
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('音声サマリーを再生します')),
                              );
                            },
                            icon: const Icon(Icons.headphones, size: 24),
                            label: Text(
                              '音声で聞く',
                              style: AppTextStyles.labelLarge(isTablet),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Duration info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.access_time,
                              size: 16,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '約3分',
                              style: AppTextStyles.bodySmall(
                                isTablet,
                              ).copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 48),
                ],
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

  List<String> _getKeyInsights() {
    return [
      'Remote work technologies have fundamentally changed how teams collaborate across geographical boundaries',
      'AI-powered tools are becoming essential for productivity and decision-making in modern workplaces',
      'Cloud infrastructure enables small companies to access enterprise-level computational resources',
      'Privacy and security considerations are becoming increasingly important as digital adoption accelerates',
      'The future workplace will require continuous learning and adaptation to emerging technologies',
    ];
  }
}
