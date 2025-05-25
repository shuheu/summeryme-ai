import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'signup_screen.dart';
import '../main_tab_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _googleLogin() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Google ログイン処理を実装
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainTabScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final maxWidth = isTablet ? 400.0 : double.infinity;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar:
          kDebugMode
              ? AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  'Debug Mode',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainTabScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Skip Auth',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              )
              : null,
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
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF007AFF).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: isTablet ? 80 : 64,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'summeryme.ai',
                          style: TextStyle(
                            fontSize: isTablet ? 32 : 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'AIが記事をサマリーして音声で聞ける',
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: isTablet ? 64 : 48),

                  // Welcome message
                  Text(
                    'ようこそ！',
                    style: TextStyle(
                      fontSize: isTablet ? 28 : 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
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

                  // Google login button - Main feature
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE8E8E8)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _googleLogin,
                      icon:
                          _isLoading
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
                                  errorBuilder:
                                      (context, error, stackTrace) =>
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
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE8E8E8)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '主な機能',
                          style: TextStyle(
                            fontSize: isTablet ? 18 : 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(
                              Icons.headphones,
                              color: Color(0xFF007AFF),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '記事を音声で聞ける',
                                style: TextStyle(
                                  fontSize: isTablet ? 16 : 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.auto_awesome,
                              color: Color(0xFF007AFF),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'AIが記事を要約',
                                style: TextStyle(
                                  fontSize: isTablet ? 16 : 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.bookmark,
                              color: Color(0xFF007AFF),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '記事を保存・管理',
                                style: TextStyle(
                                  fontSize: isTablet ? 16 : 14,
                                  color: Colors.grey[700],
                                ),
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
      ),
    );
  }
}
