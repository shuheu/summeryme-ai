# Terraform Variables for Summeryme AI Backend

# 基本設定
variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
  default     = "numeric-skill-460414-d3"
}

variable "region" {
  description = "Google Cloud Region"
  type        = string
  default     = "asia-northeast1"
}

variable "environment" {
  description = "Environment name (development, staging, production)"
  type        = string
  default     = "production"

  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be one of: development, staging, production."
  }
}

# Cloud SQL設定
variable "db_tier" {
  description = "Cloud SQL instance tier"
  type        = string
  default     = "db-f1-micro"
}

variable "db_disk_size" {
  description = "Cloud SQL disk size in GB"
  type        = number
  default     = 10
}

# Cloud Run設定
variable "container_image" {
  description = "Container image for Cloud Run service"
  type        = string
  default     = "asia-northeast1-docker.pkg.dev/numeric-skill-460414-d3/cloud-run-source-deploy/backend-api:latest"
}

variable "cpu_limit" {
  description = "CPU limit for Cloud Run service"
  type        = string
  default     = "1000m"
}

variable "memory_limit" {
  description = "Memory limit for Cloud Run service"
  type        = string
  default     = "1Gi"
}

variable "min_instances" {
  description = "Minimum number of Cloud Run instances"
  type        = number
  default     = 0
}

variable "max_instances" {
  description = "Maximum number of Cloud Run instances"
  type        = number
  default     = 10
}

variable "log_level" {
  description = "Application log level"
  type        = string
  default     = "info"

  validation {
    condition     = contains(["debug", "info", "warn", "error"], var.log_level)
    error_message = "Log level must be one of: debug, info, warn, error."
  }
}

variable "allow_public_access" {
  description = "Allow public access to Cloud Run service"
  type        = bool
  default     = true
}