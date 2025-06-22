# Artifact Registry
# Summaryme AI Backend

# Artifact Registry リポジトリ
resource "google_artifact_registry_repository" "backend" {
  location      = var.region
  repository_id = "backend"
  description   = "Docker repository for backend application"
  format        = "DOCKER"

  labels = local.labels

  depends_on = [google_project_service.required_apis]
}

# Artifact Registry への書き込み権限（GitHub Actions用）
resource "google_artifact_registry_repository_iam_member" "github_actions_writer" {
  location   = google_artifact_registry_repository.backend.location
  repository = google_artifact_registry_repository.backend.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.github_actions.email}"
}

# Artifact Registry からの読み取り権限（Cloud Run用）
resource "google_artifact_registry_repository_iam_member" "cloud_run_reader" {
  location   = google_artifact_registry_repository.backend.location
  repository = google_artifact_registry_repository.backend.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.cloud_run.email}"
}