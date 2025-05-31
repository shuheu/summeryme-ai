import type { Context, Next } from 'hono';

/**
 * Google Cloud Scheduler用の認証ミドルウェア
 * Cloud Schedulerからのリクエストを検証
 */
export const gcpWorkerAuth = async (c: Context, next: Next) => {
  // Cloud Schedulerからのリクエストの場合、特定のヘッダーが設定される
  const userAgent = c.req.header('User-Agent');
  const xCloudScheduler = c.req.header('X-CloudScheduler');
  const xCloudSchedulerJobName = c.req.header('X-CloudScheduler-JobName');

  // 環境変数から設定を取得
  const workerSecret = process.env.WORKER_SECRET;
  const allowedJobNames = process.env.ALLOWED_JOB_NAMES?.split(',') || [];
  const isProduction = process.env.NODE_ENV === 'production';

  // 本番環境でのセキュリティチェック
  if (isProduction) {
    // Cloud Schedulerからのリクエストかチェック
    if (!userAgent?.includes('Google-Cloud-Scheduler')) {
      console.warn('不正なUser-Agentからのアクセス:', userAgent);
      return c.json({ error: 'アクセスが拒否されました' }, 403);
    }

    // Cloud Schedulerヘッダーの存在確認
    if (!xCloudScheduler) {
      console.warn('X-CloudSchedulerヘッダーが存在しません');
      return c.json({ error: 'アクセスが拒否されました' }, 403);
    }

    // 許可されたジョブ名からのアクセスかチェック
    if (allowedJobNames.length > 0 && xCloudSchedulerJobName) {
      if (!allowedJobNames.includes(xCloudSchedulerJobName)) {
        console.warn('許可されていないジョブからのアクセス:', xCloudSchedulerJobName);
        return c.json({ error: 'アクセスが拒否されました' }, 403);
      }
    }
  }

  // 追加のシークレット認証（オプション）
  if (workerSecret) {
    const authHeader = c.req.header('Authorization');
    if (!authHeader || authHeader !== `Bearer ${workerSecret}`) {
      console.warn('無効な認証トークン');
      return c.json({ error: '認証が必要です' }, 401);
    }
  }

  // リクエスト情報をログ出力
  console.log('Worker request:', {
    userAgent,
    jobName: xCloudSchedulerJobName,
    timestamp: new Date().toISOString(),
  });

  await next();
};