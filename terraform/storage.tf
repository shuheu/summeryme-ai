# Google Cloud Storage
# Summaryme AI Backend

# 音声ファイル保存用のGCSバケット
resource "google_storage_bucket" "audio_files" {
  name          = "${var.project_id}-summeryme-audio"
  location      = var.region
  force_destroy = !local.is_production # 本番環境では誤削除防止

  labels = local.labels

  # バージョニング設定
  versioning {
    enabled = local.is_production
  }

  # ライフサイクル設定
  # lifecycle_rule {
  #   condition {
  #     age = 30 # 30日後に削除
  #   }
  #   action {
  #     type = "Delete"
  #   }
  # }

  # CORS設定（必要に応じて）
  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD"]
    response_header = ["*"]
    max_age_seconds = 3600
  }

  # パブリックアクセス防止
  public_access_prevention = "enforced"

  depends_on = [google_project_service.required_apis]
}

# Cloud Runサービスアカウントにバケットへの読み書き権限を付与
resource "google_storage_bucket_iam_member" "audio_bucket_admin" {
  bucket = google_storage_bucket.audio_files.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.cloud_run.email}"
}

# GitHub Actionsサービスアカウントにもバケットへの権限を付与（必要に応じて）
# resource "google_storage_bucket_iam_member" "audio_bucket_github_admin" {
#   bucket = google_storage_bucket.audio_files.name
#   role   = "roles/storage.objectAdmin"
#   member = "serviceAccount:${google_service_account.github_actions.email}"
# }