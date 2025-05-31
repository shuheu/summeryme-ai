# Makefile for Terraform Operations
# Summeryme AI Backend Infrastructure

.PHONY: help init plan apply destroy validate format check clean import output state

# デフォルトターゲット
help: ## このヘルプメッセージを表示
	@echo "Summeryme AI Backend - Terraform Operations"
	@echo ""
	@echo "利用可能なコマンド:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

# 基本操作
init: ## Terraformを初期化
	terraform init

plan: ## 実行計画を表示
	terraform plan

apply: ## リソースを作成・更新
	terraform apply

destroy: ## 全リソースを削除（注意！）
	@echo "⚠️  警告: 全てのリソースが削除されます！"
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

# 特定リソース操作
plan-cloud-run: ## Cloud Runサービスのみプラン表示
	terraform plan -target=google_cloud_run_v2_service.main

apply-cloud-run: ## Cloud Runサービスのみ更新
	terraform apply -target=google_cloud_run_v2_service.main

plan-cloud-sql: ## Cloud SQLのみプラン表示
	terraform plan -target=google_sql_database_instance.main

apply-cloud-sql: ## Cloud SQLのみ更新
	terraform apply -target=google_sql_database_instance.main

# マイグレーション
migrate: ## データベースマイグレーションジョブを実行
	@echo "マイグレーションジョブを実行中..."
	gcloud run jobs execute migrate-job --region=asia-northeast1 --wait

# インポート操作
import-cloud-run: ## 既存のCloud Runサービスをインポート
	terraform import google_cloud_run_v2_service.main projects/numeric-skill-460414-d3/locations/asia-northeast1/services/backend-api

import-cloud-sql: ## 既存のCloud SQLインスタンスをインポート
	terraform import google_sql_database_instance.main summeryme-db

import-secret: ## 既存のSecret Managerシークレットをインポート
	terraform import google_secret_manager_secret.db_password projects/numeric-skill-460414-d3/secrets/db-password

# 環境別操作
setup-dev: ## 開発環境用の設定ファイルを作成
	@if [ ! -f terraform.tfvars ]; then \
		cp terraform.tfvars.example terraform.tfvars; \
		sed -i '' 's/environment = "production"/environment = "development"/' terraform.tfvars; \
		sed -i '' 's/db_tier = "db-f1-micro"/db_tier = "db-f1-micro"/' terraform.tfvars; \
		echo "開発環境用のterraform.tfvarsを作成しました"; \
	else \
		echo "terraform.tfvarsは既に存在します"; \
	fi

setup-prod: ## 本番環境用の設定ファイルを作成
	@if [ ! -f terraform.tfvars ]; then \
		cp terraform.tfvars.example terraform.tfvars; \
		echo "本番環境用のterraform.tfvarsを作成しました"; \
	else \
		echo "terraform.tfvarsは既に存在します"; \
	fi

# デバッグ
debug: ## デバッグモードでプランを実行
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

# 完全セットアップ
setup: init setup-prod validate ## 初期セットアップを実行
	@echo "✅ Terraformのセットアップが完了しました"
	@echo "次のステップ:"
	@echo "1. terraform.tfvarsファイルを確認・編集"
	@echo "2. make plan でプランを確認"
	@echo "3. make apply でリソースを作成"