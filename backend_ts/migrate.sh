#!/bin/bash

# migrate.sh - Prismaマイグレーション実行スクリプト
# DATABASE_URLの変数展開を行ってからマイグレーションを実行

set -e

echo "=== Prisma Migration Script ==="
echo "NODE_ENV: $NODE_ENV"
echo "DATABASE_URL exists: $([ -n "$DATABASE_URL" ] && echo "true" || echo "false")"
echo "DB_PASSWORD exists: $([ -n "$DB_PASSWORD" ] && echo "true" || echo "false")"

# DATABASE_URLの変数展開
if [ -z "$DATABASE_URL" ]; then
  echo "❌ ERROR: DATABASE_URL environment variable is not set"
  exit 1
fi

if [ -z "$DB_PASSWORD" ]; then
  echo "❌ ERROR: DB_PASSWORD environment variable is not set"
  exit 1
fi

# ${DB_PASSWORD}を実際のパスワードに置換
EXPANDED_DATABASE_URL="${DATABASE_URL//\$\{DB_PASSWORD\}/$DB_PASSWORD}"

echo "Original DATABASE_URL contains placeholder: $(echo "$DATABASE_URL" | grep -q '\${DB_PASSWORD}' && echo "true" || echo "false")"
echo "Expanded DATABASE_URL contains placeholder: $(echo "$EXPANDED_DATABASE_URL" | grep -q '\${DB_PASSWORD}' && echo "true" || echo "false")"

# 展開されたDATABASE_URLを環境変数として設定
export DATABASE_URL="$EXPANDED_DATABASE_URL"

echo "✅ DATABASE_URL expanded successfully"
echo "Running Prisma migration..."

# Prismaマイグレーションを実行
npx prisma migrate deploy

echo "✅ Migration completed successfully"
