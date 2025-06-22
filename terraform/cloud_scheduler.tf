# Cloud Scheduler
# バッチジョブのスケジュール実行

# Cloud Scheduler のサービスアカウント
resource "google_service_account" "cloud_scheduler" {
  account_id   = "${local.service_name}-scheduler-sa"
  display_name = "Cloud Scheduler Service Account for ${local.service_name}"
  description  = "Service account for Cloud Scheduler to trigger Cloud Run Jobs"
}

# Cloud Scheduler に Cloud Run Jobs を実行する権限を付与
resource "google_project_iam_member" "cloud_scheduler_run_invoker" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.cloud_scheduler.email}"
}

# 記事要約ジョブのスケジューラー
resource "google_cloud_scheduler_job" "article_summary" {
  name        = "article-summary-scheduler"
  description = "Trigger article summary batch job"
  schedule    = "0 5,11,17 * * *" # 3時間ごとに実行
  time_zone   = "Asia/Tokyo"
  region      = var.region

  http_target {
    http_method = "POST"
    uri         = "https://${var.region}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/${var.project_id}/jobs/${google_cloud_run_v2_job.article_summary.name}:run"

    oauth_token {
      service_account_email = google_service_account.cloud_scheduler.email
    }
  }

  depends_on = [
    google_project_service.required_apis,
    google_cloud_run_v2_job.article_summary,
    google_project_iam_member.cloud_scheduler_run_invoker
  ]
}

# 日次要約ジョブのスケジューラー
resource "google_cloud_scheduler_job" "daily_summary" {
  name        = "daily-summary-scheduler"
  description = "Trigger daily summary batch job"
  schedule    = "0 6,12,18 * * *"
  time_zone   = "Asia/Tokyo"
  region      = var.region

  http_target {
    http_method = "POST"
    uri         = "https://${var.region}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/${var.project_id}/jobs/${google_cloud_run_v2_job.daily_summary.name}:run"

    oauth_token {
      service_account_email = google_service_account.cloud_scheduler.email
    }
  }

  depends_on = [
    google_project_service.required_apis,
    google_cloud_run_v2_job.daily_summary,
    google_project_iam_member.cloud_scheduler_run_invoker
  ]
}