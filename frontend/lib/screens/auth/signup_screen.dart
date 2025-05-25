import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'login_screen.dart';
import '../main_tab_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (_formKey.currentState!.validate() && _agreeToTerms) {
      setState(() {
        _isLoading = true;
      });

      // シミュレートされた登録処理
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
    } else if (!_agreeToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('利用規約とプライバシーポリシーに同意してください'),
          backgroundColor: Colors.red,
        ),
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title:
            kDebugMode
                ? const Text(
                  'Debug Mode',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                )
                : null,
        actions:
            kDebugMode
                ? [
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
                ]
                : null,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 48.0 : 24.0,
              vertical: 24.0,
            ),
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    Text(
                      'アカウント作成',
                      style: TextStyle(
                        fontSize: isTablet ? 32 : 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'summeryme.aiを始めましょう',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isTablet ? 40 : 32),

                    // Name field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: '名前',
                        hintText: '山田太郎',
                        prefixIcon: const Icon(Icons.person_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE8E8E8),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE8E8E8),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF007AFF),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '名前を入力してください';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'メールアドレス',
                        hintText: 'example@email.com',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE8E8E8),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE8E8E8),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF007AFF),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'メールアドレスを入力してください';
                        }
                        if (!RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        ).hasMatch(value)) {
                          return '有効なメールアドレスを入力してください';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'パスワード',
                        hintText: '6文字以上で入力',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE8E8E8),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE8E8E8),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF007AFF),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'パスワードを入力してください';
                        }
                        if (value.length < 6) {
                          return 'パスワードは6文字以上で入力してください';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Confirm password field
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'パスワード確認',
                        hintText: 'パスワードを再入力',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE8E8E8),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFFE8E8E8),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF007AFF),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'パスワード確認を入力してください';
                        }
                        if (value != _passwordController.text) {
                          return 'パスワードが一致しません';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Terms and conditions checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _agreeToTerms,
                          onChanged: (value) {
                            setState(() {
                              _agreeToTerms = value ?? false;
                            });
                          },
                          activeColor: const Color(0xFF007AFF),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _agreeToTerms = !_agreeToTerms;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: RichText(
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: isTablet ? 16 : 14,
                                    color: Colors.black87,
                                  ),
                                  children: const [
                                    TextSpan(text: ''),
                                    TextSpan(
                                      text: '利用規約',
                                      style: TextStyle(
                                        color: Color(0xFF007AFF),
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    TextSpan(text: 'と'),
                                    TextSpan(
                                      text: 'プライバシーポリシー',
                                      style: TextStyle(
                                        color: Color(0xFF007AFF),
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    TextSpan(text: 'に同意します'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Signup button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _signup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007AFF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                                : Text(
                                  'アカウント作成',
                                  style: TextStyle(
                                    fontSize: isTablet ? 18 : 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Divider
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(color: Color(0xFFE8E8E8)),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'または',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: isTablet ? 16 : 14,
                            ),
                          ),
                        ),
                        const Expanded(
                          child: Divider(color: Color(0xFFE8E8E8)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Social signup buttons
                    SizedBox(
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Google 登録
                        },
                        icon: const Icon(Icons.g_mobiledata, size: 24),
                        label: Text(
                          'Googleで登録',
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: const BorderSide(color: Color(0xFFE8E8E8)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Login link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'すでにアカウントをお持ちの方は ',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: isTablet ? 16 : 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'ログイン',
                            style: TextStyle(
                              color: const Color(0xFF007AFF),
                              fontSize: isTablet ? 16 : 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
