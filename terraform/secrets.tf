# Secret Manager
# Summeryme AI Backend

# データベースパスワード生成
resource "random_password" "db_password" {
  length  = 32
  special = false
  upper   = true
  lower   = true
  numeric = true

  # シングルクォート、ダブルクォート、バックスラッシュを除外
  # MySQLで問題を起こす可能性のある文字を避ける
  override_special = "!@#$%^&*()-_=+[]{}|;:,.<>?"

  # パスワードの再生成を防ぐ
  keepers = {
    version = "2" # バージョンを変更してパスワード再生成
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Secret Manager - データベースパスワード
resource "google_secret_manager_secret" "db_password" {
  secret_id = "db-password"

  labels = local.labels

  replication {
    auto {}
  }

  # TTL設定（90日でローテーション推奨）
  ttl = "7776000s" # 90 days

  lifecycle {
    prevent_destroy = true
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