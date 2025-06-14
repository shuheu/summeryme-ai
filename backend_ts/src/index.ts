import { serve } from '@hono/node-server';
import { Hono } from 'hono';
import { cors } from 'hono/cors';
import { logger } from 'hono/logger';

import savedArticleRouter from './apis/savedArticle.js';
import userDailySummaryRouter from './apis/userDailySummery.js';

import type { PrismaClient } from '@prisma/client/extension';

// Prismaクライアントのインポートを遅延させる
let globalPrisma: PrismaClient;

const app = new Hono();

// ログミドルウェアを追加
app.use('*', logger());

// CORS設定を追加（Web環境での利用のため）
const isDevelopment = process.env.NODE_ENV !== 'production';

app.use(
  '*',
  cors({
    origin: isDevelopment
      ? '*'
      : [
          'https://summeryme-ai.web.app', // TODO: 本番環境のドメイン（例）
        ],
    allowMethods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
    allowHeaders: ['Content-Type', 'Authorization'],
    credentials: false,
  }),
);

app.get('/', (c) => {
  return c.text('Hello summeryme.ai!');
});

// 基本的なヘルスチェック（データベース接続なし）
app.get('/health/basic', (c) => {
  return c.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
    service: 'backend-api',
  });
});

// 完全なヘルスチェック（データベース接続含む）
app.get('/health', async (c) => {
  try {
    // Prismaクライアントを動的にインポート
    if (!globalPrisma) {
      console.log('Dynamically importing Prisma client...');
      const { globalPrisma: prisma } = await import('./lib/dbClient.js');
      globalPrisma = prisma;
    }

    // データベース接続をテスト
    await globalPrisma.$queryRaw`SELECT 1`;

    return c.json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
      environment: process.env.NODE_ENV || 'development',
      database: 'connected',
    });
  } catch (error) {
    console.error('Health check failed:', error);
    console.error('DB_HOST at error time:', !!process.env.DB_HOST);
    console.error('DB_PASSWORD at error time:', !!process.env.DB_PASSWORD);

    return c.json(
      {
        status: 'unhealthy',
        timestamp: new Date().toISOString(),
        environment: process.env.NODE_ENV || 'development',
        database: 'disconnected',
        error: error instanceof Error ? error.message : 'Unknown error',
      },
      503,
    );
  }
});

// 動的にルーターをインポート
app.route('/api/saved-articles', savedArticleRouter);
app.route('/api/user-daily-summaries', userDailySummaryRouter);

// Prismaクライアントの接続を適切に終了
process.on('SIGINT', async () => {
  if (globalPrisma) {
    await globalPrisma.$disconnect();
  }
  process.exit(0);
});

process.on('SIGTERM', async () => {
  if (globalPrisma) {
    await globalPrisma.$disconnect();
  }
  process.exit(0);
});

serve(
  {
    fetch: app.fetch,
    port: Number(process.env.PORT) || 8080,
  },
  (info) => {
    console.log(`🚀 Server is running on http://localhost:${info.port}`);
  },
);
