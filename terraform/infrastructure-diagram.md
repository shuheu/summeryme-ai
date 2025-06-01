# Summeryme AI Backend - インフラ構成図

## アーキテクチャ概要

このドキュメントは、Terraformで管理されているSummeryme AI Backendのインフラ構成を視覚化したものです。

## インフラ構成図

```mermaid
flowchart TB
    %% Internet Layer
    subgraph Internet["🌐 Internet"]
        User[👤 Users]
        GitHub[🔧 GitHub Actions]
    end

    %% Google Cloud Platform
    subgraph GCP["☁️ Google Cloud Platform"]

        %% Compute Services
        subgraph Compute["💻 Compute Services"]
            CloudRun[📦 Cloud Run Service<br/>Hono + TypeScript<br/>Port: 8080]
            MigrationJob[⚙️ Migration Job<br/>Prisma Migrate]
        end

        %% VPC Network
        subgraph VPC["🔗 VPC Network"]
            VPCConnector[🔌 VPC Connector<br/>10.8.0.0/28]
            Subnet[🏠 Private Subnet<br/>10.0.0.0/24<br/>Private Google Access]
        end

        %% Storage & Secrets
        subgraph Storage["💾 Storage & Secrets"]
            CloudSQL[🗄️ Cloud SQL MySQL 8.0<br/>db-f1-micro<br/>Private IP Only]
            SecretManager[🔐 Secret Manager<br/>DB Password]
        end

        %% Security & IAM
        subgraph Security["🛡️ Security & IAM"]
            SA_CloudRun[👤 Cloud Run SA<br/>SQL Client<br/>Secret Accessor]
            SA_GitHub[👤 GitHub Actions SA<br/>Run Admin<br/>SQL Admin]
        end
    end

    %% User Flow
    User -->|HTTPS Requests| CloudRun
    GitHub -->|Deploy| CloudRun
    GitHub -->|Migrate| MigrationJob

    %% Network Flow (Private Resources Only)
    CloudRun -->|Private Access| VPCConnector
    MigrationJob -->|Private Access| VPCConnector
    VPCConnector --> Subnet

    %% Direct Internet Access (No NAT needed)
    CloudRun -.->|Direct Internet<br/>Google APIs| Internet
    MigrationJob -.->|Direct Internet<br/>Google APIs| Internet

    %% Database Connections
    CloudRun -.->|Private Connection| CloudSQL
    MigrationJob -.->|Private Connection| CloudSQL

    %% Secret Access
    CloudRun -.->|Read Secrets| SecretManager
    MigrationJob -.->|Read Secrets| SecretManager

    %% IAM Relationships
    SA_CloudRun -.->|Assumes| CloudRun
    SA_CloudRun -.->|Access| CloudSQL
    SA_CloudRun -.->|Access| SecretManager

    SA_GitHub -.->|Assumes| GitHub
    SA_GitHub -.->|Deploy| CloudRun
    SA_GitHub -.->|Execute| MigrationJob

    %% Styling
    classDef internetClass fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    classDef computeClass fill:#f3e5f5,stroke:#4a148c,stroke-width:2px
    classDef networkClass fill:#e8f5e8,stroke:#1b5e20,stroke-width:2px
    classDef storageClass fill:#fff3e0,stroke:#e65100,stroke-width:2px
    classDef securityClass fill:#ffebee,stroke:#b71c1c,stroke-width:2px

    class User,GitHub internetClass
    class CloudRun,MigrationJob computeClass
    class VPCConnector,Subnet networkClass
    class CloudSQL,SecretManager storageClass
    class SA_CloudRun,SA_GitHub securityClass
```

## 簡略版構成図（C4 Context Level）

```mermaid
C4Context
    title Summeryme AI Backend - System Context

    Person(user, "Users", "エンドユーザー")
    System_Ext(github, "GitHub Actions", "CI/CDパイプライン")

    System_Boundary(gcp, "Google Cloud Platform") {
        System(backend, "Backend API", "Hono + TypeScript<br/>Cloud Run")
        SystemDb(database, "Database", "Cloud SQL MySQL")
        System(secrets, "Secret Manager", "パスワード管理")
    }

    Rel(user, backend, "HTTPS API calls")
    Rel(github, backend, "Deploy")
    Rel(backend, database, "SQL queries", "Private network")
    Rel(backend, secrets, "Read secrets")
```

## ネットワーク詳細図

```mermaid
flowchart LR
    subgraph External["外部"]
        U[👤 User]
        G[🔧 GitHub]
        APIs[🌐 Google APIs]
    end

    subgraph GCP["Google Cloud Platform"]
        subgraph CloudRun["Cloud Run (Managed)"]
            CR[📦 Cloud Run Service<br/>Direct Internet Access]
        end

        subgraph VPC["VPC: 10.0.0.0/24"]
            VC[🔌 VPC Connector<br/>10.8.0.0/28]

            subgraph Private["プライベート"]
                SQL[🗄️ Cloud SQL<br/>Private IP]
                SM[🔐 Secret Manager]
            end
        end
    end

    U -->|HTTPS| CR
    G -->|Deploy API| CR
    CR -->|Direct Access| APIs
    CR -->|VPC Access<br/>Private Resources Only| VC
    VC -.->|Private| SQL
    CR -.->|API Access| SM

    %% Styling
    classDef external fill:#e3f2fd,stroke:#1976d2
    classDef cloudrun fill:#f1f8e9,stroke:#388e3c
    classDef private fill:#fce4ec,stroke:#c2185b
    classDef network fill:#fff8e1,stroke:#f57c00

    class U,G,APIs external
    class CR cloudrun
    class SQL,SM private
    class VC network
```

## 主要コンポーネント

### 🌐 Internet Layer
- **Users**: エンドユーザーからのHTTPSリクエスト
- **GitHub Actions**: CI/CDパイプラインからのデプロイ

### ☁️ Google Cloud Platform

#### Compute Services
- **Cloud Run Service**: メインのバックエンドAPI（Hono + TypeScript）
  - ポート: 8080
  - 自動スケーリング: 0-10インスタンス
  - ヘルスチェック: `/health`エンドポイント
- **Migration Job**: Prismaマイグレーション実行用ジョブ

#### VPC Network
- **VPC Connector**: Cloud RunとVPC間の接続
  - IP範囲: `10.8.0.0/28`
- **Private Subnet**: プライベートネットワーク
  - IP範囲: `10.0.0.0/24`
- **Cloud Router**: VPCルーティング管理
- **Cloud NAT**: アウトバウンドインターネットアクセス

#### Storage & Secrets
- **Cloud SQL MySQL**: メインデータベース
  - バージョン: MySQL 8.0
  - ティア: db-f1-micro
  - プライベート接続のみ
- **Secret Manager**: データベースパスワード管理

#### Security & IAM
- **Cloud Run Service Account**: Cloud Run用の最小権限
  - Cloud SQL Client
  - Secret Manager Accessor
- **GitHub Actions Service Account**: CI/CD用権限
  - Cloud Run Admin
  - Cloud SQL Admin
  - Secret Manager Admin

## ネットワークフロー

### 1. ユーザーリクエスト
```
User → Cloud Run Service (Direct HTTPS) → VPC Connector → Private Subnet → Cloud SQL
```

### 2. デプロイメント
```
GitHub Actions → Cloud Run Service (新バージョンデプロイ)
GitHub Actions → Migration Job (データベースマイグレーション)
```

### 3. アウトバウンド通信
```
Cloud Run → Direct Internet Access (Google Frontend経由)
※ Cloud NATは不要 - Cloud Runは直接インターネットアクセス可能
```

### 4. プライベートリソースアクセス
```
Cloud Run → VPC Connector → Private Subnet → Cloud SQL (Private IP)
Cloud Run → Secret Manager (Google APIs経由)
```

## セキュリティ特徴

- **プライベートネットワーク**: Cloud SQLはプライベートIPのみ
- **最小権限の原則**: 各サービスアカウントは必要最小限の権限
- **Secret管理**: パスワードはSecret Managerで暗号化保存
- **VPC分離**: 全てのリソースがプライベートVPC内で動作

## 監視・ログ

- Cloud Runの自動ログ収集
- ヘルスチェックによる可用性監視
- Cloud SQLの接続監視
- VPCフローログ（エラーのみ）

---

**生成日**: 2025/05/31
**Terraformバージョン**: 1.5+
**プロジェクト**: Summeryme AI Backend