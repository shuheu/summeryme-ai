# Terraform Version Constraints

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

  # Terraform Cloud / Terraform Enterprise を使用する場合
  # cloud {
  #   organization = "your-organization"
  #   workspaces {
  #     name = "summeryme-ai-backend"
  #   }
  # }

  # ローカルでstateファイルを管理する場合（推奨しない）
  # backend "local" {
  #   path = "terraform.tfstate"
  # }

  # Google Cloud Storage でstateファイルを管理する場合（推奨）
  # backend "gcs" {
  #   bucket = "your-terraform-state-bucket"
  #   prefix = "summeryme-ai/backend"
  # }
}