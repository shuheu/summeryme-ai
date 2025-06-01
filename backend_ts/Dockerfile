FROM node:22-bookworm-slim

RUN corepack enable && corepack prepare pnpm@latest --activate
RUN apt-get update -y && apt-get install -y openssl && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 依存関係のインストール（開発依存関係も含む）
COPY package.json pnpm-lock.yaml* ./
RUN pnpm install --frozen-lockfile

# ソースコードのコピー
COPY . /app/

# Prismaクライアントの生成
RUN npx prisma generate

# TypeScriptのビルド
RUN pnpm run build

# Prismaの生成されたファイルを正しいパスにコピー（@/エイリアス対応）
RUN mkdir -p dist/src/prisma/generated && cp -r src/prisma/generated/* dist/src/prisma/generated/

# デバッグ: ファイル構造を確認
RUN echo "=== Checking dist structure ===" && \
    ls -la dist/ && \
    echo "=== Checking prisma structure ===" && \
    ls -la dist/prisma/ && \
    echo "=== Checking generated structure ===" && \
    ls -la dist/prisma/generated/ || echo "Generated directory not found"

# 本番依存関係のみを再インストール
RUN pnpm install --frozen-lockfile --prod && pnpm store prune

# 本番環境用の設定
ENV NODE_ENV=production
EXPOSE 8080

# 本番サーバーの起動
CMD ["pnpm", "run", "start"]