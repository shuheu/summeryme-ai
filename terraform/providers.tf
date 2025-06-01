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

  # GCSリモートバックエンド設定
  # 注意: backendブロックでは変数を使用できないため、固定値を使用
  # バケット名は初期化時に -backend-config で動的に指定
  backend "gcs" {
    prefix = "summeryme-ai/backend"
  }
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