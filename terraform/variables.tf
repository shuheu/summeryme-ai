# Variables for Summeryme AI Backend
# Terraform Configuration

# =============================================================================
# 基本設定 (Required)
# =============================================================================

variable "project_id" {
  description = "Google Cloud Project ID where resources will be created"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Project ID must be 6-30 characters, start with a letter, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "region" {
  description = "Google Cloud Region for resource deployment"
  type        = string
  default     = "asia-northeast1"

  validation {
    condition = contains([
      "asia-northeast1", "asia-northeast2", "asia-northeast3",
      "asia-southeast1", "asia-southeast2",
      "us-central1", "us-east1", "us-west1",
      "europe-west1", "europe-west2", "europe-west3"
    ], var.region)
    error_message = "Region must be a valid Google Cloud region."
  }
}

variable "environment" {
  description = "Environment name (affects resource naming and configuration)"
  type        = string
  default     = "production"

  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be one of: development, staging, production."
  }
}

# =============================================================================
# Cloud SQL設定
# =============================================================================

variable "db_tier" {
  description = "Cloud SQL instance machine type (affects performance and cost)"
  type        = string
  default     = "db-f1-micro"

  validation {
    condition = contains([
      "db-f1-micro", "db-g1-small",
      "db-n1-standard-1", "db-n1-standard-2", "db-n1-standard-4",
      "db-n1-highmem-2", "db-n1-highmem-4"
    ], var.db_tier)
    error_message = "DB tier must be a valid Cloud SQL machine type."
  }
}

variable "db_disk_size" {
  description = "Cloud SQL disk size in GB (minimum 10GB for MySQL)"
  type        = number
  default     = 10

  validation {
    condition     = var.db_disk_size >= 10 && var.db_disk_size <= 65536
    error_message = "DB disk size must be between 10 and 65536 GB."
  }
}

# =============================================================================
# Cloud Run設定
# =============================================================================

variable "container_image" {
  description = "Container image URL to deploy to Cloud Run"
  type        = string

  validation {
    condition     = can(regex("^(gcr\\.io|.*\\.pkg\\.dev)/.*", var.container_image))
    error_message = "Container image must be from Google Container Registry or Artifact Registry."
  }
}

variable "cpu_limit" {
  description = "CPU limit for Cloud Run service (e.g., '1000m' = 1 vCPU)"
  type        = string
  default     = "1000m"

  validation {
    condition     = can(regex("^[0-9]+m?$", var.cpu_limit))
    error_message = "CPU limit must be in format like '1000m' or '1'."
  }
}

variable "memory_limit" {
  description = "Memory limit for Cloud Run service (e.g., '1Gi', '512Mi')"
  type        = string
  default     = "1Gi"

  validation {
    condition     = can(regex("^[0-9]+(Mi|Gi)$", var.memory_limit))
    error_message = "Memory limit must be in format like '512Mi' or '1Gi'."
  }
}

variable "min_instances" {
  description = "Minimum number of Cloud Run instances (0 = scale to zero)"
  type        = number
  default     = 0

  validation {
    condition     = var.min_instances >= 0 && var.min_instances <= 1000
    error_message = "Min instances must be between 0 and 1000."
  }
}

variable "max_instances" {
  description = "Maximum number of Cloud Run instances"
  type        = number
  default     = 2  # ハッカソン用：コスト最適化

  validation {
    condition     = var.max_instances >= 1 && var.max_instances <= 1000
    error_message = "Max instances must be between 1 and 1000."
  }
}

# =============================================================================
# アプリケーション設定
# =============================================================================

variable "log_level" {
  description = "Application log level (affects verbosity of logs)"
  type        = string
  default     = "info"

  validation {
    condition     = contains(["debug", "info", "warn", "error"], var.log_level)
    error_message = "Log level must be one of: debug, info, warn, error."
  }
}

variable "allow_public_access" {
  description = "Allow unauthenticated public access to Cloud Run service"
  type        = bool
  default     = true
}

# =============================================================================
# 高度な設定 (Optional)
# =============================================================================


