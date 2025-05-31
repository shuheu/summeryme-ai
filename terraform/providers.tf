# プロバイダー設定
# Summeryme AI Backend

terraform {
  required_version = ">= 1.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.45"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.45"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }

  # リモートバックエンド設定（本番環境では有効化推奨）
  # backend "gcs" {
  #   bucket = "your-terraform-state-bucket"
  #   prefix = "summeryme-ai/backend"
  # }
}

# Google Cloud Provider
provider "google" {
  project = var.project_id
  region  = var.region
}

# Google Cloud Beta Provider
provider "google-beta" {
  project = var.project_id
  region  = var.region
}