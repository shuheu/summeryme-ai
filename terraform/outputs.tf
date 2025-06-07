# Outputs for Summeryme AI Backend
# Terraform Configuration

# =============================================================================
# Cloud Run Service
# =============================================================================

output "cloud_run_service_url" {
  description = "Public URL of the Cloud Run service"
  value       = google_cloud_run_v2_service.main.uri
}

output "cloud_run_service_name" {
  description = "Name of the Cloud Run service"
  value       = google_cloud_run_v2_service.main.name
}

output "cloud_run_service_location" {
  description = "Location/region of the Cloud Run service"
  value       = google_cloud_run_v2_service.main.location
}

output "cloud_run_service_id" {
  description = "Full resource ID of the Cloud Run service"
  value       = google_cloud_run_v2_service.main.id
}

# =============================================================================
# VPC Network
# =============================================================================

output "vpc_network_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.main.name
}

output "vpc_network_id" {
  description = "ID of the VPC network"
  value       = google_compute_network.main.id
}

output "vpc_subnet_name" {
  description = "Name of the VPC subnet"
  value       = google_compute_subnetwork.main.name
}

output "vpc_subnet_cidr" {
  description = "CIDR range of the VPC subnet"
  value       = google_compute_subnetwork.main.ip_cidr_range
}

output "vpc_connector_name" {
  description = "Name of the VPC access connector"
  value       = google_vpc_access_connector.main.name
}

# =============================================================================
# Cloud SQL Database
# =============================================================================

output "cloud_sql_instance_name" {
  description = "Name of the Cloud SQL instance"
  value       = google_sql_database_instance.main.name
}

output "cloud_sql_instance_connection_name" {
  description = "Connection name for Cloud SQL Proxy (format: project:region:instance)"
  value       = google_sql_database_instance.main.connection_name
}

output "cloud_sql_instance_ip_address" {
  description = "Private IP address of the Cloud SQL instance"
  value       = google_sql_database_instance.main.private_ip_address
  sensitive   = true
}

output "cloud_sql_instance_public_ip_address" {
  description = "Public IP address of the Cloud SQL instance (if enabled)"
  value       = google_sql_database_instance.main.public_ip_address
  sensitive   = true
}

output "database_name" {
  description = "Name of the application database"
  value       = google_sql_database.main.name
}

output "database_user" {
  description = "Database user name for application connections"
  value       = google_sql_user.main.name
}

# =============================================================================
# Secret Manager
# =============================================================================

output "db_password_secret_id" {
  description = "Secret Manager secret ID for database password"
  value       = google_secret_manager_secret.db_password.secret_id
}

output "db_password_secret_name" {
  description = "Full resource name of the database password secret"
  value       = google_secret_manager_secret.db_password.name
}

# =============================================================================
# Service Accounts
# =============================================================================

output "cloud_run_service_account_email" {
  description = "Email address of the Cloud Run service account"
  value       = google_service_account.cloud_run.email
}

output "cloud_run_service_account_id" {
  description = "Unique ID of the Cloud Run service account"
  value       = google_service_account.cloud_run.unique_id
}

output "github_actions_service_account_email" {
  description = "Email address of the GitHub Actions service account"
  value       = google_service_account.github_actions.email
}

output "github_actions_service_account_id" {
  description = "Unique ID of the GitHub Actions service account"
  value       = google_service_account.github_actions.unique_id
}

# =============================================================================
# Migration Job
# =============================================================================

output "migration_job_name" {
  description = "Name of the Cloud Run migration job"
  value       = google_cloud_run_v2_job.migrate.name
}

output "migration_job_location" {
  description = "Location of the Cloud Run migration job"
  value       = google_cloud_run_v2_job.migrate.location
}

# =============================================================================
# Project Information
# =============================================================================

output "project_id" {
  description = "Google Cloud Project ID where resources are deployed"
  value       = var.project_id
}

output "region" {
  description = "Google Cloud Region where resources are deployed"
  value       = var.region
}

output "environment" {
  description = "Environment name (development, staging, production)"
  value       = var.environment
}

# =============================================================================
# Useful Commands
# =============================================================================

output "useful_commands" {
  description = "Useful commands for managing the deployed resources"
  value = {
    # Cloud Run commands
    deploy_command = "gcloud run deploy ${google_cloud_run_v2_service.main.name} --source . --region=${var.region}"
    logs_command   = "gcloud logging read \"resource.type=cloud_run_revision AND resource.labels.service_name=${google_cloud_run_v2_service.main.name}\" --limit=50"

    # Migration commands
    migrate_command = "gcloud run jobs execute ${google_cloud_run_v2_job.migrate.name} --region=${var.region}"

    # Database commands
    sql_proxy_command  = "./cloud-sql-proxy ${google_sql_database_instance.main.connection_name} --port=3306"
    stop_sql_command   = "make stop-sql"
    start_sql_command  = "make start-sql"
    sql_status_command = "make sql-status"

    # Secret commands
    get_password_command = "gcloud secrets versions access latest --secret=\"${google_secret_manager_secret.db_password.secret_id}\""
  }
}

# =============================================================================
# Resource Summary
# =============================================================================

output "resource_summary" {
  description = "Summary of all created resources"
  value = {
    cloud_run_service = {
      name     = google_cloud_run_v2_service.main.name
      url      = google_cloud_run_v2_service.main.uri
      location = google_cloud_run_v2_service.main.location
    }

    vpc_network = {
      name      = google_compute_network.main.name
      subnet    = google_compute_subnetwork.main.name
      connector = google_vpc_access_connector.main.name
    }

    cloud_sql_instance = {
      name            = google_sql_database_instance.main.name
      connection_name = google_sql_database_instance.main.connection_name
      database        = google_sql_database.main.name
      user            = google_sql_user.main.name
    }

    service_accounts = {
      cloud_run      = google_service_account.cloud_run.email
      github_actions = google_service_account.github_actions.email
    }

    secrets = {
      db_password = google_secret_manager_secret.db_password.secret_id
    }
  }
}

# =============================================================================
# Artifact Registry
# =============================================================================

output "artifact_registry_repository_name" {
  description = "Name of the Artifact Registry repository"
  value       = google_artifact_registry_repository.backend.name
}

output "artifact_registry_repository_url" {
  description = "URL of the Artifact Registry repository"
  value       = "${google_artifact_registry_repository.backend.location}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.backend.repository_id}"
}

output "container_image_url" {
  description = "Full URL of the container image used for deployment"
  value       = var.container_image
}

# =============================================================================
# Backend Configuration
# =============================================================================

output "backend_configuration" {
  description = "GCS backend configuration for Terraform state management"
  value = {
    bucket       = "${var.project_id}-terraform-state"
    prefix       = "summeryme-ai/backend"
    init_command = "terraform init -backend-config=\"bucket=${var.project_id}-terraform-state\" -backend-config=\"prefix=summeryme-ai/backend\""
  }
}