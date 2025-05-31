# Cloud SQL
# Summeryme AI Backend

# Cloud SQL インスタンス
resource "google_sql_database_instance" "main" {
  name                = local.db_name
  database_version    = "MYSQL_8_0"
  region              = var.region
  deletion_protection = local.db_settings.deletion_protection

  settings {
    tier              = var.db_tier
    availability_type = "ZONAL" # ハッカソン用：高可用性オフ

    disk_type       = "PD_HDD"
    disk_size       = var.db_disk_size
    disk_autoresize = false

    backup_configuration {
      enabled            = false # ハッカソン用：バックアップ無効 local.db_settings.backup_enabled
      start_time         = "04:00"
      binary_log_enabled = false # ハッカソン用：バイナリログ無効 local.db_settings.binary_log_enabled

      backup_retention_settings {
        retained_backups = local.db_settings.retained_backups
      }
    }

    maintenance_window {
      day          = 7 # Sunday
      hour         = 4 # 4 AM
      update_track = "stable"
    }

    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.main.id
      ssl_mode        = "ALLOW_UNENCRYPTED_AND_ENCRYPTED"
    }

    database_flags {
      name  = "character_set_server"
      value = "utf8mb4"
    }

    database_flags {
      name  = "collation_server"
      value = "utf8mb4_unicode_ci"
    }

    user_labels = local.labels
  }

  depends_on = [
    google_project_service.required_apis,
    google_service_networking_connection.private_vpc_connection
  ]

  lifecycle {
    prevent_destroy = true
  }
}

# データベース作成
resource "google_sql_database" "main" {
  name      = local.database
  instance  = google_sql_database_instance.main.name
  charset   = "utf8mb4"
  collation = "utf8mb4_unicode_ci"
}

# データベースユーザー作成
resource "google_sql_user" "main" {
  name     = local.db_user
  instance = google_sql_database_instance.main.name
  password = random_password.db_password.result

  depends_on = [google_sql_database_instance.main]
}