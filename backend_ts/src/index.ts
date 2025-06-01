import { serve } from '@hono/node-server';
import { Hono } from 'hono';

import savedArticleRouter from './apis/savedArticle.js';
import userDailySummaryRouter from './apis/userDailySummery.js';

// 環境変数の詳細なデバッグ情報
console.log('=== Environment Variables Debug ===');
console.log('NODE_ENV:', process.env.NODE_ENV);
console.log('PORT:', process.env.PORT);
console.log('DATABASE_URL exists:', !!process.env.DATABASE_URL);
console.log('DATABASE_URL length:', process.env.DATABASE_URL?.length || 0);
console.log('DB_PASSWORD exists:', !!process.env.DB_PASSWORD);
console.log('DB_PASSWORD length:', process.env.DB_PASSWORD?.length || 0);
console.log(
  'DATABASE_URL contains placeholder:',
  process.env.DATABASE_URL?.includes('${DB_PASSWORD}') || false,
);
console.log(
  'All env vars starting with DB:',
  Object.keys(process.env).filter((key) => key.startsWith('DB')),
);
console.log(
  'All env vars starting with DATABASE:',
  Object.keys(process.env).filter((key) => key.startsWith('DATABASE')),
);
console.log('===================================');

// Prismaクライアントのインポートを遅延させる
let globalPrisma: any;

const app = new Hono();

app.get('/', (c) => {
  return c.text('Hello summeryme.ai!');
});

// 基本的なヘルスチェック（データベース接続なし）
app.get('/health/basic', (c) => {
  return c.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
    database_url_exists: !!process.env.DATABASE_URL,
    database_url_length: process.env.DATABASE_URL?.length || 0,
    db_password_exists: !!process.env.DB_PASSWORD,
    db_password_length: process.env.DB_PASSWORD?.length || 0,
    database_url_has_placeholder:
      process.env.DATABASE_URL?.includes('${DB_PASSWORD}') || false,
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
      database_url_exists: !!process.env.DATABASE_URL,
      db_password_exists: !!process.env.DB_PASSWORD,
      database_url_has_placeholder:
        process.env.DATABASE_URL?.includes('${DB_PASSWORD}') || false,
    });
  } catch (error) {
    console.error('Health check failed:', error);
    console.error('DATABASE_URL at error time:', !!process.env.DATABASE_URL);

    return c.json(
      {
        status: 'unhealthy',
        timestamp: new Date().toISOString(),
        environment: process.env.NODE_ENV || 'development',
        database: 'disconnected',
        database_url_exists: !!process.env.DATABASE_URL,
        db_password_exists: !!process.env.DB_PASSWORD,
        database_url_has_placeholder:
          process.env.DATABASE_URL?.includes('${DB_PASSWORD}') || false,
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
    console.log(`Server is running on http://localhost:${info.port}`);
    console.log('DATABASE_URL at server start:', !!process.env.DATABASE_URL);
    console.log('DB_PASSWORD at server start:', !!process.env.DB_PASSWORD);
    console.log(
      'DATABASE_URL has placeholder:',
      process.env.DATABASE_URL?.includes('${DB_PASSWORD}') || false,
    );
  },
);
