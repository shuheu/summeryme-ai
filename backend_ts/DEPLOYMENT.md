# Summeryme AI Backend デプロイメントガイド

## 📋 概要

このドキュメントは、Summeryme AI BackendのGoogle Cloud Platform (GCP) へのデプロイメント構成と設定手順をまとめたものです。

## 🏗️ アーキテクチャ構成

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

## 🔧 技術スタック

### Backend (Cloud Run)

- **フレームワーク**: Hono v4.7.10
- **言語**: TypeScript (ESNext, NodeNext)
- **ORM**: Prisma v6.8.2
- **ランタイム**: Node.js v22
- **パッケージマネージャー**: pnpm

### Database (Cloud SQL)

- **データベース**: MySQL 8.0
- **インスタンスタイプ**: db-f1-micro (コスト最適化)
- **ストレージ**: 10GB HDD
- **リージョン**: asia-northeast1-b

### Infrastructure

- **プラットフォーム**: Google Cloud Platform
- **プロジェクトID**: your-gcp-project-id
- **プロジェクト名**: summeryme-ai
- **IaC**: Terraform (推奨)

## 📊 リソース詳細

### Cloud Run サービス

```yaml
サービス名: backend-api
URL: https://backend-api-422364792408.asia-northeast1.run.app
リージョン: asia-northeast1
リビジョン: backend-api-00010-xp8

リソース設定:
  CPU: 1000m (1 vCPU)
  メモリ: 1Gi
  同時実行数: 100
  最小インスタンス: 0
  最大インスタンス: 10
  タイムアウト: 900秒 (15分)

環境変数:
  NODE_ENV: production
  LOG_LEVEL: info
  DATABASE_URL: mysql://summeryme_user:${DB_PASSWORD}@localhost:3306/summeryme_production?socket=/cloudsql/your-gcp-project-id:asia-northeast1:summeryme-db

シークレット:
  DB_PASSWORD: db-password:latest (Secret Manager)

Cloud SQL接続:
  インスタンス: your-gcp-project-id:asia-northeast1:summeryme-db
  接続方式: Cloud SQL Proxy (Unix Socket)
```

### Cloud SQL インスタンス

```yaml
インスタンス名: summeryme-db
データベースバージョン: MYSQL_8_0
ティア: db-f1-micro
リージョン: asia-northeast1-b
ゾーン: asia-northeast1-b
パブリックIP: 35.243.114.128
状態: RUNNABLE

ストレージ設定:
  タイプ: HDD
  サイズ: 10GB
  自動増加: 無効

データベース:
  名前: summeryme_production
  文字セット: utf8mb4
  照合順序: utf8mb4_unicode_ci

ユーザー:
  名前: summeryme_user
  パスワード: Secret Managerで管理
```

## 🔐 セキュリティ設定

### IAM権限

```yaml
サービスアカウント: 422364792408-compute@developer.gserviceaccount.com

付与された権限:
  - roles/cloudsql.client (Cloud SQL接続)
  - roles/secretmanager.secretAccessor (Secret Manager読み取り)
  - roles/editor (基本編集権限)
```

### Secret Manager

```yaml
シークレット名: db-password
バージョン: 1
値: データベースパスワード (Base64エンコード済み)
アクセス権限: Cloud Runサービスアカウントのみ
```

## 🚀 API エンドポイント

### パブリックエンドポイント

```
GET  /                 - Hello Hono! メッセージ
GET  /health          - サーバーヘルスチェック
```

### Worker エンドポイント (GCP認証必要)

```
POST /worker/process-articles           - 記事要約処理
POST /worker/generate-daily-summaries   - 日次要約生成
GET  /worker/health                     - Workerヘルスチェック
```

## 📁 データベーススキーマ

### テーブル構成

```sql
-- ユーザー管理
users (
  id: INT PRIMARY KEY AUTO_INCREMENT,
  uid: VARCHAR(255) UNIQUE,
  name: VARCHAR(255),
  created_at: DATETIME,
  updated_at: DATETIME
)

-- 保存記事
saved_articles (
  id: INT PRIMARY KEY AUTO_INCREMENT,
  user_id: INT,
  title: VARCHAR(255),
  url: VARCHAR(1024),
  created_at: DATETIME,
  updated_at: DATETIME,
  INDEX(user_id),
  INDEX(created_at)
)

-- 記事要約
saved_article_summaries (
  id: INT PRIMARY KEY AUTO_INCREMENT,
  saved_article_id: INT UNIQUE,
  summary: TEXT,
  created_at: DATETIME,
  updated_at: DATETIME
)

-- 日次要約
user_daily_summaries (
  id: INT PRIMARY KEY AUTO_INCREMENT,
  user_id: INT,
  summary: TEXT,
  audio_url: VARCHAR(255),
  generated_date: DATE,
  created_at: DATETIME,
  updated_at: DATETIME,
  INDEX(user_id),
  INDEX(created_at),
  UNIQUE(user_id, generated_date)
)
```

## 🛠️ デプロイメント手順

### 方法1: Terraform (推奨)

Terraformを使用したInfrastructure as Codeによるデプロイメント

#### 1. 前提条件

```bash
# Terraformのインストール
brew install terraform

# Google Cloud SDKの認証
gcloud auth login
gcloud auth application-default login
gcloud config set project your-gcp-project-id
```

#### 2. Terraformセットアップ

```bash
# Terraformディレクトリに移動
cd terraform/

# 初期セットアップ
make setup

# 設定ファイルの確認・編集
vim terraform.tfvars
```

#### 3. 新規デプロイ vs 既存リソースのインポート

##### 🆕 新規デプロイの場合

```bash
# 実行計画の確認
make plan

# リソースの作成
make apply

# マイグレーション実行
make migrate
```

##### 🔄 既存リソースがある場合（インポート）

```bash
# 1. 既存リソースの確認
make import-check

# 2. 一括インポート実行
make import-all

# 3. 設定差分確認
make plan

# 4. 設定同期（必要に応じて）
make apply

# 5. マイグレーション実行（必要に応じて）
make migrate
```

#### 4. インポート詳細手順

##### 📋 インポート前チェック

```bash
# 現在のGCPリソース状況を確認
make project-info

# インポート可能なリソースを詳細確認
make import-check
```

出力例：

```
=== インポート可能なリソースをチェック中 ===
プロジェクト: numeric-skill-460414-d3

Cloud Runサービス:
NAME         URL
backend-api  https://backend-api-y3l3dqp67q-an.a.run.app

Cloud SQLインスタンス:
NAME          DATABASE_VERSION  REGION
summeryme-db  MYSQL_8_0         asia-northeast1

Secret Manager:
NAME
db-password
```

##### 🚀 一括インポート実行

```bash
# 全リソースを自動的にインポート
make import-all
```

このコマンドは以下を順次実行：

1. **Google Cloud APIs** (8個) - 必要なAPIサービスを有効化
2. **Secret Manager** - データベースパスワード管理
3. **Cloud SQL** - インスタンス、データベース、ユーザー
4. **サービスアカウント** - Cloud Run、GitHub Actions用
5. **Cloud Run** - アプリケーションサービスとIAM設定

##### 🔧 個別インポート（必要に応じて）

```bash
# 特定リソースのみインポート
make import-cloud-run      # Cloud Runサービス
make import-cloud-sql      # Cloud SQLインスタンス
make import-secret         # Secret Manager
make import-apis           # Google Cloud APIs
```

##### 📊 インポート結果確認

```bash
# Terraformで管理されているリソース一覧
make state

# 設定差分の確認
make plan

# 必要に応じて設定を同期
make apply
```

#### 5. 既存リソースのインポート（初回のみ）

```bash
# 既存リソースをTerraform管理下に移行
make import-cloud-run
make import-cloud-sql
make import-secret
```

### 方法2: 手動デプロイ

#### 1. 前提条件

```bash
# Google Cloud SDKのインストール
brew install --cask google-cloud-sdk

# 認証
gcloud auth login
gcloud config set project your-gcp-project-id
```

#### 2. 必要なAPIの有効化

```bash
gcloud services enable run.googleapis.com
gcloud services enable sqladmin.googleapis.com
gcloud services enable secretmanager.googleapis.com
gcloud services enable cloudbuild.googleapis.com
gcloud services enable containerregistry.googleapis.com
```

#### 3. Cloud SQLインスタンス作成

```bash
# インスタンス作成
gcloud sql instances create summeryme-db \
  --database-version=MYSQL_8_0 \
  --tier=db-f1-micro \
  --region=asia-northeast1 \
  --storage-type=HDD \
  --storage-size=10GB \
  --no-storage-auto-increase \
  --maintenance-window-day=SUN \
  --maintenance-window-hour=04

# データベース作成
gcloud sql databases create summeryme_production --instance=summeryme-db

# ユーザー作成
export DB_PASSWORD=$(openssl rand -base64 32)
gcloud sql users create summeryme_user \
  --instance=summeryme-db \
  --password="$DB_PASSWORD"
```

#### 4. Secret Manager設定

```bash
# パスワードをSecret Managerに保存
echo -n "$DB_PASSWORD" | gcloud secrets create db-password --data-file=-
```

#### 5. Cloud Runデプロイ

```bash
# アプリケーションデプロイ
gcloud run deploy backend-api \
  --source . \
  --region=asia-northeast1 \
  --platform=managed \
  --allow-unauthenticated

# リソース設定
gcloud run services update backend-api \
  --region=asia-northeast1 \
  --memory=1Gi \
  --cpu=1 \
  --concurrency=100 \
  --min-instances=0 \
  --max-instances=10 \
  --timeout=900

# Cloud SQL接続設定
gcloud run services update backend-api \
  --region=asia-northeast1 \
  --set-cloudsql-instances=your-gcp-project-id:asia-northeast1:summeryme-db \
  --set-secrets="DB_PASSWORD=db-password:latest" \
  --set-env-vars="DATABASE_URL=mysql://summeryme_user:\${DB_PASSWORD}@localhost:3306/summeryme_production?socket=/cloudsql/your-gcp-project-id:asia-northeast1:summeryme-db"
```

#### 6. データベースマイグレーション

```bash
# マイグレーションジョブ作成
gcloud run jobs create migrate-job \
  --image=asia-northeast1-docker.pkg.dev/your-gcp-project-id/cloud-run-source-deploy/backend-api \
  --region=asia-northeast1 \
  --set-cloudsql-instances=your-gcp-project-id:asia-northeast1:summeryme-db \
  --set-secrets="DB_PASSWORD=db-password:latest" \
  --set-env-vars="DATABASE_URL=mysql://summeryme_user:\${DB_PASSWORD}@localhost:3306/summeryme_production?socket=/cloudsql/your-gcp-project-id:asia-northeast1:summeryme-db" \
  --command="npx" \
  --args="prisma,migrate,deploy"

# マイグレーション実行
gcloud run jobs execute migrate-job --region=asia-northeast1
```

#### 7. IAM権限設定

```bash
# Cloud SQL Client権限
gcloud projects add-iam-policy-binding your-gcp-project-id \
  --member="serviceAccount:422364792408-compute@developer.gserviceaccount.com" \
  --role="roles/cloudsql.client"

# Secret Manager権限
gcloud projects add-iam-policy-binding your-gcp-project-id \
  --member="serviceAccount:422364792408-compute@developer.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"
```

## 🔍 動作確認

### インポート後の確認手順

```bash
# 1. リソース状態確認
make state

# 2. 設定差分確認
make plan

# 3. サービス動作確認
curl https://backend-api-422364792408.asia-northeast1.run.app/health

# 4. データベース接続確認
make migrate

# 5. 全体状況確認
make project-info
```

### ヘルスチェック

```bash
curl https://backend-api-422364792408.asia-northeast1.run.app/health
```

期待されるレスポンス:

```json
{
  "status": "healthy",
  "timestamp": "2025-05-31T06:49:04.389Z",
  "environment": "production"
}
```

### ログ確認

```bash
# Cloud Runログ
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=backend-api" --limit=20

# Cloud SQLログ
gcloud logging read "resource.type=cloudsql_database" --limit=20
```

## 💰 コスト最適化

### 現在の設定

- **Cloud SQL**: db-f1-micro (月額約$7-10)
- **Cloud Run**: 従量課金 (リクエスト数とCPU時間に基づく)
- **Secret Manager**: 月額約$0.06 (10,000アクセスまで)

### コスト削減のポイント

1. **最小インスタンス数**: 0 (アイドル時は課金なし)
2. **HDDストレージ**: SSDより安価
3. **自動スケーリング**: トラフィックに応じて自動調整
4. **リージョン選択**: asia-northeast1 (東京) で低レイテンシ

## 🚨 監視・アラート

### 推奨監視項目

- Cloud Runインスタンス数
- レスポンス時間
- エラー率
- Cloud SQL接続数
- データベースCPU使用率

### ログ分析

- 構造化ログ出力
- Cloud Loggingでの集約
- エラートラッキング

## 🔄 CI/CD パイプライン

### GitHub Actions設定例

```yaml
name: Deploy to Cloud Run
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: google-github-actions/setup-gcloud@v1
        with:
          service_account_key: ${{ secrets.GCP_SA_KEY }}
          project_id: your-gcp-project-id
      - run: |
          gcloud run deploy backend-api \
            --source . \
            --region=asia-northeast1
```

### Terraform CI/CD

```yaml
name: Terraform CI/CD
on:
  push:
    branches: [main]
    paths: ['terraform/**']

jobs:
  terraform:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: terraform
    steps:
      - uses: actions/checkout@v3
      - uses: hashicorp/setup-terraform@v2
      - name: Terraform Init
        run: terraform init
      - name: Terraform Plan
        run: terraform plan
      - name: Terraform Apply
        if: github.ref == 'refs/heads/main'
        run: terraform apply -auto-approve
```

## 📚 参考資料

- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Cloud SQL Documentation](https://cloud.google.com/sql/docs)
- [Prisma Documentation](https://www.prisma.io/docs)
- [Hono Documentation](https://hono.dev/)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)

## 🆘 トラブルシューティング

### よくある問題

1. **インポートエラー**

   ```bash
   # リソースが既に管理されている場合
   terraform state rm google_cloud_run_v2_service.main
   make import-cloud-run

   # 設定差分が大きい場合
   make plan
   make apply
   ```

2. **データベース接続エラー**

   - Cloud SQL Proxyの設定確認
   - IAM権限の確認
   - 環境変数の確認

3. **デプロイエラー**

   - Dockerfileの構文確認
   - 依存関係の確認
   - ビルドログの確認

4. **パフォーマンス問題**

   - メモリ・CPU設定の調整
   - 同時実行数の調整
   - データベースクエリの最適化

5. **Terraform関連**
   - State ファイルの競合
   - プロバイダーバージョンの不整合
   - リソースのインポートエラー

### インポート関連のトラブルシューティング

#### リソースが見つからない場合

```bash
# リソースの存在確認
gcloud run services list --region=asia-northeast1
gcloud sql instances list
gcloud secrets list

# 必要に応じて手動作成
gcloud run deploy backend-api --source . --region=asia-northeast1
```

#### 設定差分が大きい場合

```bash
# 段階的に適用
make apply-cloud-run
make apply-cloud-sql

# または一括適用
make apply
```

#### パスワード不整合

```bash
# 既存パスワードの確認
gcloud secrets versions access latest --secret="db-password"

# Terraformの設定を既存値に合わせる
# または新しいパスワードで統一
```

### サポート連絡先

- 開発チーム: [連絡先情報]
- GCPサポート: [サポートケース作成]

---

**最終更新**: 2025-05-31
**バージョン**: 1.0.0
**作成者**: AI Assistant

### 基本情報

- **プロジェクトID**: your-gcp-project-id
- **リージョン**: asia-northeast1-b
- **環境**: 本番環境

## 🐳 Docker イメージビルド方式

### GitHub Actions での自動デプロイ

新しいワークフローでは以下の手順でデプロイされます：

1. **ソースコードのビルド**

   ```bash
   pnpm install --frozen-lockfile
   pnpm prisma generate
   pnpm build
   ```

2. **Dockerイメージのビルド**

   ```bash
   docker build -t asia-northeast1-docker.pkg.dev/PROJECT_ID/backend/backend-api:COMMIT_SHA .
   docker build -t asia-northeast1-docker.pkg.dev/PROJECT_ID/backend/backend-api:latest .
   ```

3. **Artifact Registryへのプッシュ**

   ```bash
   docker push asia-northeast1-docker.pkg.dev/PROJECT_ID/backend/backend-api:COMMIT_SHA
   docker push asia-northeast1-docker.pkg.dev/PROJECT_ID/backend/backend-api:latest
   ```

4. **Cloud Runへのデプロイ**
   ```bash
   gcloud run deploy backend-api \
     --image=asia-northeast1-docker.pkg.dev/PROJECT_ID/backend/backend-api:COMMIT_SHA \
     --platform=managed \
     --region=asia-northeast1
   ```

### ローカルでのDockerビルド

```bash
# イメージビルド
docker build -t backend-api .

# ローカル実行
docker run -p 8080:8080 \
  -e DATABASE_URL="mysql://user:password@host:3306/database" \
  backend-api

# Artifact Registryへのプッシュ（認証済みの場合）
docker tag backend-api asia-northeast1-docker.pkg.dev/PROJECT_ID/backend/backend-api:v1.0.0
docker push asia-northeast1-docker.pkg.dev/PROJECT_ID/backend/backend-api:v1.0.0
```

## 📋 Terraform での管理
