# Summeryme.ai Frontend

Summeryme.aiのフロントエンドアプリケーションです。Flutterを使用してクロスプラットフォーム対応のモバイル・ウェブアプリケーションを開発しています。

## 📱 プロジェクト概要

このプロジェクトは、iOS、Android、Web、Windows、macOS、Linuxに対応したクロスプラットフォームアプリケーションです。

### 技術スタック

- **フレームワーク**: Flutter 3.7.2+
- **言語**: Dart
- **UI**: Material Design
- **対応プラットフォーム**:
  - 📱 iOS
  - 🤖 Android
  - 🌐 Web
  - 🖥️ Windows
  - 🍎 macOS
  - 🐧 Linux

## 🚀 セットアップ

### 前提条件

1. **Flutter SDK** (3.7.2以上)
   ```bash
   flutter --version
   ```

2. **開発環境**
   - iOS開発: Xcode (macOSのみ)
   - Android開発: Android Studio
   - Web開発: Chrome

### インストール手順

1. **リポジトリのクローン**
   ```bash
   git clone <repository-url>
   cd frontend
   ```

2. **依存関係のインストール**
   ```bash
   flutter pub get
   ```

3. **プロジェクトの確認**
   ```bash
   flutter doctor
   ```

## 🏃‍♂️ 実行方法

### 開発環境での実行

```bash
# iOS シミュレーター
flutter run -d ios

# Android エミュレーター
flutter run -d android

# Web ブラウザ
flutter run -d web-server

# デスクトップ (macOS)
flutter run -d macos

# デスクトップ (Windows)
flutter run -d windows

# デスクトップ (Linux)
flutter run -d linux
```

### デバッグモード
```bash
flutter run --debug
```

### リリースモード
```bash
flutter run --release
```

## 🔧 ビルド

### Android APK
```bash
flutter build apk --release
```

### iOS IPA (macOSのみ)
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

### デスクトップ
```bash
# macOS
flutter build macos --release

# Windows
flutter build windows --release

# Linux
flutter build linux --release
```

## 📁 プロジェクト構造

```
frontend/
├── lib/                    # Dartソースコード
│   └── main.dart          # アプリケーションのエントリーポイント
├── android/               # Android固有の設定
├── ios/                   # iOS固有の設定
├── web/                   # Web固有の設定
├── windows/               # Windows固有の設定
├── macos/                 # macOS固有の設定
├── linux/                 # Linux固有の設定
├── test/                  # テストファイル
├── pubspec.yaml          # プロジェクト設定・依存関係
└── README.md             # このファイル
```

## 📦 主要な依存関係

### 本番依存関係
- `flutter`: Flutter SDK
- `cupertino_icons`: iOS スタイルアイコン

### 開発依存関係
- `flutter_test`: テストフレームワーク
- `flutter_lints`: コード品質チェック

## 🧪 テスト

### 単体テスト実行
```bash
flutter test
```

### ウィジェットテスト実行
```bash
flutter test test/widget_test.dart
```

### 統合テスト実行
```bash
flutter drive --target=test_driver/app.dart
```

## 📱 アプリケーション情報

- **アプリ名**: Summeryme.ai
- **パッケージ名**: summeryme.ai
- **バージョン**: 1.0.0+1
- **最小SDK**: Flutter 3.7.2

## 🔍 開発ガイドライン

### コードスタイル
- Dart公式のlintルールに従う
- `flutter_lints`パッケージを使用
- コードフォーマット: `flutter format .`

### 分析
```bash
# コード分析実行
flutter analyze

# 依存関係の確認
flutter pub deps

# 古い依存関係の確認
flutter pub outdated
```

## 🚀 デプロイ

### Android (Google Play Store)
1. `flutter build appbundle --release`
2. Google Play Consoleにアップロード

### iOS (App Store)
1. `flutter build ios --release`
2. Xcodeでアーカイブ
3. App Store Connectにアップロード

### Web
1. `flutter build web --release`
2. `build/web/`フォルダをWebサーバーにデプロイ

## 🐛 トラブルシューティング

### よくある問題

1. **Flutter Doctor エラー**
   ```bash
   flutter doctor --verbose
   ```

2. **依存関係の問題**
   ```bash
   flutter clean
   flutter pub get
   ```

3. **キャッシュクリア**
   ```bash
   flutter clean
   rm -rf ~/.pub-cache
   flutter pub get
   ```

## 📚 参考資料

- [Flutter公式ドキュメント](https://docs.flutter.dev/)
- [Dart言語ガイド](https://dart.dev/guides)
- [Material Design](https://material.io/design)
- [Flutter Cookbook](https://docs.flutter.dev/cookbook)

## 🤝 コントリビューション

1. フォークしてください
2. フィーチャーブランチを作成してください (`git checkout -b feature/AmazingFeature`)
3. 変更をコミットしてください (`git commit -m 'Add some AmazingFeature'`)
4. ブランチにプッシュしてください (`git push origin feature/AmazingFeature`)
5. プルリクエストを開いてください

## 📄 ライセンス

このプロジェクトのライセンス情報については、LICENSEファイルを参照してください。

## 📞 サポート

問題や質問がある場合は、以下の方法でお問い合わせください：

- Issues: GitHubのIssuesページ
- Email: [サポートメールアドレス]
- Documentation: [プロジェクトドキュメント]

---

**注意**: このプロジェクトは開発中です。本番環境での使用前に十分なテストを行ってください。