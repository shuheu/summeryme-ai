import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'screens/auth/login_screen.dart';
import 'themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // テキストレンダリングの品質を向上
  if (!kIsWeb) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // プラットフォーム別のフォント取得
  String get _platformFont {
    if (kIsWeb) return 'system-ui';
    if (Platform.isMacOS) return '.AppleSystemUIFont';
    if (Platform.isIOS) return '.SF UI Text';
    if (Platform.isAndroid) return 'Roboto';
    if (Platform.isWindows) return 'Segoe UI';
    return 'system-ui';
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'summeryme.ai',
      theme: AppTheme.lightTheme.copyWith(
        // プラットフォーム別の最適なフォントを使用
        textTheme: AppTheme.lightTheme.textTheme.apply(
          fontFamily: _platformFont,
        ),
      ),
      // 常にログイン画面から開始（デバッグモードではスキップボタンが表示される）
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
