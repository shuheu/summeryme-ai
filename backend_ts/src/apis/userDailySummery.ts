import { Hono } from 'hono';
import { z } from 'zod';

import { globalPrisma } from '../lib/dbClient.js';
import { AudioUrlService } from '../services/audioUrlService.js';

import type { ZodIssue } from 'zod';

const userDailySummaryRouter = new Hono();

// バリデーションスキーマの定義
const getUserDailySummariesSchema = z.object({
  page: z.string().regex(/^\d+$/).transform(Number).optional().default('1'),
  limit: z.string().regex(/^\d+$/).transform(Number).optional().default('10'),
});

const getUserDailySummaryByIdSchema = z.object({
  id: z
    .string()
    .regex(/^\d+$/, 'IDは数値である必要があります')
    .transform(Number),
});

// UserDailySummaryの一覧を取得するエンドポイント
userDailySummaryRouter.get('/', async (c) => {
  try {
    // クエリパラメータのバリデーション
    const queryParams = {
      page: c.req.query('page'),
      limit: c.req.query('limit'),
    };

    const validationResult = getUserDailySummariesSchema.safeParse(queryParams);

    if (!validationResult.success) {
      return c.json(
        {
          error: 'バリデーションエラー',
          details: validationResult.error.errors.map((err: ZodIssue) => ({
            field: err.path.join('.'),
            message: err.message,
          })),
        },
        400,
      );
    }

    const { page, limit } = validationResult.data;

    // TODO: ユーザーIDの取得処理を追加する
    const userId = 1;

    // ページネーションの計算
    const skip = (page - 1) * limit;

    // UserDailySummaryの一覧を取得
    const [userDailySummaries, totalCount] = await Promise.all([
      globalPrisma.userDailySummary.findMany({
        where: {
          userId: userId,
        },
        orderBy: {
          generatedDate: 'desc',
        },
        skip: skip,
        take: limit,
      }),
      globalPrisma.userDailySummary.count({
        where: {
          userId: userId,
        },
      }),
    ]);

    const totalPages = Math.ceil(totalCount / limit);

    return c.json({
      data: userDailySummaries,
      pagination: {
        currentPage: page,
        totalPages: totalPages,
        totalCount: totalCount,
        limit: limit,
        hasNextPage: page < totalPages,
        hasPreviousPage: page > 1,
      },
    });
  } catch (error) {
    console.error('UserDailySummary取得エラー:', error);
    return c.json({ error: 'サーバーエラーが発生しました' }, 500);
  }
});

// 特定のUserDailySummaryを取得するエンドポイント
userDailySummaryRouter.get('/:id', async (c) => {
  try {
    // パスパラメータのバリデーション
    const pathParams = {
      id: c.req.param('id'),
    };

    const validationResult =
      getUserDailySummaryByIdSchema.safeParse(pathParams);

    if (!validationResult.success) {
      return c.json(
        {
          error: 'バリデーションエラー',
          details: validationResult.error.errors.map((err: ZodIssue) => ({
            field: err.path.join('.'),
            message: err.message,
          })),
        },
        400,
      );
    }

    const { id } = validationResult.data;

    // TODO: ユーザーIDの取得処理を追加する
    const userId = 1;

    const userDailySummary = await globalPrisma.userDailySummary.findUnique({
      where: {
        id: id,
        userId: userId,
      },
      include: {
        userDailySummarySavedArticles: {
          include: {
            savedArticle: {
              include: {
                savedArticleSummary: true,
              },
            },
          },
        },
      },
    });

    if (!userDailySummary) {
      return c.json({ error: 'デイリーサマリーが見つかりません' }, 404);
    }

    return c.json({
      data: userDailySummary,
    });
  } catch (error) {
    console.error('UserDailySummary取得エラー:', error);
    return c.json({ error: 'サーバーエラーが発生しました' }, 500);
  }
});

// 特定のUserDailySummaryの音声URLを取得するエンドポイント
userDailySummaryRouter.get('/:id/audio-urls', async (c) => {
  try {
    // パスパラメータのバリデーション
    const pathParams = {
      id: c.req.param('id'),
    };

    const validationResult =
      getUserDailySummaryByIdSchema.safeParse(pathParams);

    if (!validationResult.success) {
      return c.json(
        {
          error: 'バリデーションエラー',
          details: validationResult.error.errors.map((err: ZodIssue) => ({
            field: err.path.join('.'),
            message: err.message,
          })),
        },
        400,
      );
    }

    const { id } = validationResult.data;

    // TODO: ユーザーIDの取得処理を追加する
    const userId = 1;

    // デイリーサマリーの存在確認
    const userDailySummary = await globalPrisma.userDailySummary.findUnique({
      where: {
        id: id,
        userId: userId,
      },
    });

    if (!userDailySummary) {
      return c.json({ error: 'デイリーサマリーが見つかりません' }, 404);
    }

    // 音声URL取得サービスを初期化
    const audioUrlService = new AudioUrlService();

    // 音声ファイルの存在確認
    const hasAudioFiles = await audioUrlService.hasAudioFiles(userId, id);

    if (!hasAudioFiles) {
      return c.json({
        data: {
          audioFiles: [],
          hasAudio: false,
          message: 'この記事には音声サマリーがありません',
        },
      });
    }

    // 署名付きURLを取得
    const audioFiles = await audioUrlService.getAudioUrlsForDailySummary(
      userId,
      id,
    );

    return c.json({
      data: {
        audioFiles: audioFiles,
        hasAudio: audioFiles.length > 0,
        totalFiles: audioFiles.length,
        expiresInMinutes: audioUrlService.getUrlExpirationMinutes(),
      },
    });
  } catch (error) {
    console.error('音声URL取得エラー:', error);
    return c.json({ error: 'サーバーエラーが発生しました' }, 500);
  }
});

export default userDailySummaryRouter;
