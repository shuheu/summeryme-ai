# Terraform Outputs for Summeryme AI Backend

# Cloud Run Service
output "cloud_run_service_url" {
  description = "URL of the Cloud Run service"
  value       = google_cloud_run_v2_service.main.uri
}

output "cloud_run_service_name" {
  description = "Name of the Cloud Run service"
  value       = google_cloud_run_v2_service.main.name
}

output "cloud_run_service_location" {
  description = "Location of the Cloud Run service"
  value       = google_cloud_run_v2_service.main.location
}

# Cloud SQL
output "cloud_sql_instance_name" {
  description = "Name of the Cloud SQL instance"
  value       = google_sql_database_instance.main.name
}

output "cloud_sql_instance_connection_name" {
  description = "Connection name of the Cloud SQL instance"
  value       = google_sql_database_instance.main.connection_name
}

output "cloud_sql_instance_ip_address" {
  description = "IP address of the Cloud SQL instance"
  value       = google_sql_database_instance.main.ip_address
  sensitive   = true
}

output "database_name" {
  description = "Name of the database"
  value       = google_sql_database.main.name
}

output "database_user" {
  description = "Database user name"
  value       = google_sql_user.main.name
}

# Secret Manager
output "db_password_secret_id" {
  description = "Secret Manager secret ID for database password"
  value       = google_secret_manager_secret.db_password.secret_id
}

# Service Account
output "service_account_email" {
  description = "Email of the Cloud Run service account"
  value       = google_service_account.cloud_run.email
}

# Migration Job
output "migration_job_name" {
  description = "Name of the migration job"
  value       = google_cloud_run_v2_job.migrate.name
}

# Project Information
output "project_id" {
  description = "Google Cloud Project ID"
  value       = var.project_id
}

output "region" {
  description = "Google Cloud Region"
  value       = var.region
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}