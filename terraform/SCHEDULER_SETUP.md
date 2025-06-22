# Cloud Scheduler セットアップガイド

このドキュメントでは、バッチジョブのスケジュール実行の設定と動作確認方法について説明します。

## 実装内容

### 1. Cloud Scheduler ジョブ

`cloud_scheduler.tf` で以下の2つのスケジュールジョブを定義しています：

#### 記事要約ジョブ (`article-summary-scheduler`)

- **タイムゾーン**: Asia/Tokyo
- **対象ジョブ**: `article-summary-job`

#### 日次要約ジョブ (`daily-summary-scheduler`)

- **タイムゾーン**: Asia/Tokyo
- **対象ジョブ**: `daily-summary-job`

### 2. セキュリティ設定

- 専用のサービスアカウント `${service_name}-scheduler-sa` を作成
- Cloud Run Jobs を実行するための `roles/run.invoker` 権限を付与

## デプロイ手順

1. Terraform の初期化（まだの場合）:

   ```bash
   cd terraform
   make init
   ```

2. 変更内容の確認:

   ```bash
   make plan
   ```

3. デプロイの実行:

   ```bash
   make apply
   ```

## 動作確認方法

### 1. Cloud Scheduler ジョブの確認

Google Cloud Console から確認:

```bash
gcloud scheduler jobs list --location=asia-northeast1
```

または、Web コンソールから:

https://console.cloud.google.com/cloudscheduler

### 2. 手動実行でのテスト

#### 記事要約ジョブの手動実行:

```bash
gcloud scheduler jobs run article-summary-scheduler --location=asia-northeast1
```

#### 日次要約ジョブの手動実行:

```bash
gcloud scheduler jobs run daily-summary-scheduler --location=asia-northeast1
```

### 3. Cloud Run Job の実行状態確認

```bash
# ジョブの一覧表示
gcloud run jobs list --region=asia-northeast1

# 特定ジョブの実行履歴確認
gcloud run jobs executions list --job=article-summary-job --region=asia-northeast1
gcloud run jobs executions list --job=daily-summary-job --region=asia-northeast1

# 実行ログの確認
gcloud logging read "resource.type=cloud_run_job AND resource.labels.job_name=article-summary-job" --limit=50
gcloud logging read "resource.type=cloud_run_job AND resource.labels.job_name=daily-summary-job" --limit=50
```

### 4. スケジューラーの一時停止/再開

一時停止:

```bash
gcloud scheduler jobs pause article-summary-scheduler --location=asia-northeast1
gcloud scheduler jobs pause daily-summary-scheduler --location=asia-northeast1
```

再開:

```bash
gcloud scheduler jobs resume article-summary-scheduler --location=asia-northeast1
gcloud scheduler jobs resume daily-summary-scheduler --location=asia-northeast1
```

## スケジュール設定の変更

スケジュールを変更する場合は、`cloud_scheduler.tf` の `schedule` パラメータを編集してください。

### cron 形式の例

- `0 */3 * * *` - 3時間ごと
- `0 6 * * *` - 毎日午前6時
- `0 */6 * * *` - 6時間ごと
- `0 0,12 * * *` - 毎日午前0時と午後12時
- `0 9-18 * * 1-5` - 平日の9時から18時まで毎時

変更後は以下を実行:

```bash
cd terraform
make plan
make apply
```

## トラブルシューティング

### ジョブが実行されない場合

1. サービスアカウントの権限を確認:
   ```bash
   gcloud projects get-iam-policy ${PROJECT_ID} --flatten="bindings[].members" --filter="serviceAccount:*scheduler-sa*"
   ```

2. Cloud Scheduler API が有効か確認:
   ```bash
   gcloud services list --enabled | grep cloudscheduler
   ```

3. Cloud Run Job のステータスを確認:
   ```bash
   gcloud run jobs describe article-summary-job --region=asia-northeast1
   gcloud run jobs describe daily-summary-job --region=asia-northeast1
   ```

### ログの詳細確認

Cloud Logging でより詳細なログを確認:
```bash
# Scheduler のログ
gcloud logging read "resource.type=cloud_scheduler_job" --limit=50

# Job 実行のエラーログ
gcloud logging read "severity>=ERROR AND resource.type=cloud_run_job" --limit=50
```

## 注意事項

- スケジュール実行は Asia/Tokyo タイムゾーンで設定されています
- Cloud Run Jobs の同時実行数は1に設定されているため、前の実行が完了してから次が開始されます
- 実行に失敗した場合、Cloud Scheduler は自動的にリトライを行います（デフォルト設定）