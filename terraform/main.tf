# Summeryme AI Backend - Terraform Configuration

terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }
}

# プロバイダー設定
provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

# ローカル変数
locals {
  service_name = "backend-api"
  db_name      = "summeryme-db"
  db_user      = "summeryme_user"
  database     = "summeryme_production"

  labels = {
    project     = "summeryme-ai"
    environment = var.environment
    managed_by  = "terraform"
  }
}

# 必要なAPIの有効化
resource "google_project_service" "required_apis" {
  for_each = toset([
    "run.googleapis.com",
    "sqladmin.googleapis.com",
    "secretmanager.googleapis.com",
    "cloudbuild.googleapis.com",
    "containerregistry.googleapis.com",
    "artifactregistry.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com"
  ])

  service = each.value

  disable_dependent_services = false
  disable_on_destroy        = false
}

# データベースパスワード生成
resource "random_password" "db_password" {
  length  = 32
  special = true
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

resource "google_secret_manager_secret_version" "db_password" {
  secret      = google_secret_manager_secret.db_password.id
  secret_data = random_password.db_password.result
}

# Cloud SQL インスタンス
resource "google_sql_database_instance" "main" {
  name             = local.db_name
  database_version = "MYSQL_8_0"
  region          = var.region
  deletion_protection = var.environment == "production"

  settings {
    tier              = var.db_tier
    availability_type = var.environment == "production" ? "REGIONAL" : "ZONAL"

    disk_type       = "PD_HDD"
    disk_size       = var.db_disk_size
    disk_autoresize = false

    backup_configuration {
      enabled                        = true
      start_time                     = "04:00"
      point_in_time_recovery_enabled = var.environment == "production"
      binary_log_enabled            = var.environment == "production"

      backup_retention_settings {
        retained_backups = var.environment == "production" ? 7 : 3
      }
    }

    maintenance_window {
      day          = 7  # Sunday
      hour         = 4  # 4 AM
      update_track = "stable"
    }

    ip_configuration {
      ipv4_enabled = false
      private_network = null
      require_ssl = false
    }

    database_flags {
      name  = "character_set_server"
      value = "utf8mb4"
    }

    database_flags {
      name  = "collation_server"
      value = "utf8mb4_unicode_ci"
    }
  }

  depends_on = [google_project_service.required_apis]
}

# データベース作成
resource "google_sql_database" "main" {
  name     = local.database
  instance = google_sql_database_instance.main.name
  charset  = "utf8mb4"
  collation = "utf8mb4_unicode_ci"
}

# データベースユーザー作成
resource "google_sql_user" "main" {
  name     = local.db_user
  instance = google_sql_database_instance.main.name
  password = random_password.db_password.result
}

# Cloud Run サービス用のサービスアカウント
resource "google_service_account" "cloud_run" {
  account_id   = "${local.service_name}-sa"
  display_name = "Cloud Run Service Account for ${local.service_name}"
  description  = "Service account for Cloud Run service ${local.service_name}"
}

# サービスアカウントに必要な権限を付与
resource "google_project_iam_member" "cloud_run_sql_client" {
  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}

resource "google_project_iam_member" "cloud_run_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}

# Secret Managerへのアクセス権限
resource "google_secret_manager_secret_iam_member" "db_password_access" {
  secret_id = google_secret_manager_secret.db_password.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cloud_run.email}"
}

# Cloud Run サービス
resource "google_cloud_run_v2_service" "main" {
  name     = local.service_name
  location = var.region

  labels = local.labels

  template {
    service_account = google_service_account.cloud_run.email

    scaling {
      min_instance_count = var.min_instances
      max_instance_count = var.max_instances
    }

    containers {
      image = var.container_image

      ports {
        container_port = 8080
      }

      resources {
        limits = {
          cpu    = var.cpu_limit
          memory = var.memory_limit
        }
      }

      env {
        name  = "NODE_ENV"
        value = var.environment
      }

      env {
        name  = "LOG_LEVEL"
        value = var.log_level
      }

      env {
        name = "DATABASE_URL"
        value = "mysql://${local.db_user}:$${DB_PASSWORD}@localhost:3306/${local.database}?socket=/cloudsql/${var.project_id}:${var.region}:${local.db_name}"
      }

      env {
        name = "DB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.db_password.secret_id
            version = "latest"
          }
        }
      }
    }

    # Cloud SQL接続設定
    cloud_sql_instances = [
      "${var.project_id}:${var.region}:${local.db_name}"
    ]
  }

  traffic {
    percent = 100
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
  }

  depends_on = [
    google_project_service.required_apis,
    google_sql_database_instance.main,
    google_sql_database.main,
    google_sql_user.main
  ]
}

# Cloud Run サービスへのパブリックアクセス許可
resource "google_cloud_run_service_iam_member" "public_access" {
  count = var.allow_public_access ? 1 : 0

  location = google_cloud_run_v2_service.main.location
  service  = google_cloud_run_v2_service.main.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Cloud Run Job for migrations
resource "google_cloud_run_v2_job" "migrate" {
  name     = "migrate-job"
  location = var.region

  labels = local.labels

  template {
    template {
      service_account = google_service_account.cloud_run.email

      containers {
        image = var.container_image

        command = ["npx"]
        args    = ["prisma", "migrate", "deploy"]

        resources {
          limits = {
            cpu    = "1000m"
            memory = "512Mi"
          }
        }

        env {
          name  = "NODE_ENV"
          value = "production"
        }

        env {
          name = "DATABASE_URL"
          value = "mysql://${local.db_user}:$${DB_PASSWORD}@localhost:3306/${local.database}?socket=/cloudsql/${var.project_id}:${var.region}:${local.db_name}"
        }

        env {
          name = "DB_PASSWORD"
          value_source {
            secret_key_ref {
              secret  = google_secret_manager_secret.db_password.secret_id
              version = "latest"
            }
          }
        }
      }

      # Cloud SQL接続設定
      cloud_sql_instances = [
        "${var.project_id}:${var.region}:${local.db_name}"
      ]
    }
  }

  depends_on = [
    google_project_service.required_apis,
    google_cloud_run_v2_service.main
  ]
}