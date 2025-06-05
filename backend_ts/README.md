# Summeryme AI Backend

Hono + TypeScript + Prisma + MySQL を使用したバックエンドAPI

## 🚀 クイックスタート

### 本番環境（Cloud Run）

```bash
# ヘルスチェック
curl https://backend-api-422364792408.asia-northeast1.run.app/health

# Worker API（GCP認証必要）
curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
     https://backend-api-422364792408.asia-northeast1.run.app/worker/health
```

### ローカル開発

```bash
# 依存関係のインストール
pnpm install

# 環境変数の設定
cp .env.example .env
# .envファイルを編集してDATABASE_URLを設定

# データベースマイグレーション
pnpm prisma migrate dev

# 開発サーバー起動
pnpm dev
```

## 🏗️ 技術スタック

- **フレームワーク**: [Hono](https://hono.dev/) v4.7.10
- **言語**: TypeScript (ESNext, NodeNext)
- **ORM**: [Prisma](https://www.prisma.io/) v6.8.2
- **データベース**: MySQL 8.0
- **ランタイム**: Node.js v22
- **パッケージマネージャー**: pnpm
- **インフラ**: Google Cloud Run + Cloud SQL

## 🏛️ アーキテクチャ

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Cloud Run     │    │   Cloud SQL     │    │ Secret Manager  │
│   (backend-api) │◄──►│  (summeryme-db) │    │  (db-password)  │
│                 │    │                 │    │                 │
│ - Hono Server   │    │ - MySQL 8.0     │    │ - DB Password   │
│ - Prisma ORM    │    │ - db-f1-micro   │    │ - Secure Store  │
│ - TypeScript    │    │ - 10GB HDD      │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🔌 API エンドポイント

### パブリックエンドポイント

- `GET /` - Hello Hono! メッセージ
- `GET /health` - サーバーヘルスチェック
- `POST /api/auth/login` - Firebase ID トークンでログイン/登録

### Worker エンドポイント（GCP認証必要）

- `POST /worker/process-articles` - 記事要約処理
- `POST /worker/generate-daily-summaries` - 日次要約生成
- `GET /worker/health` - Workerヘルスチェック

## 📁 プロジェクト構成

```
backend_ts/
├── src/
│   ├── index.ts              # メインエントリーポイント
│   ├── routes/
│   │   └── worker.ts         # Worker API ルート
│   └── lib/
│       └── auth.ts           # GCP認証ミドルウェア
├── prisma/
│   ├── schema.prisma         # データベーススキーマ
│   └── migrations/           # マイグレーションファイル
├── Dockerfile                # 本番用Dockerファイル
├── .dockerignore            # Docker除外設定
├── package.json             # 依存関係とスクリプト
├── tsconfig.json            # TypeScript設定
├── .env.example             # 環境変数テンプレート
├── DEPLOYMENT.md            # デプロイメントガイド
└── README.md                # このファイル
```

## 🛠️ 開発手順

### 1. 環境セットアップ

```bash
# Node.js v22のインストール（推奨）
nvm install 22
nvm use 22

# pnpmのインストール
npm install -g pnpm

# 依存関係のインストール
pnpm install
```

### 2. データベース設定

```bash
# 環境変数の設定
cp .env.example .env

# .envファイルを編集
# DATABASE_URL="mysql://user:password@localhost:3306/summeryme_dev"

# Prismaクライアント生成
pnpm prisma generate

# マイグレーション実行
pnpm prisma migrate dev
```

### 3. 開発サーバー起動

```bash
# 開発モード（ホットリロード）
pnpm dev

# 本番ビルド
pnpm build

# 本番サーバー起動
pnpm start
```

### 4. データベース操作

```bash
# Prisma Studio（GUI）
pnpm prisma studio

# マイグレーション作成
pnpm prisma migrate dev --name add_new_table

# データベースリセット
pnpm prisma migrate reset
```

## 🚀 デプロイ方法

### Terraform（推奨）

```bash
# Terraformディレクトリに移動
cd ../terraform/

# 初期セットアップ
make setup

# リソース作成
make plan
make apply

# マイグレーション実行
make migrate
```

### 手動デプロイ

```bash
# Cloud Runにデプロイ
gcloud run deploy backend-api \
  --source . \
  --region=asia-northeast1 \
  --platform=managed
```

詳細な手順は [DEPLOYMENT.md](./DEPLOYMENT.md) を参照してください。

## 🌐 本番環境

### Cloud Run サービス

- **URL**: https://backend-api-422364792408.asia-northeast1.run.app
- **リージョン**: asia-northeast1
- **CPU**: 1 vCPU
- **メモリ**: 1GB
- **インスタンス**: 0-10（自動スケーリング）

### Cloud SQL データベース

- **インスタンス**: summeryme-db
- **バージョン**: MySQL 8.0
- **ティア**: db-f1-micro
- **ストレージ**: 10GB HDD
- **リージョン**: asia-northeast1-b

## 🔐 セキュリティ

### 認証・認可

- **Worker API**: GCP Identity Token認証
- **データベース**: Cloud SQL Proxy + Secret Manager
- **権限**: 最小権限の原則

### 機密情報管理

- **パスワード**: Google Secret Manager
- **環境変数**: Cloud Run環境変数
- **接続**: Cloud SQL Proxy（Unix Socket）

## 💰 コスト情報

### 月額概算（軽微な使用）

- **Cloud SQL**: $7-10（db-f1-micro）
- **Cloud Run**: $0-5（従量課金）
- **Secret Manager**: $0.06（10,000アクセス）
- **合計**: 約$7-15/月

### コスト最適化

- 最小インスタンス数: 0（アイドル時無料）
- HDDストレージ使用
- 自動スケーリング
- リージョン最適化

## 📊 監視・ログ

### ログ確認

```bash
# Cloud Runログ
gcloud logging read "resource.type=cloud_run_revision" --limit=20

# アプリケーションログ
gcloud logging read "resource.labels.service_name=backend-api" --limit=20
```

### メトリクス

- レスポンス時間
- エラー率
- インスタンス数
- データベース接続数

## 🔧 トラブルシューティング

### よくある問題

1. **データベース接続エラー**: Cloud SQL Proxy設定確認
2. **認証エラー**: GCP権限設定確認
3. **デプロイエラー**: Dockerfileとビルドログ確認

### デバッグ

```bash
# ローカルでのデバッグ
pnpm dev

# 本番ログ確認
gcloud logging tail "resource.labels.service_name=backend-api"

# データベース接続テスト
pnpm prisma db pull
```

## 📚 参考資料

- [Hono Documentation](https://hono.dev/)
- [Prisma Documentation](https://www.prisma.io/docs)
- [Google Cloud Run](https://cloud.google.com/run/docs)
- [Google Cloud SQL](https://cloud.google.com/sql/docs)

## 🤝 開発ガイドライン

### コーディング規約

- TypeScript Strict Mode
- ESLint + Prettier
- 関数型プログラミング推奨
- エラーハンドリング必須

### Git ワークフロー

- feature ブランチでの開発
- Pull Request レビュー
- main ブランチへの自動デプロイ

---

**最終更新**: 2025-05-31
**バージョン**: 1.0.0
