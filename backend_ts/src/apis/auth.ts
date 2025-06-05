import { Hono } from 'hono';
import { z } from 'zod';

import { globalPrisma } from '../lib/dbClient.js';
import { firebaseAuth } from '../lib/firebaseAdmin.js';

const authRouter = new Hono();

const loginSchema = z.object({
  idToken: z.string(),
});

authRouter.post('/login', async (c) => {
  try {
    const body = await c.req.json();
    const parse = loginSchema.safeParse(body);
    if (!parse.success) {
      return c.json({ error: 'Invalid request' }, 400);
    }

    const { idToken } = parse.data;
    const decoded = await firebaseAuth.verifyIdToken(idToken);
    const { uid, name } = decoded;

    const user = await globalPrisma.user.upsert({
      where: { uid },
      update: { name: name ?? 'anonymous' },
      create: { uid, name: name ?? 'anonymous' },
    });

    return c.json({ data: { id: user.id, uid: user.uid, name: user.name } });
  } catch (error) {
    console.error('Auth error:', error);
    return c.json({ error: 'Unauthorized' }, 401);
  }
});

export default authRouter;
