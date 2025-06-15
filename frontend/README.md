# Summaryme.ai Frontend

Summaryme.aiのフロントエンドアプリケーションです。Flutterを使用してクロスプラットフォーム対応のモバイル・ウェブアプリケーションを開発しています。

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

### 全体構造
```
frontend/
├── lib/                    # Dartソースコード
├── android/               # Android固有の設定
├── ios/                   # iOS固有の設定
├── web/                   # Web固有の設定
├── windows/               # Windows固有の設定
├── macos/                 # macOS固有の設定
├── linux/                 # Linux固有の設定
├── test/                  # テストファイル
├── build/                 # ビルド成果物
├── pubspec.yaml          # プロジェクト設定・依存関係
└── README.md             # このファイル
```

### lib/ディレクトリの詳細構造
```
lib/
├── main.dart              # アプリのエントリーポイント
├── models/                # データモデル
│   └── article.dart       # 記事データモデル
└── screens/               # UI画面
    ├── auth/              # 認証関連画面
    │   ├── login_screen.dart      # ログイン画面
    │   └── signup_screen.dart     # 会員登録画面
    ├── main_tab_screen.dart       # メインタブナビゲーション
    ├── article_detail_screen.dart # 記事詳細画面
    ├── saved_articles_screen.dart # 保存済み記事一覧
    ├── today_digest_screen.dart   # 今日のダイジェスト
    └── settings_screen.dart       # 設定画面
```

### ディレクトリ構造のルール

#### **1. 機能別分類**
- **`models/`**: データ構造とビジネスロジック
- **`screens/`**: UI画面とウィジェット
- **`auth/`**: 認証関連の画面をサブディレクトリで分離

#### **2. ファイル命名規則**
- **スネークケース**: `main_tab_screen.dart`
- **機能を表す接尾辞**: `_screen.dart`, `_model.dart`
- **明確で説明的な名前**: `article_detail_screen.dart`

#### **3. 将来の拡張構造**
プロジェクトの成長に合わせて以下の構造への拡張を推奨：

```
lib/
├── main.dart
├── models/                # データモデル
│   ├── article.dart
│   ├── user.dart
│   └── subscription.dart
├── screens/               # UI画面
│   ├── auth/
│   ├── article/
│   ├── settings/
│   └── home/
├── widgets/               # 再利用可能なウィジェット
│   ├── common/
│   ├── article_card.dart
│   └── custom_button.dart
├── services/              # API通信・外部サービス
│   ├── api_service.dart
│   ├── auth_service.dart
│   └── storage_service.dart
├── utils/                 # ユーティリティ関数
│   ├── constants.dart
│   ├── helpers.dart
│   └── validators.dart
├── providers/             # 状態管理
│   ├── auth_provider.dart
│   └── article_provider.dart
└── themes/                # テーマとスタイル
    ├── app_theme.dart
    └── colors.dart
```

#### **4. 現在の構造の特徴**
- ✅ **シンプルで理解しやすい**
- ✅ **機能別に整理されている**
- ✅ **認証機能が適切に分離されている**
- ✅ **Flutterの標準的な構造に従っている**
- ✅ **小〜中規模アプリに適している**

## 📦 主要な依存関係

### 本番依存関係
- `flutter`: Flutter SDK
- `cupertino_icons`: iOS スタイルアイコン
- `http`: HTTP通信ライブラリ
- `cached_network_image`: ネットワーク画像キャッシュ
- `shared_preferences`: ローカルデータ保存
- `provider`: 状態管理
- `intl`: 国際化・日付フォーマット

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

- **アプリ名**: summeryme.ai
- **パッケージ名**: summeryme.ai
- **バージョン**: 1.0.0+1
- **最小SDK**: Flutter 3.7.2
- **アプリタイプ**: 記事リーダー・ダイジェストアプリ
- **主要機能**:
  - 📰 記事閲覧・保存
  - 📊 今日のダイジェスト
  - 🔐 ユーザー認証
  - ⚙️ 設定管理
  - 📱 レスポンシブデザイン

## 🔍 開発ガイドライン

### コードスタイル

- Dart公式のlintルールに従う
- `flutter_lints`パッケージを使用
- コードフォーマット: `dart format .`

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

## 🚀 Firebase Hosting デプロイガイド

このプロジェクトは Flutter Web アプリケーションで、Firebase Hosting を使用して Google Cloud 環境にデプロイされます。

## 📋 前提条件

### 必要なツール

- Flutter SDK 3.7.2+
- Firebase CLI
- Node.js 16+
- Git

#### Firebase ログイン

```bash
firebase login
```

## 🔧 プロジェクト設定

### 1. Firebase プロジェクトの初期化

```bash
cd frontend
firebase init hosting
```

### 2. Flutter 依存関係のインストール

```bash
flutter pub get
```

## 🚀 デプロイ方法

### 方法1: スクリプトを使用（推奨）

#### 本番環境

```bash
cd frontend
./scripts/deploy.sh production
```

## 🔄 GitHub Actions CI/CD

### 自動デプロイの設定

1. **Firebase Service Account の作成**

```bash
firebase projects:list
firebase init hosting:github
```

2. **GitHub Secrets の設定**
   - `FIREBASE_SERVICE_ACCOUNT_<project_id>`: Firebase サービスアカウントの JSON キー

### デプロイ トリガー

- **プルリクエスト**: プレビュー環境に自動デプロイ
- **develop ブランチ**: ステージング環境に自動デプロイ
- **main ブランチ**: 本番環境に自動デプロイ

## 🌐 デプロイ環境

### 本番環境

- **ブランチ**: `master`
- **自動デプロイ**: ✅

### プレビュー環境

- **URL**: 動的生成（PRごと）
- **ブランチ**: プルリクエスト
- **自動デプロイ**: ✅

## 📊 ビルド設定

### Web レンダラー

- **CanvasKit**: 高性能レンダリング（デフォルト）
- **HTML**: 軽量だが機能制限あり

## 🔧 トラブルシューティング

### よくある問題

#### 1. Firebase CLI ログイン問題
```bash
firebase logout
firebase login --reauth
```

#### 2. ビルドエラー
```bash
flutter clean
flutter pub get
flutter build web
```

#### 3. デプロイ権限エラー
```bash
firebase projects:list
firebase use <project_id>
```

### ログ確認

```bash
# Firebase Hosting ログ
firebase hosting:sites:list

# GitHub Actions ログ
# GitHubのActions タブから確認
```

### コマンド一覧

```bash
# ビルド
flutter build web

# デプロイ状況確認
firebase hosting:sites:list

# ログ確認
firebase hosting:sites:get <project_id>
```