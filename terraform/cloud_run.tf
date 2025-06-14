# Cloud Run
# Summeryme AI Backend

# VPCアクセスコネクタ
resource "google_vpc_access_connector" "main" {
  name          = "${local.service_name}-connector"
  region        = var.region
  ip_cidr_range = "10.8.0.0/28"
  network       = google_compute_network.main.name

  depends_on = [google_project_service.required_apis]
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

    # VPCアクセス設定
    vpc_access {
      connector = google_vpc_access_connector.main.id
      egress    = "ALL_TRAFFIC"
    }

    # Cloud SQL接続設定
    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [local.cloud_sql_connection_name]
      }
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
        cpu_idle = true
      }

      # 環境変数
      env {
        name  = "NODE_ENV"
        value = var.environment
      }

      env {
        name  = "LOG_LEVEL"
        value = var.log_level
      }

      # データベース接続情報を個別の環境変数として設定
      env {
        name  = "DB_HOST"
        value = "localhost" # Cloud SQL Proxyを使用するためlocalhost
      }

      env {
        name  = "DB_PORT"
        value = "3306"
      }

      env {
        name  = "DB_USER"
        value = local.db_user
      }

      env {
        name  = "DB_NAME"
        value = local.database
      }

      env {
        name  = "DB_SOCKET_PATH"
        value = "/cloudsql/${local.cloud_sql_connection_name}"
      }

      # Secret Manager からの環境変数
      env {
        name = "DB_PASSWORD"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.db_password.secret_id
            version = "latest"
          }
        }
      }

      # GCS設定
      env {
        name  = "GCS_AUDIO_BUCKET"
        value = google_storage_bucket.audio_files.name
      }

      # Cloud SQL ボリュームマウント
      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }

      # ヘルスチェック設定
      startup_probe {
        http_get {
          path = "/health/basic"
          port = 8080
        }
        initial_delay_seconds = 10
        timeout_seconds       = 5
        period_seconds        = 10
        failure_threshold     = 3
      }

      liveness_probe {
        http_get {
          path = "/health/basic"
          port = 8080
        }
        initial_delay_seconds = 30
        timeout_seconds       = 5
        period_seconds        = 30
        failure_threshold     = 3
      }
    }

    # タイムアウト設定
    timeout = "900s" # 15分

    # 同時実行数
    max_instance_request_concurrency = 100
  }

  traffic {
    percent = 100
    type    = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
  }

  depends_on = [
    google_project_service.required_apis,
    google_sql_database_instance.main,
    google_secret_manager_secret_version.db_password,
    google_vpc_access_connector.main,
    google_storage_bucket.audio_files
  ]

  lifecycle {
    ignore_changes = [
      template[0].containers[0].image
    ]
  }
}

# Cloud Run Job (マイグレーション用)
resource "google_cloud_run_v2_job" "migrate" {
  name     = "migrate-job"
  location = var.region

  labels = local.labels

  template {
    template {
      service_account = google_service_account.cloud_run.email

      # VPCアクセス設定
      vpc_access {
        connector = google_vpc_access_connector.main.id
        egress    = "ALL_TRAFFIC"
      }

      # Cloud SQL接続設定
      volumes {
        name = "cloudsql"
        cloud_sql_instance {
          instances = [local.cloud_sql_connection_name]
        }
      }

      containers {
        image = var.container_image

        # bashスクリプトでマイグレーションを実行
        command = ["pnpm"]
        args    = ["run", "migrate"]

        resources {
          limits = {
            cpu    = "1000m"
            memory = "1Gi"
          }
        }

        # 環境変数
        env {
          name  = "NODE_ENV"
          value = var.environment
        }

        # データベース接続情報を個別の環境変数として設定
        env {
          name  = "DB_HOST"
          value = "localhost"
        }

        env {
          name  = "DB_PORT"
          value = "3306"
        }

        env {
          name  = "DB_USER"
          value = local.db_user
        }

        env {
          name  = "DB_NAME"
          value = local.database
        }

        env {
          name  = "DB_SOCKET_PATH"
          value = "/cloudsql/${local.cloud_sql_connection_name}"
        }

        # Secret Manager からの環境変数
        env {
          name = "DB_PASSWORD"
          value_source {
            secret_key_ref {
              secret  = google_secret_manager_secret.db_password.secret_id
              version = "latest"
            }
          }
        }

        # GCS設定
        env {
          name  = "GCS_AUDIO_BUCKET"
          value = google_storage_bucket.audio_files.name
        }

        # Cloud SQL ボリュームマウント
        volume_mounts {
          name       = "cloudsql"
          mount_path = "/cloudsql"
        }
      }
    }
  }

  depends_on = [
    google_project_service.required_apis,
    google_sql_database_instance.main,
    google_secret_manager_secret_version.db_password,
    google_vpc_access_connector.main,
    google_storage_bucket.audio_files
  ]

  lifecycle {
    ignore_changes = [
      template[0].template[0].containers[0].image
    ]
  }
}

# Cloud Run Job (記事要約処理用)
resource "google_cloud_run_v2_job" "article_summary" {
  name     = "article-summary-job"
  location = var.region

  labels = local.labels

  template {
    # ジョブレベルの設定
    parallelism = 1
    task_count  = 1

    template {
      service_account = google_service_account.cloud_run.email

      # VPCアクセス設定
      vpc_access {
        connector = google_vpc_access_connector.main.id
        egress    = "ALL_TRAFFIC"
      }

      # Cloud SQL接続設定
      volumes {
        name = "cloudsql"
        cloud_sql_instance {
          instances = [local.cloud_sql_connection_name]
        }
      }

      containers {
        image = var.container_image

        # 記事要約処理を実行
        command = ["pnpm"]
        args    = ["run", "run-job:articleSummary"]

        resources {
          limits = {
            cpu    = "2000m"
            memory = "2Gi"
          }
        }

        # 環境変数
        env {
          name  = "NODE_ENV"
          value = var.environment
        }

        env {
          name  = "LOG_LEVEL"
          value = var.log_level
        }

        # データベース接続情報を個別の環境変数として設定
        env {
          name  = "DB_HOST"
          value = "localhost"
        }

        env {
          name  = "DB_PORT"
          value = "3306"
        }

        env {
          name  = "DB_USER"
          value = local.db_user
        }

        env {
          name  = "DB_NAME"
          value = local.database
        }

        env {
          name  = "DB_SOCKET_PATH"
          value = "/cloudsql/${local.cloud_sql_connection_name}"
        }

        # Secret Manager からの環境変数
        env {
          name = "DB_PASSWORD"
          value_source {
            secret_key_ref {
              secret  = google_secret_manager_secret.db_password.secret_id
              version = "latest"
            }
          }
        }

        # GCS設定
        env {
          name  = "GCS_AUDIO_BUCKET"
          value = google_storage_bucket.audio_files.name
        }

        # Cloud SQL ボリュームマウント
        volume_mounts {
          name       = "cloudsql"
          mount_path = "/cloudsql"
        }
      }
    }
  }

  depends_on = [
    google_project_service.required_apis,
    google_sql_database_instance.main,
    google_secret_manager_secret_version.db_password,
    google_vpc_access_connector.main,
    google_storage_bucket.audio_files
  ]

  lifecycle {
    ignore_changes = [
      template[0].template[0].containers[0].image
    ]
  }
}

# Cloud Run Job (日次要約処理用)
resource "google_cloud_run_v2_job" "daily_summary" {
  name     = "daily-summary-job"
  location = var.region

  labels = local.labels

  template {
    # ジョブレベルの設定
    parallelism = 1
    task_count  = 1

    template {
      service_account = google_service_account.cloud_run.email

      # VPCアクセス設定
      vpc_access {
        connector = google_vpc_access_connector.main.id
        egress    = "ALL_TRAFFIC"
      }

      # Cloud SQL接続設定
      volumes {
        name = "cloudsql"
        cloud_sql_instance {
          instances = [local.cloud_sql_connection_name]
        }
      }

      containers {
        image = var.container_image

        # 日次要約処理を実行
        command = ["pnpm"]
        args    = ["run", "run-job:dailySummary"]

        resources {
          limits = {
            cpu    = "2000m"
            memory = "2Gi"
          }
        }

        # 環境変数
        env {
          name  = "NODE_ENV"
          value = var.environment
        }

        env {
          name  = "LOG_LEVEL"
          value = var.log_level
        }

        # データベース接続情報を個別の環境変数として設定
        env {
          name  = "DB_HOST"
          value = "localhost"
        }

        env {
          name  = "DB_PORT"
          value = "3306"
        }

        env {
          name  = "DB_USER"
          value = local.db_user
        }

        env {
          name  = "DB_NAME"
          value = local.database
        }

        env {
          name  = "DB_SOCKET_PATH"
          value = "/cloudsql/${local.cloud_sql_connection_name}"
        }

        # Secret Manager からの環境変数
        env {
          name = "DB_PASSWORD"
          value_source {
            secret_key_ref {
              secret  = google_secret_manager_secret.db_password.secret_id
              version = "latest"
            }
          }
        }

        # GCS設定
        env {
          name  = "GCS_AUDIO_BUCKET"
          value = google_storage_bucket.audio_files.name
        }

        # Cloud SQL ボリュームマウント
        volume_mounts {
          name       = "cloudsql"
          mount_path = "/cloudsql"
        }
      }
    }
  }

  depends_on = [
    google_project_service.required_apis,
    google_sql_database_instance.main,
    google_secret_manager_secret_version.db_password,
    google_vpc_access_connector.main,
    google_storage_bucket.audio_files
  ]

  lifecycle {
    ignore_changes = [
      template[0].template[0].containers[0].image
    ]
  }
}