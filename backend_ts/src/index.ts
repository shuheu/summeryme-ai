import { serve } from '@hono/node-server';
import { Hono } from 'hono';

import savedArticleRouter from './apis/savedArticle.js';
import userDailySummaryRouter from './apis/userDailySummery.js';

// 環境変数の詳細なデバッグ情報
console.log('=== Environment Variables Debug ===');
console.log('NODE_ENV:', process.env.NODE_ENV);
console.log('PORT:', process.env.PORT);
console.log('DB_HOST:', process.env.DB_HOST);
console.log('DB_PORT:', process.env.DB_PORT);
console.log('DB_USER:', process.env.DB_USER);
console.log('DB_NAME:', process.env.DB_NAME);
console.log('DB_PASSWORD exists:', !!process.env.DB_PASSWORD);
console.log('DB_SOCKET_PATH:', process.env.DB_SOCKET_PATH);
console.log(
  'All env vars starting with DB:',
  Object.keys(process.env).filter((key) => key.startsWith('DB')),
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
    db_host_exists: !!process.env.DB_HOST,
    db_port_exists: !!process.env.DB_PORT,
    db_user_exists: !!process.env.DB_USER,
    db_name_exists: !!process.env.DB_NAME,
    db_password_exists: !!process.env.DB_PASSWORD,
    db_socket_path_exists: !!process.env.DB_SOCKET_PATH,
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
      db_host_exists: !!process.env.DB_HOST,
      db_port_exists: !!process.env.DB_PORT,
      db_user_exists: !!process.env.DB_USER,
      db_name_exists: !!process.env.DB_NAME,
      db_password_exists: !!process.env.DB_PASSWORD,
      db_socket_path_exists: !!process.env.DB_SOCKET_PATH,
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
        db_host_exists: !!process.env.DB_HOST,
        db_port_exists: !!process.env.DB_PORT,
        db_user_exists: !!process.env.DB_USER,
        db_name_exists: !!process.env.DB_NAME,
        db_password_exists: !!process.env.DB_PASSWORD,
        db_socket_path_exists: !!process.env.DB_SOCKET_PATH,
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
    console.log('DB_HOST at server start:', !!process.env.DB_HOST);
    console.log('DB_PASSWORD at server start:', !!process.env.DB_PASSWORD);
    console.log(
      'DB_SOCKET_PATH at server start:',
      !!process.env.DB_SOCKET_PATH,
    );
  },
);
