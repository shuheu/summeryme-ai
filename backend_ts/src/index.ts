import { serve } from '@hono/node-server';
import { Hono } from 'hono';

import { PrismaClient } from './prisma/generated/prisma/index.js';
import { createWorkerRoutes } from './routes/worker.js';

// Prismaクライアントの初期化（エラーハンドリング付き）
let prisma: PrismaClient;
try {
  prisma = new PrismaClient();
  console.log('Prismaクライアントが正常に初期化されました');
} catch (error) {
  console.error('Prismaクライアントの初期化に失敗:', error);
  // 一時的にダミーのPrismaクライアントを作成
  prisma = new PrismaClient();
}
import savedArticleRouter from './apis/savedArticle.js';
import userDailySummaryRouter from './apis/userDailySummery.js';
import { globalPrisma } from './lib/dbClient.js';

const app = new Hono();

app.get('/', (c) => {
  return c.text('Hello summeryme.ai!');
});

app.get('/health', (c) => {
  return c.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'development',
  });
});

// Worker用ルートを追加
const workerRoutes = createWorkerRoutes(prisma);
app.route('/worker', workerRoutes);

app.route('/api/saved-articles', savedArticleRouter);
app.route('/api/user-daily-summaries', userDailySummaryRouter);

// Prismaクライアントの接続を適切に終了
process.on('SIGINT', async () => {
  await globalPrisma.$disconnect();
  process.exit(0);
});

process.on('SIGTERM', async () => {
  await prisma.$disconnect();
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
