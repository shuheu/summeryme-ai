# Makefile for Terraform Operations
# Summeryme AI Backend Infrastructure

.PHONY: help init plan apply destroy validate format check clean import output state

# 動的にGCPプロジェクトIDを取得
PROJECT_ID := $(shell gcloud config get-value project 2>/dev/null)
REGION := asia-northeast1

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
	terraform init

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

check: validate format ## 検証とフォーマットを実行

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
	terraform apply -target=google_cloud_run_v2_service.main

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

import-cloud-run-iam: check-project ## 既存のCloud Run IAM設定をインポート
	@echo "Cloud Run IAM設定をインポート中..."
	@echo "プロジェクト: $(PROJECT_ID)"
	@if gcloud run services get-iam-policy backend-api --region=$(REGION) --format="value(bindings.members)" | grep -q "allUsers"; then \
		terraform import "google_cloud_run_service_iam_member.public_access[0]" "projects/$(PROJECT_ID)/locations/$(REGION)/services/backend-api roles/run.invoker allUsers"; \
	else \
		echo "パブリックアクセス設定が見つかりません（新規作成されます）"; \
	fi

import-all: check-project ## 全ての既存リソースを一括インポート
	@echo "🚀 全リソースの一括インポートを開始します..."
	@echo "プロジェクト: $(PROJECT_ID)"
	@echo ""
	@echo "=== 1. APIサービスのインポート ==="
	@$(MAKE) import-apis || true
	@echo ""
	@echo "=== 2. Secret Managerのインポート ==="
	@$(MAKE) import-secret || true
	@$(MAKE) import-secret-version || true
	@echo ""
	@echo "=== 3. Cloud SQLのインポート ==="
	@$(MAKE) import-cloud-sql || true
	@$(MAKE) import-cloud-sql-database || true
	@$(MAKE) import-cloud-sql-user || true
	@echo ""
	@echo "=== 4. サービスアカウントのインポート ==="
	@$(MAKE) import-service-accounts || true
	@echo ""
	@echo "=== 5. Cloud Runのインポート ==="
	@$(MAKE) import-cloud-run || true
	@$(MAKE) import-cloud-run-job || true
	@$(MAKE) import-cloud-run-iam || true
	@echo ""
	@echo "🎉 一括インポートが完了しました！"
	@echo ""
	@echo "次のステップ:"
	@echo "1. terraform plan で差分を確認"
	@echo "2. 必要に応じて terraform apply で同期"

import-check: check-project ## インポート可能なリソースをチェック
	@echo "=== インポート可能なリソースをチェック中 ==="
	@echo "プロジェクト: $(PROJECT_ID)"
	@echo ""
	@echo "Cloud Runサービス:"
	@gcloud run services list --region=$(REGION) --format="table(metadata.name,status.url)" || echo "  なし"
	@echo ""
	@echo "Cloud Run Jobs:"
	@gcloud run jobs list --region=$(REGION) --format="table(metadata.name)" || echo "  なし"
	@echo ""
	@echo "Cloud SQLインスタンス:"
	@gcloud sql instances list --format="table(name,databaseVersion,region)" || echo "  なし"
	@echo ""
	@echo "Cloud SQLデータベース:"
	@gcloud sql databases list --instance=summeryme-db --format="table(name,charset,collation)" 2>/dev/null || echo "  なし"
	@echo ""
	@echo "Cloud SQLユーザー:"
	@gcloud sql users list --instance=summeryme-db --format="table(name,host)" 2>/dev/null || echo "  なし"
	@echo ""
	@echo "Secret Manager:"
	@gcloud secrets list --format="table(name)" || echo "  なし"
	@echo ""
	@echo "サービスアカウント:"
	@gcloud iam service-accounts list --format="table(email,displayName)" | grep -E "(backend-api-sa|github-actions)" || echo "  関連するサービスアカウントなし"
	@echo ""
	@echo "有効なAPI:"
	@gcloud services list --enabled --filter="name:(run.googleapis.com OR sqladmin.googleapis.com OR secretmanager.googleapis.com)" --format="table(name)" || echo "  なし"

# 環境別操作
setup-dev: check-project ## 開発環境用の設定ファイルを作成
	@if [ ! -f terraform.tfvars ]; then \
		cp terraform.tfvars.example terraform.tfvars; \
		sed -i '' 's/project_id = "your-gcp-project-id"/project_id = "$(PROJECT_ID)"/' terraform.tfvars; \
		sed -i '' 's/environment = "production"/environment = "development"/' terraform.tfvars; \
		sed -i '' 's/db_tier = "db-f1-micro"/db_tier = "db-f1-micro"/' terraform.tfvars; \
		echo "開発環境用のterraform.tfvarsを作成しました (プロジェクト: $(PROJECT_ID))"; \
	else \
		echo "terraform.tfvarsは既に存在します"; \
	fi

setup-prod: check-project ## 本番環境用の設定ファイルを作成
	@if [ ! -f terraform.tfvars ]; then \
		cp terraform.tfvars.example terraform.tfvars; \
		sed -i '' 's/project_id = "your-gcp-project-id"/project_id = "$(PROJECT_ID)"/' terraform.tfvars; \
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
		tfsec .; \
	else \
		echo "tfsecがインストールされていません。brew install tfsec でインストールしてください"; \
	fi

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