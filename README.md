# summeryme-ai

## プロジェクト概要

読みたいのに読めない人が読めるようになるAIサービス

## アーキテクチャ

このプロジェクトは以下の3つの主要コンポーネントで構成されています：

- **バックエンド**: TypeScript + Hono + Prisma + MySQL
- **フロントエンド**: Flutter（クロスプラットフォーム対応）
- **インフラ**: Google Cloud Platform（Terraform管理）

## 技術スタック

### バックエンド (`backend_ts/`)
- **フレームワーク**: [Hono](https://hono.dev/) v4.7.10
- **言語**: TypeScript (ESNext, NodeNext)
- **ORM**: [Prisma](https://www.prisma.io/) v6.8.2
- **データベース**: MySQL 8.0
- **ランタイム**: Node.js v22
- **パッケージマネージャー**: pnpm
- **コンテナ**: Docker + Docker Compose

### フロントエンド (`frontend/`)
- **フレームワーク**: Flutter 3.0+
- **言語**: Dart
- **アーキテクチャ**: クロスプラットフォーム（iOS、Android、Web、Windows、macOS、Linux）
- **UI**: Material Design
- **状態管理**: Provider パターン
- **主要依存関係**:
  - `http: ^1.1.0` - HTTP通信
  - `cached_network_image: ^3.3.0` - 画像キャッシュ
  - `shared_preferences: ^2.2.2` - ローカルストレージ
  - `provider: ^6.1.1` - 状態管理
  - `intl: ^0.19.0` - 国際化対応

### インフラ (`terraform/`)
- **クラウドプロバイダー**: Google Cloud Platform
- **IaC**: Terraform
- **主要サービス**:
  - Cloud Run（アプリケーションホスティング）
  - Cloud SQL（MySQL データベース）
  - Secret Manager（機密情報管理）
  - Artifact Registry（コンテナイメージ保存）

## セットアップ手順

### 前提条件

- Docker & Docker Compose
- Flutter SDK (3.0+)
- Node.js (v22推奨)
- pnpm
- Terraform（インフラ管理用）
- Google Cloud SDK（デプロイ用）

### 1. バックエンドセットアップ

```bash
# backend_tsディレクトリに移動
cd backend_ts

# 依存関係のインストール
pnpm install

# 環境変数の設定
cp .env.example .env
# .envファイルを編集してDATABASE_URLを設定

# Docker Composeでデータベースとアプリケーションを起動
docker compose up -d

# データベースマイグレーション
pnpm migrate

# 開発サーバー起動（ホットリロード）
pnpm dev
```

バックエンドAPIは `http://localhost:8080` でアクセス可能です。

### 2. フロントエンドセットアップ

```bash
# frontendディレクトリに移動
cd frontend

# Flutter依存関係の取得
flutter pub get

# プラットフォーム別実行
# Web
flutter run -d chrome

# モバイル（エミュレータまたは実機が必要）
flutter run

# デスクトップ
flutter run -d macos    # macOS
flutter run -d linux    # Linux
flutter run -d windows  # Windows
```

### 3. インフラセットアップ（本番環境）

```bash
# terraformディレクトリに移動
cd terraform

# Terraformの初期化
make init

# 設定ファイルの作成
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvarsを編集してプロジェクト設定を入力

# 実行計画の確認
make plan

# インフラの作成・更新
make apply

# データベースマイグレーション（本番環境）
make migrate
```

## 開発ワークフロー

### ローカル開発

1. **バックエンド開発**:
   ```bash
   cd backend_ts
   docker compose up -d db  # データベースのみ起動
   pnpm dev                 # 開発サーバー起動
   ```

2. **フロントエンド開発**:
   ```bash
   cd frontend
   flutter run -d chrome    # Web開発
   ```

### コード品質管理

**バックエンド**:
```bash
cd backend_ts
pnpm lint          # ESLintによる静的解析
pnpm format        # Prettierによるコード整形
pnpm format-check  # フォーマットチェック
```

**フロントエンド**:
```bash
cd frontend
flutter analyze    # Dart静的解析
flutter test       # テスト実行
```

## プロジェクト構造

```
summeryme-ai/
├── backend_ts/           # TypeScriptバックエンド
│   ├── src/
│   │   ├── apis/         # APIエンドポイント
│   │   ├── lib/          # ライブラリ・ユーティリティ
│   │   ├── prisma/       # Prismaスキーマ・マイグレーション
│   │   ├── services/     # ビジネスロジック
│   │   └── utils/        # ヘルパー関数
│   ├── scripts/          # 運用スクリプト
│   ├── Dockerfile        # 本番用Dockerファイル
│   ├── Dockerfile.dev    # 開発用Dockerファイル
│   ├── compose.yml       # Docker Compose設定
│   └── package.json      # Node.js依存関係
├── frontend/             # Flutterフロントエンド
│   ├── lib/
│   │   ├── models/       # データモデル
│   │   ├── screens/      # UI画面
│   │   │   └── auth/     # 認証関連画面
│   │   └── themes/       # テーマ・スタイル
│   ├── android/          # Android固有設定
│   ├── ios/              # iOS固有設定
│   ├── web/              # Web固有設定
│   ├── windows/          # Windows固有設定
│   ├── macos/            # macOS固有設定
│   ├── linux/            # Linux固有設定
│   └── pubspec.yaml      # Flutter依存関係
└── terraform/            # インフラ構成（Terraform）
    ├── main.tf           # メイン設定
    ├── providers.tf      # プロバイダー設定
    ├── variables.tf      # 変数定義
    ├── outputs.tf        # 出力値定義
    ├── cloud_run.tf      # Cloud Run設定
    ├── cloud_sql.tf      # Cloud SQL設定
    ├── secrets.tf        # Secret Manager設定
    └── Makefile          # 運用コマンド
```

## API仕様

バックエンドAPIは `http://localhost:8080` で提供されます。

主要エンドポイント：
- `GET /health` - ヘルスチェック
- その他のAPIエンドポイントは `backend_ts/src/apis/` を参照

## デプロイメント

### 本番環境デプロイ

1. **コンテナイメージのビルド・プッシュ**:
   ```bash
   cd backend_ts
   # Google Cloud Buildまたはローカルでビルド
   ```

2. **インフラの更新**:
   ```bash
   cd terraform
   make apply
   ```

3. **データベースマイグレーション**:
   ```bash
   make migrate
   ```

### フロントエンドデプロイ

```bash
cd frontend
# Web版ビルド
flutter build web

# モバイルアプリビルド
flutter build apk      # Android
flutter build ios      # iOS
```

## 貢献方法

1. このリポジトリをフォーク
2. 機能ブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add some amazing feature'`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成




質問や問題がある場合は、GitHubのIssuesページでお知らせください。
