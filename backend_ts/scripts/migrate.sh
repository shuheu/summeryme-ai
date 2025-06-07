#!/bin/bash
set -e

echo "=== Starting Prisma Migration ==="

# 必要な環境変数の確認
echo "Checking environment variables..."
if [ -z "$DB_HOST" ] || [ -z "$DB_PORT" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ] || [ -z "$DB_NAME" ]; then
  echo "❌ Missing required database environment variables"
  exit 1
fi

echo "✅ Database environment variables are set"
echo "DB_HOST: $DB_HOST"
echo "DB_PORT: $DB_PORT"
echo "DB_USER: $DB_USER"
echo "DB_NAME: $DB_NAME"
echo "DB_SOCKET_PATH: $DB_SOCKET_PATH"

# DATABASE_URLの動的構築
if [ -n "$DB_SOCKET_PATH" ]; then
  # Cloud SQL Proxy（Unix Socket）接続
  export DATABASE_URL="mysql://$DB_USER:$DB_PASSWORD@localhost/$DB_NAME?socket=$DB_SOCKET_PATH"
  echo "✅ Using Cloud SQL Proxy connection"
else
  # TCP接続
  export DATABASE_URL="mysql://$DB_USER:$DB_PASSWORD@$DB_HOST:$DB_PORT/$DB_NAME"
  echo "✅ Using TCP connection"
fi

echo "DATABASE_URL configured (password hidden)"

# Prismaクライアントの生成
echo "Generating Prisma Client..."
npx prisma generate

# マイグレーションの実行
echo "Running Prisma migrations..."
npx prisma migrate deploy

echo "✅ Migration completed successfully!"
