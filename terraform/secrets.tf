# Secret Manager
# Summeryme AI Backend

# データベースパスワード生成
resource "random_password" "db_password" {
  length  = 32
  special = true
  upper   = true
  lower   = true
  numeric = true

  # パスワードの再生成を防ぐ
  keepers = {
    version = "1"
  }
}

# Secret Manager - データベースパスワード
resource "google_secret_manager_secret" "db_password" {
  secret_id = "db-password"

  labels = local.labels

  replication {
    auto {}
  }

  depends_on = [google_project_service.required_apis]
}

# Secret Manager - パスワードバージョン
resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.db_password.result

  lifecycle {
    ignore_changes = [secret_data]
  }
}

# Secret Managerへのアクセス権限
resource "google_secret_manager_secret_iam_member" "db_password_access" {
  secret_id = google_secret_manager_secret.db_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cloud_run.email}"

  depends_on = [google_service_account.cloud_run]
}