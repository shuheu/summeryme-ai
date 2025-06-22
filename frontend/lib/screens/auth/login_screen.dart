import 'package:flutter/material.dart';
import '../main_tab_screen.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  Future<void> _googleLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.signInWithGoogle();

      if (!mounted) return;

      if (user != null) {
        // Successfully signed in
        Navigator.pushReplacement(
          context,
          MaterialPageRoute<void>(builder: (context) => const MainTabScreen()),
        );
      } else {
        // User cancelled the sign-in
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ログインに失敗しました: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final maxWidth = isTablet ? 400.0 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 48.0 : 24.0,
              vertical: 24.0,
            ),
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo and title
                  Column(
                    children: [
                      // AI Icon with gradient
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF667eea), // Purple-blue
                              Color(0xFF764ba2), // Deep purple
                              Color(0xFF6B73FF), // Electric blue
                              Color(0xFF000DFF), // Deep blue
                            ],
                            stops: [0.0, 0.3, 0.7, 1.0],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF667eea,
                              ).withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          size: isTablet ? 64 : 48,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // App name with gradient text
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF667eea),
                            Color(0xFF764ba2),
                            Color(0xFF6B73FF),
                            Color(0xFF000DFF),
                          ],
                          stops: [0.0, 0.3, 0.7, 1.0],
                        ).createShader(bounds),
                        child: Text(
                          'summaryme.ai',
                          style: TextStyle(
                            fontSize: isTablet ? 36 : 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Subtitle with gradient
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                        ).createShader(bounds),
                        child: Text(
                          'AIが記事をサマリーして音声で聞ける',
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isTablet ? 64 : 48),

                  // Welcome message
                  Text(
                    'ようこそ！',
                    style: TextStyle(
                      fontSize: isTablet ? 32 : 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Googleアカウントでログインして\n記事の音声サマリーを楽しもう',
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isTablet ? 48 : 40),

                  // Google login button
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE8E8E8)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _googleLogin,
                      icon: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFF007AFF),
                                ),
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Image.network(
                                'https://developers.google.com/identity/images/g-logo.png',
                                height: 20,
                                width: 20,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.g_mobiledata,
                                  size: 24,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                      label: Text(
                        _isLoading ? 'ログイン中...' : 'Googleでログイン',
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isTablet ? 48 : 32),

                  // Features preview
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                          ).createShader(bounds),
                          child: Text(
                            '主な機能',
                            style: TextStyle(
                              fontSize: isTablet ? 20 : 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildFeatureRow(
                          Icons.headphones,
                          '記事を音声で聞ける',
                          isTablet,
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureRow(
                          Icons.auto_awesome,
                          'AIが記事を要約',
                          isTablet,
                        ),
                        const SizedBox(height: 16),
                        _buildFeatureRow(Icons.bookmark, '記事を保存・管理', isTablet),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text, bool isTablet) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF667eea), size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
