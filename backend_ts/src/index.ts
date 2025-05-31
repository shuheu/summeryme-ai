import { serve } from '@hono/node-server';
import { Hono } from 'hono';
import { globalPrisma } from './lib/dbClient.js';
import savedArticleRouter from './apis/savedArticle.js';
import userDailySummaryRouter from './apis/userDailySummery.js';

const app = new Hono();

app.get('/', (c) => {
  return c.text('Hello Hono!');
});

// APIルーターの設定
app.route('/api/saved-articles', savedArticleRouter);
app.route('/api/user-daily-summaries', userDailySummaryRouter);

// Prismaクライアントの接続を適切に終了
process.on('SIGINT', async () => {
  await globalPrisma.$disconnect();
  process.exit(0);
});

serve(
  {
    fetch: app.fetch,
    port: 8080,
  },
  (info) => {
    console.log(`Server is running on http://localhost:${info.port}`);
  },
);
