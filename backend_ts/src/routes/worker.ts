import { Hono } from 'hono';
import type { PrismaClient } from '../prisma/generated/prisma/index.js';
import { gcpWorkerAuth } from '../middleware/gcp-worker-auth.js';
import { ArticleProcessorService } from '../services/article-processor.js';

export const createWorkerRoutes = (prisma: PrismaClient) => {
  const worker = new Hono();
  // const articleProcessor = new ArticleProcessorService(prisma);

  // Google Cloud Scheduler用の認証を適用
  worker.use('*', gcpWorkerAuth);

  /**
   * 記事要約処理（Cloud Scheduler用）
   * 毎時実行を想定
   */
  worker.post('/process-articles', async (c) => {
    console.log('🚀 ~ worker.post ~ c:', c);

    const startTime = Date.now();

    // try {
    //   const body = await c.req.json().catch(() => ({}));
    //   const { limit = 20 } = body; // Cloud Schedulerでは多めに処理

    //   console.log(`記事要約処理を開始 (limit: ${limit})`);

    //   const result = await articleProcessor.processArticlesBatch(limit);

    //   const response = {
    //     success: result.success,
    //     message: `記事要約処理が完了しました`,
    //     processedCount: result.processedCount,
    //     errorCount: result.errors.length,
    //     duration: result.duration,
    //     timestamp: new Date().toISOString(),
    //     ...(result.errors.length > 0 && { errors: result.errors }),
    //   };

    //   console.log('記事要約処理結果:', response);

    //   return c.json(response, result.success ? 200 : 207); // 207: Multi-Status
    // } catch (error) {
    //   const duration = Date.now() - startTime;
    //   console.error('記事要約処理でエラーが発生:', error);

    //   return c.json({
    //     success: false,
    //     error: '記事要約処理に失敗しました',
    //     duration,
    //     timestamp: new Date().toISOString(),
    //   }, 500);
    // }
  });

  /**
   * 日次要約とpodcast生成（Cloud Scheduler用）
   * 日次実行を想定
   */
  worker.post('/generate-daily-summaries', async (c) => {
    console.log('🚀 ~ worker.post ~ c:', c);
    // const startTime = Date.now();

    // try {
    //   const body = await c.req.json().catch(() => ({}));
    //   const { targetDate } = body;

    //   // targetDateが指定されていない場合は前日を使用
    //   const date = targetDate ? new Date(targetDate) : new Date(Date.now() - 24 * 60 * 60 * 1000);

    //   console.log(`日次要約処理を開始 (対象日: ${date.toISOString().split('T')[0]})`);

    //   const result = await articleProcessor.generateDailySummariesBatch(date);

    //   const response = {
    //     success: result.success,
    //     message: `日次要約処理が完了しました`,
    //     targetDate: date.toISOString().split('T')[0],
    //     processedCount: result.processedCount,
    //     errorCount: result.errors.length,
    //     duration: result.duration,
    //     timestamp: new Date().toISOString(),
    //     ...(result.errors.length > 0 && { errors: result.errors }),
    //   };

    //   console.log('日次要約処理結果:', response);

    //   return c.json(response, result.success ? 200 : 207);
    // } catch (error) {
    //   const duration = Date.now() - startTime;
    //   console.error('日次要約処理でエラーが発生:', error);

    //   return c.json({
    //     success: false,
    //     error: '日次要約処理に失敗しました',
    //     duration,
    //     timestamp: new Date().toISOString(),
    //   }, 500);
    // }
  });

  /**
   * ヘルスチェック（Cloud Scheduler監視用）
   */
  worker.get('/health', async (c) => {
    console.log('🚀 ~ worker.get ~ c:', c);
    // try {
    //   // データベース接続確認
    //   await prisma.$queryRaw`SELECT 1`;

    //   return c.json({
    //     status: 'healthy',
    //     service: 'article-processor-worker',
    //     timestamp: new Date().toISOString(),
    //     database: 'connected',
    //     environment: process.env.NODE_ENV || 'development',
    //   });
    // } catch (error) {
    //   console.error('ヘルスチェックでエラー:', error);

    //   return c.json({
    //     status: 'unhealthy',
    //     service: 'article-processor-worker',
    //     timestamp: new Date().toISOString(),
    //     database: 'disconnected',
    //     error: error instanceof Error ? error.message : '不明なエラー',
    //   }, 503);
    // }
  });

  return worker;
};
