import { serve } from '@hono/node-server';
import { Hono } from 'hono';

import savedArticleRouter from './apis/savedArticle.js';
import userDailySummaryRouter from './apis/userDailySummery.js';
import { globalPrisma } from './lib/dbClient.js';
import { createWorkerRoutes } from './routes/worker.js';

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
const workerRoutes = createWorkerRoutes(globalPrisma);
app.route('/worker', workerRoutes);

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
