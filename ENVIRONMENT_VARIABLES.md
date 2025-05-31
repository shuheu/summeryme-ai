# 環境変数設定ガイド

## 📋 概要

このドキュメントでは、Summeryme AI Backendで使用する環境変数について説明します。

## 🔧 基本設定

### Node.js環境
| 変数名 | 説明 | デフォルト値 | 必須 |
|--------|------|-------------|------|
| `NODE_ENV` | 実行環境 | `development` | ❌ |
| `LOG_LEVEL` | ログレベル | `info` | ❌ |
| `PORT` | サーバーポート | `8080` | ❌ |

### データベース設定
| 変数名 | 説明 | デフォルト値 | 必須 |
|--------|------|-------------|------|
| `DATABASE_URL` | データベース接続文字列 | - | ✅ |
| `DB_PASSWORD` | データベースパスワード | - | ✅ (本番) |

### Google Cloud設定
| 変数名 | 説明 | デフォルト値 | 必須 |
|--------|------|-------------|------|
| `GOOGLE_CLOUD_PROJECT` | GCPプロジェクトID | - | ✅ |
| `GCP_REGION` | GCPリージョン | `asia-northeast1` | ❌ |
| `GCP_SERVICE_NAME` | Cloud Runサービス名 | `backend-api` | ❌ |
| `CLOUD_SQL_INSTANCE` | Cloud SQLインスタンス名 | `summeryme-db` | ❌ |

## 🌍 環境別設定

### ローカル開発環境

`.env`ファイルを作成：

```bash
# 基本設定
NODE_ENV=development
LOG_LEVEL=debug
PORT=8080

# データベース設定（Docker Compose使用時）
DATABASE_URL=mysql://root:password@localhost:3306/summeryme_dev

# Google Cloud設定（オプション）
GOOGLE_CLOUD_PROJECT=your-gcp-project-id
GCP_REGION=asia-northeast1
```

### 本番環境（Cloud Run）

Cloud Runで自動設定される変数：
- `PORT` - Cloud Runが自動設定
- `GOOGLE_CLOUD_PROJECT` - 自動設定
- `DB_PASSWORD` - Secret Managerから取得

手動設定が必要な変数：
```bash
NODE_ENV=production
LOG_LEVEL=info
DATABASE_URL=mysql://summeryme_user:${DB_PASSWORD}@localhost:3306/summeryme_production?socket=/cloudsql/your-gcp-project-id:asia-northeast1:summeryme-db
```

## 🔐 Secret Manager設定

### 本番環境でのシークレット管理

```bash
# データベースパスワードをSecret Managerに保存
gcloud secrets create db-password --data-file=password.txt

# Cloud RunでSecret Managerから環境変数として取得
gcloud run services update backend-api \
  --set-secrets="DB_PASSWORD=db-password:latest" \
  --region=asia-northeast1
```

## 🛠️ 設定方法

### 1. ローカル開発

```bash
# .envファイル作成
cp backend_ts/env.example backend_ts/.env

# 必要に応じて値を編集
vim backend_ts/.env
```

### 2. Cloud Run デプロイ

```bash
# 環境変数設定
gcloud run services update backend-api \
  --set-env-vars="NODE_ENV=production,LOG_LEVEL=info" \
  --region=asia-northeast1

# シークレット設定
gcloud run services update backend-api \
  --set-secrets="DB_PASSWORD=db-password:latest" \
  --region=asia-northeast1
```

### 3. GitHub Actions

GitHub Secretsで設定：
- `GCP_SA_KEY` - サービスアカウントキー

GitHub Variablesで設定：
- `GCP_PROJECT_ID` - プロジェクトID
- `GCP_REGION` - リージョン
- `GCP_SERVICE_NAME` - サービス名

## 📊 設定確認

### ローカル環境
```bash
cd backend_ts
pnpm dev
# ログで設定値を確認
```

### 本番環境
```bash
# Cloud Runサービスの環境変数確認
gcloud run services describe backend-api \
  --region=asia-northeast1 \
  --format="export"

# ヘルスチェックで動作確認
curl https://your-service-url.run.app/health
```

## 🚨 トラブルシューティング

### よくある問題

#### 1. データベース接続エラー
```
Error: P1001: Can't reach database server
```
**確認事項**:
- `DATABASE_URL`の設定
- Cloud SQL Proxyの接続設定
- ネットワーク設定

#### 2. 環境変数未設定エラー
```
Error: 必須の環境変数が設定されていません
```
**確認事項**:
- 必須変数の設定確認
- `.env`ファイルの存在確認
- Cloud Runの環境変数設定

#### 3. Secret Manager アクセスエラー
```
Error: Permission denied on secret
```
**確認事項**:
- サービスアカウントの権限
- Secret Managerの設定
- IAM権限の確認

### デバッグコマンド

```bash
# 環境変数一覧表示
printenv | grep -E "(NODE_ENV|DATABASE_URL|GOOGLE_CLOUD)"

# Cloud Run環境変数確認
gcloud run services describe backend-api \
  --region=asia-northeast1 \
  --format="value(spec.template.spec.template.spec.containers[0].env[].name,spec.template.spec.template.spec.containers[0].env[].value)"

# Secret Manager確認
gcloud secrets list
gcloud secrets versions access latest --secret="db-password"
```

## 🔗 関連ドキュメント

- [DEPLOYMENT.md](./DEPLOYMENT.md) - デプロイメントガイド
- [CICD_SETUP.md](./CICD_SETUP.md) - CI/CDセットアップ
- [Google Cloud Secret Manager](https://cloud.google.com/secret-manager/docs)
- [Cloud Run Environment Variables](https://cloud.google.com/run/docs/configuring/environment-variables)