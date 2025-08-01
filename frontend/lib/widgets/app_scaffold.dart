import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../services/audio_player_service.dart';
import 'mini_player.dart';

/// アプリ全体のScaffoldラッパー
/// ミニプレイヤーを含む共通レイアウトを提供
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.bottomNavigationBar,
    this.drawer,
    this.endDrawer,
    this.resizeToAvoidBottomInset,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final Widget? endDrawer;
  final bool? resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerService>(
      builder: (context, audioService, child) {
        // AudioPlayerScreen では ミニプレイヤーを表示しない
        final currentRoute = ModalRoute.of(context)?.settings.name;
        final isAudioPlayerScreen = currentRoute == '/audio_player' ||
            context.widget.runtimeType.toString().contains('AudioPlayerScreen');

        // ミニプレイヤーが表示されるかどうか
        final showMiniPlayer = !isAudioPlayerScreen &&
            (audioService.currentTrack != null ||
                (kIsWeb && audioService.currentPlaylist != null));

        return Scaffold(
          appBar: appBar,
          body: SafeArea(
            bottom: false, // 下部SafeAreaは個別に制御
            child: Column(
              children: [
                // メインコンテンツ
                Expanded(child: body),

                // ミニプレイヤー（AudioPlayerScreen以外で表示）
                if (showMiniPlayer) const MiniPlayer(),
              ],
            ),
          ),
          floatingActionButton: showMiniPlayer && floatingActionButton != null
              ? Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.width > 600
                        ? 90
                        : 80, // タブレット: 90, モバイル: 80
                  ),
                  child: floatingActionButton,
                )
              : floatingActionButton,
          backgroundColor: backgroundColor,
          bottomNavigationBar: bottomNavigationBar,
          drawer: drawer,
          endDrawer: endDrawer,
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        );
      },
    );
  }
}
