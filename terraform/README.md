# Summeryme AI Backend - Terraform Configuration

このディレクトリには、Summeryme AI BackendのGCPリソースをTerraformで管理するための設定ファイルが含まれています。

## 🗄️ 状態管理（GCS Backend）

このプロジェクトでは、Terraformの状態ファイルをGoogle Cloud Storage（GCS）で管理しています。

### GCS Backend設定
- **バケット**: `{PROJECT_ID}-terraform-state`（動的に設定）
- **プレフィックス**: `summeryme-ai/backend`（`providers.tf`で定義）
- **バージョニング**: 有効
- **場所**: asia-northeast1

### 🔐 設定方法

プロジェクトIDは`locals.tf`で変数として管理され、初期化時に動的に設定されます：

```bash
# GCSバックエンドで初期化
make init

# または直接実行
terraform init -backend-config="bucket=$(gcloud config get-value project)-terraform-state"
```

### 状態管理コマンド
```bash
# GCSバックエンドで初期化
make init

# ローカル状態からGCSに移行
make migrate-to-gcs

# ローカル状態ファイルのバックアップ
make backup-local-state

# ローカル状態で初期化（開発用）
make init-local

# バックエンド設定情報を確認
terraform output backend_configuration
```

### 利点
- **チーム共有**: 複数の開発者が同じ状態を共有
- **安全性**: 状態ファイルの暗号化とバージョニング
- **CI/CD対応**: GitHub Actionsでの自動デプロイ
- **ロック機能**: 同時実行の防止

## 📁 ファイル構成（ベストプラクティス準拠）

```
terraform/
├── main.tf                    # メイン設定ファイル（概要とコメント）
├── providers.tf               # プロバイダー設定とバージョン制約
├── locals.tf                  # ローカル変数定義
├── variables.tf               # 入力変数定義
├── outputs.tf                 # 出力値定義
├── apis.tf                    # Google Cloud APIs有効化
├── secrets.tf                 # Secret Manager設定
├── cloud_sql.tf               # Cloud SQL設定
├── iam.tf                     # IAM（サービスアカウント・権限）
├── cloud_run.tf               # Cloud Run（サービス・ジョブ）
├── terraform.tfvars.example   # 変数値のサンプル
├── terraform.tfvars           # 実際の変数値（Git除外）
├── .gitignore                 # Git除外設定
├── Makefile                   # 操作を簡単にするMakefile
└── README.md                  # このファイル
```

### 🏗️ ファイル構成の原則

この構成は、Terraformのベストプラクティスに従って設計されています：

1. **機能別分離**: 各リソースタイプを専用ファイルに分離
2. **明確な命名**: ファイル名から内容が分かりやすい
3. **依存関係の明確化**: リソース間の依存関係を明示
4. **再利用性**: 環境別の設定を変数で制御
5. **保守性**: コードの可読性と保守性を重視

## 🚀 セットアップ手順

### 1. 前提条件

```bash
# Terraformのインストール
brew install terraform

# Google Cloud SDKの認証
gcloud auth login
gcloud auth application-default login
gcloud config set project your-gcp-project-id
```

### 2. 初期セットアップ

```bash
# 開発環境のセットアップ
make dev-setup

# 初期セットアップ（terraform.tfvars作成）
make setup
```

### 3. 設定ファイルの編集

```bash
# 変数ファイルを編集
vim terraform.tfvars
```

必要な変数：
```hcl
project_id      = "your-gcp-project-id"
container_image = "asia-northeast1-docker.pkg.dev/your-project/repo/image"
```

### 4. Terraformの実行

```bash
# 実行計画の確認
make plan

# リソースの作成・更新
make apply

# データベースマイグレーション
make migrate
```

## 🔧 管理されるリソース

### Google Cloud APIs
- Cloud Run API
- Cloud SQL Admin API
- Secret Manager API
- Cloud Build API
- Container Registry API
- Artifact Registry API
- Cloud Logging API
- Cloud Monitoring API
- Compute API
- Service Networking API
- VPC Access API

### Artifact Registry
- **リポジトリ**: `backend`
- **形式**: Docker
- **場所**: asia-northeast1
- **用途**: Dockerイメージの保存

### Cloud SQL
- **インスタンス**: `summeryme-db`
- **データベース**: `summeryme_production`
- **ユーザー**: `summeryme_user`
- **設定**: MySQL 8.0, db-f1-micro, 10GB HDD

### Secret Manager
- **シークレット**: `db-password`
- **内容**: データベースパスワード（自動生成）

### Google Cloud Storage
- **バケット**: `{PROJECT_ID}-summeryme-audio`
- **用途**: 音声ファイルの保存
- **アクセス**: プライベート（認証が必要）

### Cloud Run
- **サービス**: `backend-api`
- **設定**: 1 vCPU, 1GB RAM, 0-10インスタンス
- **認証**: 専用サービスアカウント

### Cloud Run Job
- **ジョブ**: `migrate-job`
- **用途**: Prismaマイグレーション実行

### IAM
- **サービスアカウント**: `backend-api-sa`, `github-actions`
- **権限**: Cloud SQL接続、Secret Manager読み取り

## 📊 変数一覧

### 必須変数

| 変数名 | 説明 | 例 |
|--------|------|-----|
| `project_id` | GCPプロジェクトID | `your-gcp-project-id` |
| `container_image` | コンテナイメージURL | `asia-northeast1-docker.pkg.dev/...` |

### オプション変数

| 変数名 | 説明 | デフォルト値 |
|--------|------|-------------|
| `region` | GCPリージョン | `asia-northeast1` |
| `environment` | 環境名 | `production` |
| `db_tier` | Cloud SQLティア | `db-f1-micro` |
| `db_disk_size` | Cloud SQLディスクサイズ(GB) | `10` |
| `cpu_limit` | CPU制限 | `1000m` |
| `memory_limit` | メモリ制限 | `1Gi` |
| `min_instances` | 最小インスタンス数 | `0` |
| `max_instances` | 最大インスタンス数 | `10` |
| `log_level` | ログレベル | `info` |
| `allow_public_access` | パブリックアクセス許可 | `true` |

詳細な変数説明とバリデーションルールは `variables.tf` を参照してください。

## 📤 出力値

実行後に以下の情報が出力されます：

```bash
# 出力値の確認
make output

# 特定の値のみ表示
terraform output cloud_run_service_url
```

主な出力値：
- `cloud_run_service_url`: Cloud RunサービスのURL
- `cloud_sql_instance_connection_name`: Cloud SQL接続名
- `useful_commands`: よく使うコマンド集
- `resource_summary`: リソースサマリー

## 🔄 よく使うコマンド

### 基本操作
```bash
make help           # ヘルプ表示
make setup          # 初期セットアップ
make plan           # 実行計画確認
make apply          # リソース作成・更新
make destroy        # 全リソース削除
```

### 確認・検証
```bash
make check          # コード検証・フォーマット
make state          # リソース状態表示
make output         # 出力値表示
make project-info   # プロジェクト情報表示
```

### 部分的な適用
```bash
make apply-apis     # Google Cloud APIのみ
make apply-secrets  # Secret Managerのみ
make apply-cloud-sql # Cloud SQLのみ
make apply-iam      # IAMのみ
make apply-cloud-run # Cloud Runのみ
```

### インポート
```bash
make import-check   # インポート可能リソース確認
make import-all     # 全リソース一括インポート
make import-cloud-run # Cloud Runのみインポート
make import-cloud-sql # Cloud SQLのみインポート
```

### メンテナンス
```bash
make migrate        # データベースマイグレーション
make backup-state   # ステートファイルバックアップ
make security-scan  # セキュリティスキャン
make clean          # 一時ファイル削除
```

## 🔄 既存リソースのインポート

既にGCPに作成済みのリソースをTerraformの管理下に移行する手順です。

### 📋 インポート前の確認

```bash
# 現在のリソース状況を確認
make import-check

# プロジェクト情報を確認
make project-info
```

### 🚀 一括インポート（推奨）

```bash
# 全ての既存リソースを一括でインポート
make import-all
```

このコマンドは以下の順序で実行されます：
1. **APIサービス** - 必要なGoogle Cloud APIを有効化
2. **Secret Manager** - データベースパスワードの管理
3. **Cloud SQL** - データベースインスタンス、DB、ユーザー
4. **サービスアカウント** - Cloud Run、GitHub Actions用
5. **Cloud Run** - アプリケーションサービスとIAM設定

### 🔧 個別インポート

特定のリソースのみをインポートしたい場合：

```bash
make import-apis        # APIサービス
make import-secret      # Secret Manager
make import-cloud-sql   # Cloud SQL
make import-iam         # サービスアカウント
make import-cloud-run   # Cloud Run
```

### ⚠️ インポート時の注意点

1. **既存リソースの確認**
   - インポート前に`make import-check`で対象リソースを確認
   - 存在しないリソースは新規作成される

2. **エラーハンドリング**
   - 既にインポート済みのリソースはスキップされる
   - エラーが発生しても他のリソースのインポートは継続

3. **設定の差分**
   - インポート後は`make plan`で設定差分を確認
   - 必要に応じて`make apply`で設定を同期

### 📊 インポート後の確認

```bash
# Terraformで管理されているリソース一覧
make state

# 設定差分の確認
make plan

# 設定の同期（必要に応じて）
make apply
```

## 🔐 セキュリティ考慮事項

### State ファイル管理
本番環境では、stateファイルをリモートで管理することを強く推奨します：

```hcl
# providers.tf のbackend設定を有効化
terraform {
  backend "gcs" {
    bucket = "your-terraform-state-bucket"
    prefix = "summeryme-ai/backend"
  }
}
```

### 機密情報
- `terraform.tfvars`ファイルは`.gitignore`に含まれています
- パスワードは自動生成され、Secret Managerで管理されます
- 出力値の一部は`sensitive = true`でマスクされています

### バリデーション
- 全ての変数に適切なバリデーションルールを設定
- プロジェクトID、リージョン、リソース名の形式チェック
- 数値範囲の制限とセキュリティ設定の検証

## 🚨 トラブルシューティング

### よくある問題

1. **API有効化エラー**
   ```bash
   # 手動でAPIを有効化
   make apply-apis
   ```

2. **権限エラー**
   ```bash
   # 必要な権限を確認
   gcloud projects get-iam-policy PROJECT_ID
   ```

3. **State ロック**
   ```bash
   # ロックの強制解除（注意して使用）
   terraform force-unlock LOCK_ID
   ```

4. **インポートエラー**
   ```bash
   # 特定リソースの状態確認
   make state

   # 問題のあるリソースを削除してから再インポート
   terraform state rm google_cloud_run_v2_service.main
   make import-cloud-run
   ```

### ログ確認
```bash
# Terraformのデバッグログ
make debug

# セキュリティスキャン
make security-scan
```

## 📚 参考資料

- [Terraform Google Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Google Cloud Run Terraform Examples](https://cloud.google.com/run/docs/terraform)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [Terraform Configuration Language](https://www.terraform.io/docs/language/index.html)

## 🏆 ベストプラクティス

### ファイル構成
- ✅ 機能別にファイルを分離
- ✅ 明確で一貫した命名規則
- ✅ 適切なコメントと説明

### コード品質
- ✅ 全変数にバリデーション設定
- ✅ 適切な依存関係の定義
- ✅ セキュリティ設定の明示

### 運用
- ✅ リモートバックエンドの使用
- ✅ 定期的なセキュリティスキャン
- ✅ ステートファイルのバックアップ

---

**最終更新**: 2025-05-31
**バージョン**: 2.0.0 (ベストプラクティス準拠版)

## 🔄 バージョン履歴

### v2.1.0 (2025-06-22)
- ✨ Cloud Schedulerサポート追加
- ✨ バッチジョブのスケジュール実行対応
- ✨ Cloud Storageバケット追加
- ✨ Gemini APIキー管理追加

### v2.0.0 (2025-05-31)
- ✨ ベストプラクティスに沿ったファイル構成に変更
- ✨ 機能別ファイル分離（providers.tf, locals.tf, apis.tf等）
- ✨ 詳細なバリデーションルール追加
- ✨ 改善されたMakefileコマンド
- ✨ セキュリティ強化とドキュメント充実

### v1.0.0 (2025-05-30)
- 🎉 初期リリース
- 基本的なTerraform設定
- Cloud Run、Cloud SQL、Secret Manager対応