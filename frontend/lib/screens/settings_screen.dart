import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final maxWidth = isTablet ? 800.0 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Settings',
          style: TextStyle(
            color: Colors.black,
            fontSize: isTablet ? 28 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: ListView(
            padding: EdgeInsets.all(isTablet ? 24.0 : 16.0),
            children: [
              // Account info section
              _buildAccountInfo(),
              const SizedBox(height: 24),

              // Account section
              _buildSectionHeader('アカウント'),
              _buildSettingsCard([
                // _buildSettingsItem(
                //   'メールアドレスを変更',
                //   Icons.email_outlined,
                //   onTap: () {},
                //   showArrow: true,
                // ),
                // const Divider(height: 1, color: Color(0xFFE8E8E8)),
                _buildSettingsItem(
                  'ログアウト',
                  Icons.logout_outlined,
                  onTap: () => _handleLogout(context),
                  textColor: const Color(0xFFD32F2F), // 弱めの赤
                ),
              ]),
              const SizedBox(height: 24),

              // Content section
              // _buildSectionHeader('コンテンツ'),
              // _buildSettingsCard([
              //   _buildSettingsItem(
              //     '言語',
              //     Icons.language_outlined,
              //     trailing: const Text(
              //       '日本語',
              //       style: TextStyle(color: Colors.grey, fontSize: 16),
              //     ),
              //   ),
              // ]),
              // const SizedBox(height: 24),

              // Notifications section
              // _buildSectionHeader('通知'),
              // _buildSettingsCard([
              //   _buildSettingsItem(
              //     'プッシュ通知',
              //     Icons.notifications_outlined,
              //     onTap: () {},
              //     showArrow: true,
              //   ),
              // ]),
              // const SizedBox(height: 24),

              // About section
              _buildSectionHeader('アプリについて'),
              _buildSettingsCard([
                _buildSettingsItem(
                  'プライバシーポリシー',
                  Icons.privacy_tip_outlined,
                  onTap: () {},
                ),
                const Divider(height: 1, color: Color(0xFFE8E8E8)),
                _buildSettingsItem(
                  '利用規約',
                  Icons.description_outlined,
                  onTap: () {},
                ),
                const Divider(height: 1, color: Color(0xFFE8E8E8)),
                // _buildSettingsItem('ヘルプセンター', Icons.help_outline, onTap: () {}),
              ]),
              const SizedBox(height: 32),

              // Delete account button
              Center(
                child: TextButton(
                  onPressed: () => _handleDeleteAccount(context),
                  child: const Text(
                    'アカウントを削除',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 48 + MediaQuery.of(context).padding.bottom,
              ),

              // App version info
              Center(
                child: Column(
                  children: [
                    Text(
                      'summaryme.ai',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'バージョン 1.0.0 (ビルド 1)',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '© 2025 summaryme.ai',
                      style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildAccountInfo() {
    final user = _authService.currentUser;
    final displayName = user?.displayName ?? 'ゲストユーザー';
    final email = user?.email ?? 'guest@example.com';
    final photoUrl = user?.photoURL;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFFB74D), Color(0xFFFF8A65)],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF8A65).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: photoUrl != null
                  ? Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                        child: Text('👤', style: TextStyle(fontSize: 28)),
                      ),
                    )
                  : const Center(
                      child: Text('👤', style: TextStyle(fontSize: 28)),
                    ),
            ),
          ),
          const SizedBox(width: 16),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          // Edit button
          // IconButton(
          //   onPressed: () {},
          //   icon: const Icon(Icons.edit_outlined, color: Colors.grey, size: 20),
          // ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    String title,
    IconData icon, {
    Widget? trailing,
    VoidCallback? onTap,
    bool showArrow = false,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.black54, size: 24),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: textColor ?? Colors.black87,
        ),
      ),
      trailing: trailing ??
          (showArrow
              ? const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey,
                  size: 16,
                )
              : null),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('ログアウト'),
          content: const Text('本当にログアウトしますか？'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _authService.signOut();
                // The AuthWrapper will automatically redirect to login screen
              },
              child: const Text(
                'ログアウト',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleDeleteAccount(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('アカウントを削除'),
          content: const Text(
            'アカウントを削除すると、すべてのデータが失われます。\nこの操作は取り消すことができません。\n\n本当に削除しますか？',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _authService.deleteAccount();
                  // The AuthWrapper will automatically redirect to login screen
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('アカウントの削除に失敗しました: ${e.toString()}'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              child: const Text(
                '削除する',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
