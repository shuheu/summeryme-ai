import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'screens/auth/login_screen.dart';
import 'services/audio_player_service.dart';
import 'screens/main_tab_screen.dart';
import 'themes/app_theme.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // テキストレンダリングの品質を向上
  if (!kIsWeb) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
  }

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // プラットフォーム別のフォント取得
  // String get _platformFont {
  //   if (kIsWeb) return 'system-ui';
  //   if (Platform.isMacOS) return '.AppleSystemUIFont';
  //   if (Platform.isIOS) return '.SF UI Text';
  //   if (Platform.isAndroid) return 'Roboto';
  //   if (Platform.isWindows) return 'Segoe UI';
  //   return 'system-ui';
  // }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 音声プレイヤーサービスをアプリ全体で提供
        ChangeNotifierProvider(
          create: (context) => AudioPlayerService(),
        ),
      ],
      child: MaterialApp(
        title: 'summaryme.ai',
        theme: AppTheme.lightTheme.copyWith(
          // プラットフォーム別の最適なフォントを使用
          textTheme: AppTheme.lightTheme.textTheme.apply(
            fontFamily: 'M_PLUS_1p',
          ),
        ),
        home: const AuthWrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

// Widget to handle authentication state
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        // While checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // If user is signed in
        if (snapshot.hasData) {
          return const MainTabScreen();
        }

        // If user is not signed in
        return const LoginScreen();
      },
    );
  }
}
