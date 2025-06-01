# CI/CD セットアップガイド

## 📋 概要

このドキュメントでは、Summeryme AI BackendのGitHub ActionsによるCI/CDパイプラインのセットアップ方法を説明します。

## 🛠️ 前提条件

### 必要なもの
- Google Cloud Project（例：`your-gcp-project-id`）
- GitHub リポジトリ
- Google Cloud SDK（ローカル開発用）

### 必要な権限
- Google Cloud Project の編集者権限
- GitHub リポジトリの管理者権限

## 🔧 1. Google Cloud サービスアカウント作成

### 1.1 サービスアカウント作成

```bash
# プロジェクト設定
export PROJECT_ID="your-gcp-project-id"
gcloud config set project $PROJECT_ID

# サービスアカウント作成
gcloud iam service-accounts create github-actions \
  --display-name="GitHub Actions Service Account" \
  --description="Service account for GitHub Actions CI/CD"
```

### 1.2 必要な権限を付与

```bash
# Cloud Run管理権限
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:github-actions@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/run.admin"

# Cloud SQL管理権限
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:github-actions@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/cloudsql.admin"

# Secret Manager管理権限
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:github-actions@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/secretmanager.admin"

# Cloud Build権限
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:github-actions@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/cloudbuild.builds.editor"

# Artifact Registry権限
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:github-actions@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/artifactregistry.admin"

# Storage権限（Cloud Buildで必要）
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:github-actions@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/storage.admin"

# Service Account User権限
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:github-actions@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/iam.serviceAccountUser"

# Editor権限（包括的な権限）
gcloud projects add-iam-policy-binding $PROJECT_ID \
  --member="serviceAccount:github-actions@$PROJECT_ID.iam.gserviceaccount.com" \
  --role="roles/editor"
```

### 1.3 サービスアカウントキー作成

```bash
# キーファイル作成
gcloud iam service-accounts keys create github-actions-key.json \
  --iam-account=github-actions@$PROJECT_ID.iam.gserviceaccount.com

# キーファイルの内容を確認（GitHubに設定するため）
cat github-actions-key.json
```

## 🔐 2. GitHub Secrets設定

### 2.1 GitHub リポジトリでの設定

1. GitHubリポジトリにアクセス
2. `Settings` > `Secrets and variables` > `Actions`
3. `New repository secret` をクリック

### 2.2 Repository Variables設定

`Variables` タブで以下を設定：

| 名前 | 値 | 説明 |
|------|-----|------|
| `GCP_PROJECT_ID` | `your-gcp-project-id` | **必須**: GCPプロジェクトID |
| `GCP_REGION` | `asia-northeast1` | GCPリージョン |
| `GCP_SERVICE_NAME` | `backend-api` | Cloud Runサービス名 |

⚠️ **重要**: `GCP_PROJECT_ID`は必須設定です。設定しないとワークフローが失敗します。

### 2.3 Repository Secrets設定

`Secrets` タブで以下を設定：

#### `GCP_SA_KEY` の設定手順
1. **Name**: `GCP_SA_KEY`
2. **Secret**: `github-actions-key.json`ファイルの全内容をコピー&ペースト
3. **Add secret** をクリック

## 📝 3. GitHub Actions ワークフロー作成

### 3.1 ディレクトリ構造確認

```
.github/
└── workflows/
    ├── deploy-backend.yml          # バックエンドデプロイ
    ├── deploy-infrastructure.yml   # インフラデプロイ
    └── full-deployment.yml         # 完全デプロイ
```

### 3.2 ワークフローの説明

#### `deploy-backend.yml`
- **目的**: バックエンドアプリケーションのみをデプロイ
- **トリガー**: 手動実行（workflow_dispatch）
- **機能**:
  - Node.js環境セットアップ
  - 依存関係インストール
  - リント・フォーマットチェック
  - ビルド
  - Cloud Runデプロイ
  - データベースマイグレーション（オプション）
  - ヘルスチェック

#### `deploy-infrastructure.yml`
- **目的**: Terraformによるインフラ管理
- **トリガー**: 手動実行（workflow_dispatch）
- **機能**:
  - Terraform plan/apply/destroy
  - 特定リソースのターゲット指定可能

#### `full-deployment.yml`
- **目的**: インフラ + アプリケーションの完全デプロイ
- **トリガー**: 手動実行（workflow_dispatch）
- **機能**:
  - インフラデプロイ（オプション）
  - アプリケーションデプロイ
  - 段階的実行制御

## 🚀 4. ワークフロー実行方法

### 4.1 バックエンドデプロイ

1. GitHubリポジトリの `Actions` タブにアクセス
2. `Deploy Backend to Cloud Run` を選択
3. `Run workflow` をクリック
4. パラメータを設定：
   - **Environment**: `production` または `staging`
   - **Run migration**: マイグレーション実行の有無
5. `Run workflow` で実行開始

### 4.2 インフラデプロイ

1. `Deploy Infrastructure with Terraform` を選択
2. パラメータを設定：
   - **Action**: `plan`, `apply`, または `destroy`
   - **Target**: 特定リソース名（オプション）
3. 実行開始

### 4.3 完全デプロイ

1. `Full Backend Deployment Pipeline` を選択
2. パラメータを設定：
   - **Environment**: デプロイ環境
   - **Deploy infrastructure**: インフラデプロイの有無
   - **Run migration**: マイグレーション実行の有無
3. 実行開始

## 📊 5. 監視・ログ確認

### 5.1 GitHub Actions ログ

- 各ステップの詳細ログを確認可能
- エラー発生時のデバッグ情報
- デプロイメントサマリー

### 5.2 Google Cloud ログ

```bash
# Cloud Runログ確認
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=backend-api" --limit=20

# デプロイメントログ確認
gcloud logging read "resource.type=cloud_build" --limit=10
```

### 5.3 ヘルスチェック

```bash
# 手動ヘルスチェック
curl https://backend-api-422364792408.asia-northeast1.run.app/health

# Worker APIヘルスチェック（認証必要）
curl -H "Authorization: Bearer $(gcloud auth print-identity-token)" \
     https://backend-api-422364792408.asia-northeast1.run.app/worker/health
```

## 🔧 6. トラブルシューティング

### 6.1 よくある問題

#### 認証エラー
```
Error: google-github-actions/auth failed
```
**解決方法**: `GCP_SA_KEY` シークレットの設定を確認

#### ビルドエラー
```
Error: pnpm build failed
```
**解決方法**: ローカルでビルドテストを実行

#### デプロイエラー
```
Error: gcloud run deploy failed
```
**解決方法**: Cloud Run APIの有効化、権限設定を確認

### 6.2 デバッグ手順

1. **ローカルテスト**
   ```bash
   cd backend_ts
   pnpm install
   pnpm lint
   pnpm build
   ```

2. **権限確認**
   ```bash
   gcloud auth list
   gcloud projects get-iam-policy your-gcp-project-id
   ```

3. **サービス確認**
   ```bash
   gcloud services list --enabled
   gcloud run services list
   ```

### 6.3 ロールバック手順

#### 前のリビジョンに戻す
```bash
# リビジョン一覧確認
gcloud run revisions list --service=backend-api --region=asia-northeast1

# 特定リビジョンにトラフィック切り替え
gcloud run services update-traffic backend-api \
  --to-revisions=REVISION_NAME=100 \
  --region=asia-northeast1
```

## 🔐 7. セキュリティ考慮事項

### 7.1 サービスアカウント権限
- 最小権限の原則に従う
- 定期的な権限レビュー
- 不要な権限の削除

### 7.2 シークレット管理
- GitHub Secretsの適切な使用
- 定期的なキーローテーション
- アクセスログの監視

### 7.3 ネットワークセキュリティ
- VPCファイアウォール設定
- Cloud SQL プライベート接続
- SSL/TLS通信の強制

## 📚 8. 参考資料

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Google Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Cloud SQL Documentation](https://cloud.google.com/sql/docs)