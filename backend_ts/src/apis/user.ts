import { Hono } from 'hono';
import { z } from 'zod';

import { globalPrisma } from '../lib/dbClient.js';

const userRouter = new Hono();

// バリデーションスキーマ
const authSchema = z.object({
  uid: z.string().min(1),
  name: z.string().min(1),
});

// ユーザー認証エンドポイント（UIDで検索、存在しなければ作成）
userRouter.post('/auth', async (c) => {
  try {
    const body = await c.req.json();

    const { uid, name } = body;

    // バリデーション
    const validation = authSchema.safeParse({ uid, name });
    if (!validation.success) {
      console.error('Validation error:', validation.error);
      return c.json(
        { error: 'Invalid request data', details: validation.error },
        400,
      );
    }

    // UIDでユーザーを検索
    let user = await globalPrisma.user.findUnique({
      where: { uid },
    });

    // ユーザーが存在しない場合は新規作成
    if (user) {
      return c.json({
        user: {
          id: user.id,
          uid: user.uid,
          name: user.name,
          createdAt: user.createdAt.toISOString(),
          updatedAt: user.updatedAt.toISOString(),
        },
      });
    }

    user = await globalPrisma.user.create({
      data: {
        uid,
        name,
      },
    });

    return c.json({
      user: {
        id: user.id,
        uid: user.uid,
        name: user.name,
        createdAt: user.createdAt.toISOString(),
        updatedAt: user.updatedAt.toISOString(),
      },
    });
  } catch (error) {
    console.error('Error in user auth:', error);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

// ユーザー情報取得エンドポイント
userRouter.get('/:uid', async (c) => {
  try {
    const uid = c.req.param('uid');

    const user = await globalPrisma.user.findUnique({
      where: { uid },
    });

    if (!user) {
      return c.json({ error: 'User not found' }, 404);
    }

    return c.json({
      user: {
        id: user.id,
        uid: user.uid,
        name: user.name,
        createdAt: user.createdAt.toISOString(),
        updatedAt: user.updatedAt.toISOString(),
      },
    });
  } catch (error) {
    console.error('Error fetching user:', error);
    return c.json({ error: 'Internal server error' }, 500);
  }
});

export default userRouter;
