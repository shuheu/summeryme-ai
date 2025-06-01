import { serve } from '@hono/node-server';
import { Hono } from 'hono';

import savedArticleRouter from './apis/savedArticle.js';
import userDailySummaryRouter from './apis/userDailySummery.js';
import { globalPrisma } from './lib/dbClient.js';

const app = new Hono();

console.log('DATABASE_URL:', process.env.DATABASE_URL);

app.get('/', (c) => {
  return c.text('Hello summeryme.ai!');
});

// 基本的なヘルスチェック（データベース接続なし）
app.get('/health/basic', (c) => {
  return c.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
    database_url: process.env.DATABASE_URL,
    service: 'backend-api',
  });
});

// 完全なヘルスチェック（データベース接続含む）
app.get('/health', async (c) => {
  try {
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

app.route('/api/saved-articles', savedArticleRouter);
app.route('/api/user-daily-summaries', userDailySummaryRouter);

// Prismaクライアントの接続を適切に終了
process.on('SIGINT', async () => {
  await globalPrisma.$disconnect();
  process.exit(0);
});

process.on('SIGTERM', async () => {
  await globalPrisma.$disconnect();
  process.exit(0);
});

serve(
  {
    fetch: app.fetch,
    port: Number(process.env.PORT) || 8080,
  },
  (info) => {
    console.log(`Server is running on http://localhost:${info.port}`);
  },
);
