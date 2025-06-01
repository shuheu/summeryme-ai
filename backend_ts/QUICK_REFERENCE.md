# Summeryme AI Backend - クイックリファレンス

## 🚀 本番環境情報

### サービスURL

```
https://backend-api-422364792408.asia-northeast1.run.app
```

## 📋 基本情報

### 本番環境

- **プロジェクトID**: `your-gcp-project-id`
- **リージョン**: `asia-northeast1`
- **Cloud Runサービス**: `backend-api`
- **Cloud SQLインスタンス**: `summeryme-db`
- **データベース**: `summeryme_production`

## 🔧 よく使うコマンド

### Terraform操作

```bash
# Terraformディレクトリに移動
cd terraform/

# 初期セットアップ
make setup

# 実行計画確認
make plan

# リソース作成・更新
make apply

# リソース削除
make destroy

# 設定検証・フォーマット
make check

# 出力値表示
make output

# リソース状態表示
make state
```

### 既存リソースのインポート

```bash
# インポート可能なリソース確認
make import-check

# 一括インポート（推奨）
make import-all

# 個別インポート
make import-cloud-run
make import-cloud-sql
make import-secret
make import-apis

# インポート後の確認
make state
make plan
```

### Cloud Run操作

```bash
# サービス一覧
gcloud run services list --region=asia-northeast1

# サービス詳細
gcloud run services describe backend-api --region=asia-northeast1

# ログ確認
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=backend-api" --limit=20

# 新しいリビジョンをデプロイ
gcloud run deploy backend-api --source . --region=asia-northeast1

# 環境変数更新
gcloud run services update backend-api --region=asia-northeast1 --set-env-vars="KEY=VALUE"

# リソース設定更新
gcloud run services update backend-api --region=asia-northeast1 --memory=1Gi --cpu=1
```

### Cloud SQL操作

```bash
# インスタンス一覧
gcloud sql instances list

# インスタンス詳細
gcloud sql instances describe summeryme-db

# データベース一覧
gcloud sql databases list --instance=summeryme-db

# ユーザー一覧
gcloud sql users list --instance=summeryme-db

# Cloud SQL Proxy起動
./cloud-sql-proxy your-gcp-project-id:asia-northeast1:summeryme-db --port=3306
```

### Secret Manager操作

```bash
# シークレット一覧
gcloud secrets list

# シークレット詳細
gcloud secrets describe db-password

# シークレット値確認
gcloud secrets versions access latest --secret="db-password"

# 新しいシークレット作成
echo -n "secret_value" | gcloud secrets create secret-name --data-file=-
```

### Prisma操作

```bash
# クライアント生成
npx prisma generate

# マイグレーション作成
npx prisma migrate dev --name migration_name

# マイグレーション適用（本番）
npx prisma migrate deploy

# データベースリセット
npx prisma migrate reset

# Prisma Studio起動
npx prisma studio
```

## 🔍 ヘルスチェック・テスト

### 基本ヘルスチェック

```bash
curl https://backend-api-422364792408.asia-northeast1.run.app/health
```

### Worker認証テスト（要GCP認証）

```bash
# 認証トークン取得
TOKEN=$(gcloud auth print-identity-token)

# Worker ヘルスチェック
curl -H "Authorization: Bearer $TOKEN" \
  https://backend-api-422364792408.asia-northeast1.run.app/worker/health
```

## 📊 監視・ログ

### Cloud Runログ

```bash
# 最新ログ
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=backend-api" --limit=50

# エラーログのみ
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=backend-api AND severity>=ERROR" --limit=20

# 特定時間範囲のログ
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=backend-api" \
  --format="table(timestamp,severity,textPayload)" \
  --freshness=1h
```

### Cloud SQLログ

```bash
# Cloud SQLログ
gcloud logging read "resource.type=cloudsql_database" --limit=20

# 接続ログ
gcloud logging read "resource.type=cloudsql_database AND textPayload:connection" --limit=10
```

## 🔧 トラブルシューティング

### よくある問題と解決方法

#### 1. Terraformインポートエラー

```bash
# リソース状態確認
make state

# 問題のあるリソースを削除してから再インポート
terraform state rm google_cloud_run_v2_service.main
make import-cloud-run

# 設定差分確認
make plan
```

#### 2. データベース接続エラー

```bash
# 環境変数確認
gcloud run services describe backend-api --region=asia-northeast1 --format="value(spec.template.spec.containers[0].env[].name,spec.template.spec.containers[0].env[].value)"

# IAM権限確認
gcloud projects get-iam-policy your-gcp-project-id \
  --flatten="bindings[].members" \
  --filter="bindings.members:your-compute-sa@developer.gserviceaccount.com"

# Cloud SQL状態確認
gcloud sql instances describe summeryme-db --format="value(state)"
```

#### 3. デプロイエラー

```bash
# ビルドログ確認
gcloud builds list --limit=5

# 最新ビルドの詳細
gcloud builds describe [BUILD_ID]
```

#### 4. パフォーマンス問題

```bash
# インスタンス数確認
gcloud run services describe backend-api --region=asia-northeast1 --format="value(status.traffic[0].revisionName)"

# メトリクス確認（Cloud Monitoring）
gcloud monitoring metrics list --filter="metric.type:run.googleapis.com"
```

#### 5. インポート関連の問題

```bash
# 既存リソース確認
make import-check

# プロジェクト情報確認
make project-info

# 特定リソースの詳細確認
gcloud run services describe backend-api --region=asia-northeast1
gcloud sql instances describe summeryme-db
gcloud secrets describe db-password

# 段階的インポート
make import-apis
make import-secret
make import-cloud-sql
make import-cloud-run

# 設定差分確認
make plan

# 段階的適用
make apply-cloud-run
make apply-cloud-sql
```

## 🔄 デプロイメント

### Terraformデプロイ（推奨）

```bash
# 新規デプロイ
cd terraform/
make setup
make plan
make apply
make migrate

# 既存リソースがある場合
cd terraform/
make import-check
make import-all
make plan
make apply
```

### 緊急デプロイ

```bash
# 現在のディレクトリからデプロイ
cd /Users/mbashh/dev/summeryme-ai/backend_ts
gcloud run deploy backend-api --source . --region=asia-northeast1

# 特定のイメージからデプロイ
gcloud run deploy backend-api \
  --image=asia-northeast1-docker.pkg.dev/your-gcp-project-id/cloud-run-source-deploy/backend-api \
  --region=asia-northeast1
```

### ロールバック

```bash
# リビジョン一覧
gcloud run revisions list --service=backend-api --region=asia-northeast1

# 特定のリビジョンにトラフィック切り替え
gcloud run services update-traffic backend-api \
  --to-revisions=REVISION_NAME=100 \
  --region=asia-northeast1
```

## 💰 コスト監視

### 現在のコスト確認

```bash
# Cloud SQLコスト概算
gcloud sql instances describe summeryme-db --format="value(settings.tier,settings.dataDiskSizeGb)"

# Cloud Runの設定確認
gcloud run services describe backend-api --region=asia-northeast1 \
  --format="value(spec.template.spec.containers[0].resources.limits.memory,spec.template.spec.containers[0].resources.limits.cpu)"
```

## 🔐 セキュリティ

### 権限確認

```bash
# サービスアカウント権限
gcloud projects get-iam-policy your-gcp-project-id \
  --flatten="bindings[].members" \
  --filter="bindings.members:your-compute-sa@developer.gserviceaccount.com"

# Secret Managerアクセス権限
gcloud secrets get-iam-policy db-password
```

### セキュリティ設定更新

```bash
# 認証必須に変更
gcloud run services remove-iam-policy-binding backend-api \
  --region=asia-northeast1 \
  --member="allUsers" \
  --role="roles/run.invoker"

# 特定ユーザーにアクセス許可
gcloud run services add-iam-policy-binding backend-api \
  --region=asia-northeast1 \
  --member="user:email@example.com" \
  --role="roles/run.invoker"
```

## 📱 開発環境

### ローカル開発

```bash
# 依存関係インストール
pnpm install

# 開発サーバー起動
pnpm dev

# ビルド
pnpm build

# 本番サーバー起動
pnpm start

# リント・フォーマット
pnpm lint
pnpm format
```

### Docker開発

```bash
# 開発用コンテナ起動
docker compose up -d

# ログ確認
docker compose logs -f

# コンテナ停止
docker compose down
```

---

**最終更新**: 2025-05-31
**バージョン**: 1.0.0
