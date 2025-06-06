# Makefile for Terraform Operations
# Summeryme AI Backend Infrastructure

.PHONY: help init plan apply destroy validate format check check-all clean import output state lint lint-fix checkov checkov-json checkov-quiet security-all

# 動的にGCPプロジェクトIDを取得
PROJECT_ID := $(shell gcloud config get-value project 2>/dev/null)
REGION := asia-northeast1

# Terraformバックエンド設定
BACKEND_BUCKET := $(PROJECT_ID)-terraform-state
BACKEND_PREFIX := summeryme-ai/backend

# プロジェクトIDが設定されているかチェック
check-project:
	@if [ -z "$(PROJECT_ID)" ]; then \
		echo "❌ エラー: GCPプロジェクトIDが設定されていません"; \
		echo "以下のコマンドでプロジェクトを設定してください:"; \
		echo "  gcloud config set project YOUR_PROJECT_ID"; \
		exit 1; \
	else \
		echo "✅ 使用中のプロジェクト: $(PROJECT_ID)"; \
	fi

# デフォルトターゲット
help: ## このヘルプメッセージを表示
	@echo "Summeryme AI Backend - Terraform Operations"
	@echo ""
	@echo "現在のプロジェクト: $(PROJECT_ID)"
	@echo ""
	@echo "利用可能なコマンド:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

# 基本操作
init: check-project ## Terraformを初期化
	@echo "🔧 Initializing Terraform with GCS backend..."
	@echo "Backend bucket: $(BACKEND_BUCKET)"
	@echo "Backend prefix: $(BACKEND_PREFIX)"
	terraform init \
		-backend-config="bucket=$(BACKEND_BUCKET)" \
		-backend-config="prefix=$(BACKEND_PREFIX)"
	@echo "✅ Terraform initialized with GCS backend"

plan: check-project ## 実行計画を表示
	terraform plan

apply: check-project ## リソースを作成・更新
	terraform apply

destroy: check-project ## 全リソースを削除（注意！）
	@echo "⚠️  警告: 全てのリソースが削除されます！"
	@echo "プロジェクト: $(PROJECT_ID)"
	@read -p "続行しますか？ (yes/no): " confirm && [ "$$confirm" = "yes" ]
	terraform destroy

# 検証・フォーマット
validate: ## 設定ファイルの検証
	terraform validate

format: ## 設定ファイルのフォーマット
	terraform fmt -recursive

lint: ## TerraformコードのLint実行（tflintが必要）
	@if command -v tflint >/dev/null 2>&1; then \
		echo "🔍 TerraformコードのLintを実行中..."; \
		tflint --init; \
		tflint; \
		echo "✅ Lintが完了しました"; \
	else \
		echo "❌ tflintがインストールされていません"; \
		echo "以下のコマンドでインストールしてください:"; \
		echo "  brew install tflint"; \
		echo "または"; \
		echo "  curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash"; \
	fi

lint-fix: ## TerraformコードのLint実行（自動修正可能な問題を修正）
	@if command -v tflint >/dev/null 2>&1; then \
		echo "🔧 TerraformコードのLintを実行中（自動修正モード）..."; \
		tflint --init; \
		tflint --fix; \
		echo "✅ Lintと自動修正が完了しました"; \
	else \
		echo "❌ tflintがインストールされていません"; \
		echo "以下のコマンドでインストールしてください:"; \
		echo "  brew install tflint"; \
		echo "または"; \
		echo "  curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash"; \
	fi


check: validate format lint ## 検証、フォーマット、Lintを実行

check-all: validate format lint security-all ## 検証、フォーマット、Lint、セキュリティスキャンを実行

# 情報表示
output: ## 出力値を表示
	terraform output

state: ## リソース状態を表示
	terraform state list

# ユーティリティ
clean: ## 一時ファイルを削除
	rm -rf .terraform/
	rm -f terraform.tfstate.backup
	rm -f .terraform.lock.hcl

# Cloud SQL管理
stop-sql: check-project ## Cloud SQLインスタンスを停止（コスト削減）
	@echo "🛑 Cloud SQLインスタンスを停止中..."
	@echo "プロジェクト: $(PROJECT_ID)"
	@echo "インスタンス: summeryme-db"
	gcloud sql instances patch summeryme-db --activation-policy=NEVER --quiet
	@echo "✅ Cloud SQLインスタンスが停止されました"
	@echo "💰 これによりコストが大幅に削減されます"

start-sql: check-project ## Cloud SQLインスタンスを開始
	@echo "🚀 Cloud SQLインスタンスを開始中..."
	@echo "プロジェクト: $(PROJECT_ID)"
	@echo "インスタンス: summeryme-db"
	gcloud sql instances patch summeryme-db --activation-policy=ALWAYS --quiet
	@echo "✅ Cloud SQLインスタンスが開始されました"
	@echo "⏰ 起動まで数分かかる場合があります"

sql-status: check-project ## Cloud SQLインスタンスの状態を確認
	@echo "📊 Cloud SQLインスタンスの状態:"
	@echo "プロジェクト: $(PROJECT_ID)"
	gcloud sql instances describe summeryme-db --format="table(name,state,settings.activationPolicy,settings.tier)" 2>/dev/null || echo "❌ インスタンスが見つかりません"

# 特定リソース操作
plan-cloud-run: check-project ## Cloud Runサービスのみプラン表示
	terraform plan -target=google_cloud_run_v2_service.main

apply-cloud-run: check-project ## Cloud Runサービスのみ更新
	terraform apply -auto-approve -target=google_cloud_run_v2_service.main

plan-cloud-run-job: check-project ## Cloud Run Jobのみプラン表示
	terraform plan -target=google_cloud_run_v2_job.migrate

apply-cloud-run-job: check-project ## Cloud Run Jobのみ更新
	terraform apply -auto-approve -target=google_cloud_run_v2_job.migrate

plan-cloud-sql: check-project ## Cloud SQLのみプラン表示
	terraform plan -target=google_sql_database_instance.main

apply-cloud-sql: check-project ## Cloud SQLのみ更新
	terraform apply -target=google_sql_database_instance.main

plan-vpc: check-project ## VPCネットワークのみプラン表示
	terraform plan -target=google_compute_network.main -target=google_compute_subnetwork.main

apply-vpc: check-project ## VPCネットワークのみ更新
	terraform apply -target=google_compute_network.main -target=google_compute_subnetwork.main

# マイグレーション
migrate: check-project ## データベースマイグレーションジョブを実行
	@echo "マイグレーションジョブを実行中..."
	@echo "プロジェクト: $(PROJECT_ID)"
	gcloud run jobs execute migrate-job --region=$(REGION) --wait

# インポート操作
import-cloud-run: check-project ## 既存のCloud Runサービスをインポート
	@echo "Cloud Runサービスをインポート中..."
	@echo "プロジェクト: $(PROJECT_ID)"
	terraform import google_cloud_run_v2_service.main projects/$(PROJECT_ID)/locations/$(REGION)/services/backend-api

import-cloud-run-job: check-project ## 既存のCloud Run Jobをインポート
	@echo "Cloud Run Jobをインポート中..."
	@echo "プロジェクト: $(PROJECT_ID)"
	terraform import google_cloud_run_v2_job.migrate projects/$(PROJECT_ID)/locations/$(REGION)/jobs/migrate-job

import-cloud-sql: check-project ## 既存のCloud SQLインスタンスをインポート
	@echo "Cloud SQLインスタンスをインポート中..."
	@echo "プロジェクト: $(PROJECT_ID)"
	terraform import google_sql_database_instance.main summeryme-db

import-cloud-sql-database: check-project ## 既存のCloud SQLデータベースをインポート
	@echo "Cloud SQLデータベースをインポート中..."
	@echo "プロジェクト: $(PROJECT_ID)"
	terraform import google_sql_database.main $(PROJECT_ID)/summeryme-db/summeryme_production

import-cloud-sql-user: check-project ## 既存のCloud SQLユーザーをインポート
	@echo "Cloud SQLユーザーをインポート中..."
	@echo "プロジェクト: $(PROJECT_ID)"
	terraform import google_sql_user.main $(PROJECT_ID)/summeryme-db/summeryme_user

import-secret: check-project ## 既存のSecret Managerシークレットをインポート
	@echo "Secret Managerシークレットをインポート中..."
	@echo "プロジェクト: $(PROJECT_ID)"
	terraform import google_secret_manager_secret.db_password projects/$(PROJECT_ID)/secrets/db-password

import-secret-version: check-project ## 既存のSecret Managerシークレットバージョンをインポート
	@echo "Secret Managerシークレットバージョンをインポート中..."
	@echo "プロジェクト: $(PROJECT_ID)"
	@SECRET_VERSION=$$(gcloud secrets versions list db-password --limit=1 --format="value(name)") && \
	terraform import google_secret_manager_secret_version.db_password projects/$(PROJECT_ID)/secrets/db-password/versions/$$SECRET_VERSION

import-service-accounts: check-project ## 既存のサービスアカウントをインポート（存在する場合）
	@echo "サービスアカウントをインポート中..."
	@echo "プロジェクト: $(PROJECT_ID)"
	@if gcloud iam service-accounts describe backend-api-sa@$(PROJECT_ID).iam.gserviceaccount.com >/dev/null 2>&1; then \
		terraform import google_service_account.cloud_run projects/$(PROJECT_ID)/serviceAccounts/backend-api-sa@$(PROJECT_ID).iam.gserviceaccount.com; \
	else \
		echo "backend-api-sa サービスアカウントが見つかりません（新規作成されます）"; \
	fi
	@if gcloud iam service-accounts describe github-actions@$(PROJECT_ID).iam.gserviceaccount.com >/dev/null 2>&1; then \
		terraform import google_service_account.github_actions projects/$(PROJECT_ID)/serviceAccounts/github-actions@$(PROJECT_ID).iam.gserviceaccount.com; \
	else \
		echo "github-actions サービスアカウントが見つかりません（新規作成されます）"; \
	fi

import-apis: check-project ## 既存のAPIサービスをインポート
	@echo "APIサービスをインポート中..."
	@echo "プロジェクト: $(PROJECT_ID)"
	@for api in run.googleapis.com sqladmin.googleapis.com secretmanager.googleapis.com cloudbuild.googleapis.com containerregistry.googleapis.com artifactregistry.googleapis.com logging.googleapis.com monitoring.googleapis.com compute.googleapis.com servicenetworking.googleapis.com vpcaccess.googleapis.com; do \
		echo "インポート中: $$api"; \
		terraform import "google_project_service.required_apis[\"$$api\"]" $(PROJECT_ID)/$$api || echo "$$api のインポートに失敗（既に有効化済みの可能性）"; \
	done

import-artifact-registry: check-project ## 既存のArtifact Registryリポジトリをインポート
	@echo "Artifact Registryリポジトリをインポート中..."
	@echo "プロジェクト: $(PROJECT_ID)"
	@if gcloud artifacts repositories describe backend --location=$(REGION) >/dev/null 2>&1; then \
		terraform import google_artifact_registry_repository.backend projects/$(PROJECT_ID)/locations/$(REGION)/repositories/backend; \
	else \
		echo "backend リポジトリが見つかりません（新規作成されます）"; \
	fi

import-cloud-run-iam: check-project ## 既存のCloud Run IAM設定をインポート
	@echo "Cloud Run IAM設定をインポート中..."
	@echo "プロジェクト: $(PROJECT_ID)"
	@if gcloud run services get-iam-policy backend-api --region=$(REGION) --format="value(bindings.members)" | grep -q "allUsers"; then \
		terraform import "google_cloud_run_service_iam_member.public_access[0]" "projects/$(PROJECT_ID)/locations/$(REGION)/services/backend-api roles/run.invoker allUsers"; \
	else \
		echo "パブリックアクセス設定が見つかりません（新規作成されます）"; \
	fi

# 環境別操作
setup-dev: check-project ## 開発環境用の設定ファイルを作成
	@if [ ! -f terraform.tfvars ]; then \
		cp terraform.tfvars.example terraform.tfvars; \
		sed -i '' 's/your-gcp-project-id/$(PROJECT_ID)/g' terraform.tfvars; \
		sed -i '' 's/your-project/$(PROJECT_ID)/g' terraform.tfvars; \
		sed -i '' 's/environment = "production"/environment = "development"/' terraform.tfvars; \
		echo "開発環境用のterraform.tfvarsを作成しました (プロジェクト: $(PROJECT_ID))"; \
	else \
		echo "terraform.tfvarsは既に存在します"; \
	fi

setup-prod: check-project ## 本番環境用の設定ファイルを作成
	@if [ ! -f terraform.tfvars ]; then \
		cp terraform.tfvars.example terraform.tfvars; \
		sed -i '' 's/your-gcp-project-id/$(PROJECT_ID)/g' terraform.tfvars; \
		sed -i '' 's/your-project/$(PROJECT_ID)/g' terraform.tfvars; \
		echo "本番環境用のterraform.tfvarsを作成しました (プロジェクト: $(PROJECT_ID))"; \
	else \
		echo "terraform.tfvarsは既に存在します"; \
	fi

# デバッグ
debug: check-project ## デバッグモードでプランを実行
	TF_LOG=DEBUG terraform plan

# 状態管理
backup-state: ## stateファイルのバックアップを作成
	@if [ -f terraform.tfstate ]; then \
		cp terraform.tfstate terraform.tfstate.backup.$(shell date +%Y%m%d_%H%M%S); \
		echo "stateファイルをバックアップしました"; \
	else \
		echo "terraform.tfstateファイルが見つかりません"; \
	fi

# セキュリティ
security-scan: ## セキュリティスキャンを実行（tfsecが必要）
	@if command -v tfsec >/dev/null 2>&1; then \
		echo "🔒 セキュリティスキャンを実行中..."; \
		if [ -f terraform.tfvars ]; then \
			tfsec . --tfvars-file terraform.tfvars --format lovely; \
		else \
			tfsec . --format lovely; \
		fi; \
		echo ""; \
		echo "💡 詳細情報: https://aquasecurity.github.io/tfsec/"; \
	else \
		echo "❌ tfsecがインストールされていません"; \
		echo "以下のコマンドでインストールしてください:"; \
		echo "  brew install tfsec"; \
		echo "または"; \
		echo "  curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash"; \
	fi

checkov: ## Checkovコンプライアンススキャンを実行
	@if python3 -c "import checkov" 2>/dev/null; then \
		echo "📋 Checkovコンプライアンススキャンを実行中..."; \
		python3 -m checkov.main -d . --framework terraform --compact; \
		echo "✅ Checkovスキャンが完了しました"; \
	else \
		echo "❌ checkovがインストールされていません"; \
		echo "以下のコマンドでインストールしてください:"; \
		echo "  pip install checkov"; \
		echo "または"; \
		echo "  brew install checkov"; \
	fi

checkov-json: ## Checkovスキャンを実行してJSON形式で出力
	@if python3 -c "import checkov" 2>/dev/null; then \
		echo "📋 Checkovスキャンを実行中（JSON出力）..."; \
		python3 -m checkov.main -d . --framework terraform --output json --output-file checkov-results.json; \
		echo "✅ 結果をcheckov-results.jsonに保存しました"; \
	else \
		echo "❌ checkovがインストールされていません"; \
	fi

checkov-quiet: ## Checkovスキャンを実行（簡潔出力）
	@if python3 -c "import checkov" 2>/dev/null; then \
		echo "📋 Checkovスキャンを実行中（簡潔モード）..."; \
		python3 -m checkov.main -d . --framework terraform --quiet; \
		echo "✅ Checkovスキャンが完了しました"; \
	else \
		echo "❌ checkovがインストールされていません"; \
	fi

security-all: security-scan checkov ## 全セキュリティスキャンを実行（tfsec + checkov）

# ドキュメント生成
docs: ## Terraformドキュメントを生成（terraform-docsが必要）
	@if command -v terraform-docs >/dev/null 2>&1; then \
		terraform-docs markdown table . > TERRAFORM_DOCS.md; \
		echo "ドキュメントをTERRAFORM_DOCS.mdに生成しました"; \
	else \
		echo "terraform-docsがインストールされていません。brew install terraform-docs でインストールしてください"; \
	fi

# プロジェクト情報表示
project-info: check-project ## 現在のプロジェクト情報を表示
	@echo "=== プロジェクト情報 ==="
	@echo "プロジェクトID: $(PROJECT_ID)"
	@echo "リージョン: $(REGION)"
	@echo ""
	@echo "=== 既存リソース確認 ==="
	@echo "Cloud Runサービス:"
	@gcloud run services list --region=$(REGION) --format="table(metadata.name,status.url)" 2>/dev/null || echo "  なし"
	@echo ""
	@echo "Cloud SQLインスタンス:"
	@gcloud sql instances list --format="table(name,databaseVersion,region,settings.tier)" 2>/dev/null || echo "  なし"
	@echo ""
	@echo "Secret Manager:"
	@gcloud secrets list --format="table(name)" 2>/dev/null || echo "  なし"

# 完全セットアップ
setup: init setup-prod validate ## 初期セットアップを実行
	@echo "✅ Terraformのセットアップが完了しました"
	@echo "プロジェクト: $(PROJECT_ID)"
	@echo ""
	@echo "次のステップ:"
	@echo "1. terraform.tfvarsファイルを確認・編集"
	@echo "2. make plan でプランを確認"
	@echo "3. make apply でリソースを作成"

# 全体インポート
import-all: import-apis import-service-accounts import-cloud-sql import-cloud-sql-database import-cloud-run import-cloud-run-job import-secret import-artifact-registry ## 全てのリソースをインポート

# 状態管理
init-local: check-project ## ローカル状態でTerraformを初期化
	terraform init

init-gcs: check-project ## GCS状態でTerraformを初期化
	@echo "🔧 Initializing Terraform with GCS backend..."
	@echo "Backend bucket: $(BACKEND_BUCKET)"
	@echo "Backend prefix: $(BACKEND_PREFIX)"
	terraform init \
		-backend-config="bucket=$(BACKEND_BUCKET)" \
		-backend-config="prefix=$(BACKEND_PREFIX)"
	@echo "✅ Terraform initialized with GCS backend"

migrate-to-gcs: check-project ## ローカル状態をGCSに移行
	@echo "🔄 Migrating local state to GCS backend..."
	@echo "Backend bucket: $(BACKEND_BUCKET)"
	@echo "Backend prefix: $(BACKEND_PREFIX)"
	@echo ""
	@echo "⚠️  注意: この操作により、ローカルの terraform.tfstate がGCSに移行されます"
	@read -p "続行しますか？ (yes/no): " confirm && [ "$$confirm" = "yes" ]
	terraform init -migrate-state \
		-backend-config="bucket=$(BACKEND_BUCKET)" \
		-backend-config="prefix=$(BACKEND_PREFIX)"
	@echo "✅ State migration completed"

backup-local-state: ## ローカル状態ファイルをバックアップ
	@if [ -f terraform.tfstate ]; then \
		cp terraform.tfstate terraform.tfstate.backup-$(shell date +%Y%m%d-%H%M%S); \
		echo "✅ Local state backed up"; \
	else \
		echo "❌ No local state file found"; \
	fi