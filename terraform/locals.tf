# ローカル変数定義
# Summeryme AI Backend

locals {
  # サービス名
  service_name = "backend-api"
  db_name      = "summeryme-db"
  db_user      = "summeryme_user"
  database     = "summeryme_production"

  # 共通ラベル
  labels = {
    project     = "summeryme-ai"
    environment = var.environment
    managed_by  = "terraform"
  }

  # Cloud SQL接続文字列
  cloud_sql_connection_name = "${var.project_id}:${var.region}:${local.db_name}"

  # データベース接続URL（Cloud Run内でのUnix Socket接続用）
  database_url = "mysql://${local.db_user}:$${DB_PASSWORD}@/summeryme_production?socket=/cloudsql/${local.cloud_sql_connection_name}"

  # 必要なGoogle Cloud APIs
  required_apis = [
    "cloudresourcemanager.googleapis.com",
    "run.googleapis.com",
    "sqladmin.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudbuild.googleapis.com",
    "containerregistry.googleapis.com",
    "artifactregistry.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "compute.googleapis.com",
    "servicenetworking.googleapis.com",
    "vpcaccess.googleapis.com"
  ]

  # 環境別設定
  is_production = var.environment == "production"

  # データベース設定
  db_settings = {
    backup_enabled      = local.is_production
    deletion_protection = local.is_production
    binary_log_enabled  = local.is_production
    retained_backups    = local.is_production ? 7 : 1
  }
}