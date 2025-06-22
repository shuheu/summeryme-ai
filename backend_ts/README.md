# Summaryme AI Backend

Hono + TypeScript + Prisma + MySQL を使用したバックエンドAPI

## 🚀 クイックスタート

### ローカル開発

```bash
# 依存関係のインストール
pnpm install

# 環境変数の設定
cp .env.example .env
# .envファイルを編集してDATABASE_URLを設定

# データベースマイグレーション
pnpm prisma migrate dev

# 開発サーバー起動
pnpm dev
```

## 🏗️ 技術スタック

- **フレームワーク**: [Hono](https://hono.dev/) v4.7.10
- **言語**: TypeScript (ESNext, NodeNext)
- **ORM**: [Prisma](https://www.prisma.io/) v6.8.2
- **データベース**: MySQL 8.0
- **ランタイム**: Node.js v22
- **パッケージマネージャー**: pnpm
- **インフラ**: Google Cloud Run + Cloud SQL

## 🏛️ アーキテクチャ

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Cloud Run     │    │   Cloud SQL     │    │ Secret Manager  │
│   (backend-api) │◄──►│  (summeryme-db) │    │  (db-password)  │
│                 │    │                 │    │                 │
│ - Hono Server   │    │ - MySQL 8.0     │    │ - DB Password   │
│ - Prisma ORM    │    │ - db-f1-micro   │    │ - Secure Store  │
│ - TypeScript    │    │ - 10GB HDD      │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🛠️ 開発手順

### 1. 環境セットアップ

```bash
# Node.js v22のインストール（推奨）
nvm install 22
nvm use 22

# pnpmのインストール
npm install -g pnpm

# 依存関係のインストール
pnpm install
```

### 2. データベース設定

```bash
# 環境変数の設定
cp .env.example .env

# .envファイルを編集
# DATABASE_URL="mysql://user:password@localhost:3306/summeryme_dev"

# Prismaクライアント生成
pnpm prisma generate

# マイグレーション実行
pnpm prisma migrate dev
```

### 3. 開発サーバー起動

```bash
# 開発モード（ホットリロード）
pnpm dev

# 本番ビルド
pnpm build

# 本番サーバー起動
pnpm start
```

### 4. データベース操作

```bash
# Prisma Studio（GUI）
pnpm prisma studio

# マイグレーション作成
pnpm prisma migrate dev --name add_new_table

# データベースリセット
pnpm prisma migrate reset
```

---

**最終更新**: 2025-05-31
**バージョン**: 1.0.0
