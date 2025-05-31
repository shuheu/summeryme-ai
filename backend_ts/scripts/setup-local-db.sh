#!/bin/bash

# ローカル開発環境用 Cloud SQL Proxy セットアップスクリプト
# Summeryme AI Backend

set -e

echo "🚀 Cloud SQL Proxy セットアップを開始します..."

# プロジェクトIDを取得
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
if [ -z "$PROJECT_ID" ]; then
  echo "❌ エラー: GCPプロジェクトIDが設定されていません"
  echo "以下のコマンドでプロジェクトを設定してください:"
  echo "  gcloud config set project YOUR_PROJECT_ID"
  exit 1
fi

echo "✅ 使用中のプロジェクト: $PROJECT_ID"

# Cloud SQL Proxyの存在確認
if ! command -v cloud-sql-proxy &>/dev/null; then
  echo "📦 Cloud SQL Proxyをインストールしています..."

  # macOSの場合はHomebrewでインストールを試行
  if [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v brew &>/dev/null; then
      brew install cloud-sql-proxy
    else
      echo "❌ Homebrewがインストールされていません"
      echo "手動でCloud SQL Proxyをインストールしてください:"
      echo "https://cloud.google.com/sql/docs/mysql/sql-proxy#install"
      exit 1
    fi
  else
    echo "❌ 自動インストールはmacOSのみサポートしています"
    echo "手動でCloud SQL Proxyをインストールしてください:"
    echo "https://cloud.google.com/sql/docs/mysql/sql-proxy#install"
    exit 1
  fi
fi

echo "✅ Cloud SQL Proxy: $(cloud-sql-proxy --version)"

# 認証確認
echo "🔐 認証状況を確認しています..."
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1 >/dev/null; then
  echo "❌ Google Cloud認証が必要です"
  echo "以下のコマンドで認証してください:"
  echo "  gcloud auth login"
  exit 1
fi

ACTIVE_ACCOUNT=$(gcloud auth list --filter=status:ACTIVE --format="value(account)" | head -n1)
echo "✅ 認証済みアカウント: $ACTIVE_ACCOUNT"

# Cloud SQLインスタンス確認
echo "🗄️ Cloud SQLインスタンスを確認しています..."
INSTANCE_NAME="summeryme-db"
REGION="asia-northeast1"

if ! gcloud sql instances describe $INSTANCE_NAME &>/dev/null; then
  echo "❌ Cloud SQLインスタンス '$INSTANCE_NAME' が見つかりません"
  echo "Terraformでインフラを作成してください:"
  echo "  cd terraform && make apply"
  exit 1
fi

echo "✅ Cloud SQLインスタンス '$INSTANCE_NAME' が見つかりました"

# 接続文字列を生成
CONNECTION_NAME="$PROJECT_ID:$REGION:$INSTANCE_NAME"
LOCAL_PORT="3306"

echo ""
echo "🎯 セットアップ完了！"
echo ""
echo "=== Cloud SQL Proxy 起動コマンド ==="
echo "cloud-sql-proxy $CONNECTION_NAME --port=$LOCAL_PORT"
echo ""
echo "=== ローカル接続用 DATABASE_URL ==="
echo "DATABASE_URL=\"mysql://summeryme_user:YOUR_PASSWORD@localhost:$LOCAL_PORT/summeryme_production\""
echo ""
echo "=== 使用手順 ==="
echo "1. 新しいターミナルでCloud SQL Proxyを起動:"
echo "   cloud-sql-proxy $CONNECTION_NAME --port=$LOCAL_PORT"
echo ""
echo "2. データベースパスワードを取得:"
echo "   gcloud secrets versions access latest --secret=\"db-password\""
echo ""
echo "3. .env.localファイルにDATABASE_URLを設定"
echo ""
echo "4. アプリケーションを起動:"
echo "   pnpm dev"
echo ""

# .env.localファイルのサンプル作成
if [ ! -f .env.local ]; then
  echo "📝 .env.localファイルのサンプルを作成しています..."
  cat >.env.local <<EOF
# ローカル開発環境用設定
# Cloud SQL Proxy経由でデータベースに接続

# データベース接続（パスワードは手動で設定してください）
DATABASE_URL="mysql://summeryme_user:YOUR_PASSWORD@localhost:3306/summeryme_production"

# 開発環境設定
NODE_ENV="development"
LOG_LEVEL="debug"

# パスワード取得コマンド:
# gcloud secrets versions access latest --secret="db-password"
EOF
  echo "✅ .env.localファイルを作成しました"
  echo "   パスワードを手動で設定してください"
fi

echo ""
echo "🎉 セットアップが完了しました！"
