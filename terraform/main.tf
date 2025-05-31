# Summeryme AI Backend - Main Configuration
#
# このファイルは、Terraformの設定ファイルの中心となるファイルです。
# 各リソースは機能別に分離されたファイルで管理されています。
#
# ファイル構成:
# - providers.tf    : プロバイダー設定
# - locals.tf       : ローカル変数
# - variables.tf    : 入力変数
# - outputs.tf      : 出力値
# - apis.tf         : Google Cloud APIs
# - secrets.tf      : Secret Manager
# - cloud_sql.tf    : Cloud SQL
# - iam.tf          : IAM (サービスアカウント・権限)
# - cloud_run.tf    : Cloud Run (サービス・ジョブ)
#
# 使用方法:
# 1. terraform init
# 2. terraform plan
# 3. terraform apply

# このファイルは意図的に空にしています。
# 全てのリソースは機能別のファイルに分離されています。