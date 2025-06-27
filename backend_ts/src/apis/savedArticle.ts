import { Hono } from 'hono';
import { z } from 'zod';

import { globalPrisma } from '../lib/dbClient.js';
import { requireAuth } from '../middleware/auth.js';
import { fetchPageTitle } from '../utils/webScraper.js';

import type { ZodIssue } from 'zod';

const savedArticleRouter = new Hono();

// バリデーションスキーマの定義
const getUserSavedArticlesSchema = z.object({
  page: z.string().regex(/^\d+$/).transform(Number).optional().default('1'),
  limit: z.string().regex(/^\d+$/).transform(Number).optional().default('10'),
});

const createSavedArticleSchema = z.object({
  title: z
    .string()
    .max(255, 'タイトルは255文字以内である必要があります')
    .optional(),
  url: z
    .string()
    .url('有効なURLである必要があります')
    .max(1024, 'URLは1024文字以内である必要があります'),
});

const getSavedArticleByIdSchema = z.object({
  id: z
    .string()
    .regex(/^\d+$/, 'IDは数値である必要があります')
    .transform(Number),
});

const deleteSavedArticleSchema = z.object({
  id: z
    .string()
    .regex(/^\d+$/, 'IDは数値である必要があります')
    .transform(Number),
});

// savedArticleの一覧を取得するエンドポイント
savedArticleRouter.get('/', requireAuth, async (c) => {
  try {
    // クエリパラメータのバリデーション
    const queryParams = {
      page: c.req.query('page'),
      limit: c.req.query('limit'),
    };

    const validationResult = getUserSavedArticlesSchema.safeParse(queryParams);

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

    // 認証されたユーザーのIDを取得
    const user = c.get('user');
    const userId = user.id;

    // ページネーションの計算
    const skip = (page - 1) * limit;

    // savedArticleの一覧を取得（サマリー情報も含む）
    const [savedArticles, totalCount] = await Promise.all([
      globalPrisma.savedArticle.findMany({
        where: {
          userId: userId,
        },
        include: {
          savedArticleSummary: true,
        },
        orderBy: {
          createdAt: 'desc',
        },
        skip: skip,
        take: limit,
      }),
      globalPrisma.savedArticle.count({
        where: {
          userId: userId,
        },
      }),
    ]);

    const totalPages = Math.ceil(totalCount / limit);

    return c.json({
      data: {
        savedArticles,
        pagination: {
          currentPage: page,
          totalPages: totalPages,
          totalCount: totalCount,
          limit: limit,
          hasNextPage: page < totalPages,
          hasPreviousPage: page > 1,
        },
      },
    });
  } catch (error) {
    console.error('SavedArticle取得エラー:', error);
    return c.json({ error: 'サーバーエラーが発生しました' }, 500);
  }
});

// savedArticleを作成するエンドポイント
savedArticleRouter.post('/', requireAuth, async (c) => {
  try {
    const body = await c.req.json();

    console.log('body', body);

    const validationResult = createSavedArticleSchema.safeParse(body);

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

    let { title, url } = validationResult.data;

    // 認証されたユーザーのIDを取得
    const user = c.get('user');
    const userId = user.id;

    // titleが提供されていない場合、URLからタイトルを取得
    if (!title?.trim()) {
      const fetchedTitle = await fetchPageTitle(url);
      if (fetchedTitle) {
        title = fetchedTitle;
        console.log('title', title);
      } else {
        // タイトルが取得できなかった場合はURLをタイトルとして使用
        title = url;
      }
    }

    // ユーザーが存在するかチェック
    const userExists = await globalPrisma.user.findUnique({
      where: { id: userId },
    });

    if (!userExists) {
      return c.json({ error: 'ユーザーが見つかりません' }, 404);
    }

    // 同じURLが既に保存されているかチェック
    const existingArticle = await globalPrisma.savedArticle.findFirst({
      where: {
        userId: userId,
        url: url,
      },
    });

    if (existingArticle) {
      return c.json({ error: 'この記事は既に保存されています' }, 409);
    }

    // savedArticleを作成
    const savedArticle = await globalPrisma.savedArticle.create({
      data: {
        userId: userId,
        title: title,
        url: url,
      },
      include: {
        savedArticleSummary: true,
      },
    });

    return c.json(
      {
        data: savedArticle,
        message: '記事が正常に保存されました',
      },
      201,
    );
  } catch (error) {
    console.error('SavedArticle作成エラー:', error);
    return c.json({ error: 'サーバーエラーが発生しました' }, 500);
  }
});

// 特定のsavedArticleを取得するエンドポイント
savedArticleRouter.get('/:id', requireAuth, async (c) => {
  try {
    // パスパラメータのバリデーション
    const pathParams = {
      id: c.req.param('id'),
    };

    const validationResult = getSavedArticleByIdSchema.safeParse(pathParams);

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

    // 認証されたユーザーのIDを取得
    const user = c.get('user');
    const userId = user.id;

    const savedArticle = await globalPrisma.savedArticle.findUnique({
      where: {
        id: id,
        userId: userId,
      },
      include: {
        savedArticleSummary: true,
      },
    });

    if (!savedArticle) {
      return c.json({ error: '記事が見つかりません' }, 404);
    }

    return c.json({
      data: savedArticle,
    });
  } catch (error) {
    console.error('SavedArticle取得エラー:', error);
    return c.json({ error: 'サーバーエラーが発生しました' }, 500);
  }
});

// savedArticleを削除するエンドポイント
savedArticleRouter.delete('/:id', requireAuth, async (c) => {
  try {
    // パスパラメータのバリデーション
    const pathParams = {
      id: c.req.param('id'),
    };

    const validationResult = deleteSavedArticleSchema.safeParse(pathParams);

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

    // 認証されたユーザーのIDを取得
    const user = c.get('user');
    const userId = user.id;

    // 削除対象の記事が存在するかチェック
    const existingArticle = await globalPrisma.savedArticle.findUnique({
      where: { id: id, userId: userId },
    });

    if (!existingArticle) {
      return c.json({ error: '記事が見つかりません' }, 404);
    }

    // savedArticleを削除（Cascadeによりサマリーも自動削除される）
    await globalPrisma.savedArticle.delete({
      where: { id: id, userId: userId },
    });

    return c.json({
      message: '記事が正常に削除されました',
    });
  } catch (error) {
    console.error('SavedArticle削除エラー:', error);
    return c.json({ error: 'サーバーエラーが発生しました' }, 500);
  }
});

export default savedArticleRouter;
