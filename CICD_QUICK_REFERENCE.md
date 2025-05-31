# CI/CD クイックリファレンス

## 🚀 GitHub Actions ワークフロー実行

### 1. バックエンドデプロイ
```
GitHub → Actions → "Deploy Backend to Cloud Run" → Run workflow
```
- **Environment**: production / staging
- **Run migration**: true / false

### 2. インフラデプロイ
```
GitHub → Actions → "Deploy Infrastructure with Terraform" → Run workflow
```
- **Action**: plan / apply / destroy
- **Target**: (オプション) 特定リソース名

### 3. 完全デプロイ
```
GitHub → Actions → "Full Backend Deployment Pipeline" → Run workflow
```
- **Environment**: production / staging
- **Deploy infrastructure**: true / false
- **Run migration**: true / false

## 🔧 必要なセットアップ

### GitHub Secrets
| 名前 | 値 |
|------|-----|
| `GCP_SA_KEY` | Google Cloud サービスアカウントキー（JSON） |

### GitHub Variables
| 名前 | 値 |
|------|-----|
| `GCP_PROJECT_ID` | `your-gcp-project-id` |
| `GCP_REGION` | `asia-northeast1` |
| `GCP_SERVICE_NAME` | `backend-api` |

### Google Cloud 権限
```bash
# サービスアカウント作成
gcloud iam service-accounts create github-actions

# 権限付与
gcloud projects add-iam-policy-binding your-gcp-project-id \
  --member="serviceAccount:github-actions@your-gcp-project-id.iam.gserviceaccount.com" \
  --role="roles/run.admin"

# キー作成
gcloud iam service-accounts keys create github-actions-key.json \
  --iam-account=github-actions@your-gcp-project-id.iam.gserviceaccount.com
```

## 📊 デプロイ後確認

### ヘルスチェック
```bash
curl https://your-service-url.run.app/health
```

### ログ確認
```bash
gcloud logging read "resource.labels.service_name=backend-api" --limit=10
```

### サービス状態確認
```bash
gcloud run services describe backend-api --region=asia-northeast1
```

## 🔄 ロールバック

### 前のリビジョンに戻す
```bash
# リビジョン一覧
gcloud run revisions list --service=backend-api --region=asia-northeast1

# トラフィック切り替え
gcloud run services update-traffic backend-api \
  --to-revisions=REVISION_NAME=100 \
  --region=asia-northeast1
```

## 🚨 トラブルシューティング

### よくあるエラー

#### 1. 認証エラー
```
Error: google-github-actions/auth failed
```
**解決方法**: `GCP_SA_KEY` シークレットの設定確認

#### 2. ビルドエラー
```
Error: pnpm build failed
```
**解決方法**: ローカルでビルドテスト実行

#### 3. デプロイエラー
```
Error: gcloud run deploy failed
```
**解決方法**: API有効化・権限設定確認

### デバッグコマンド
```bash
# ローカルテスト
cd backend_ts && pnpm install && pnpm build

# 権限確認
gcloud projects get-iam-policy your-gcp-project-id

# サービス確認
gcloud run services list
```

## 📋 ワークフロー概要

### deploy-backend.yml
- **目的**: アプリケーションのみデプロイ
- **所要時間**: 約5-10分
- **主要ステップ**: ビルド → デプロイ → マイグレーション → ヘルスチェック

### deploy-infrastructure.yml
- **目的**: Terraformによるインフラ管理
- **所要時間**: 約3-15分（アクションによる）
- **主要ステップ**: Terraform init → plan/apply/destroy

### full-deployment.yml
- **目的**: インフラ + アプリケーション完全デプロイ
- **所要時間**: 約10-20分
- **主要ステップ**: インフラ → アプリケーション → 検証

## 🔗 関連リンク

- [CICD_SETUP.md](./CICD_SETUP.md) - 詳細セットアップガイド
- [DEPLOYMENT.md](./DEPLOYMENT.md) - デプロイメントガイド
- [GitHub Actions](https://github.com/features/actions) - 公式ドキュメント