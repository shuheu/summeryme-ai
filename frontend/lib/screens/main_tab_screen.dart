import 'package:flutter/material.dart';
import 'saved_articles_screen.dart';
import 'today_digest_screen.dart';
import 'settings_screen.dart';
import '../themes/app_theme.dart';

class MainTabScreen extends StatefulWidget {
  const MainTabScreen({super.key});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const TodayDigestScreen(),
    const SavedArticlesScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        color: AppColors.surface, // SafeAreaの背景色を設定
        child: SafeArea(
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(
                top: BorderSide(color: AppColors.border, width: 1),
              ),
            ),
            child: Row(
              children: [
                _buildNavItem(Icons.auto_awesome, 'For You', 0),
                _buildNavItem(Icons.bookmark_outline, 'Saved', 1),
                _buildNavItem(Icons.settings_outlined, '設定', 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: SizedBox(
          height: 44,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSelected)
                ShaderMask(
                  shaderCallback:
                      (bounds) => AppGradients.primary.createShader(bounds),
                  child: Icon(icon, color: Colors.white, size: 22),
                )
              else
                Icon(icon, color: Colors.grey, size: 22),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
