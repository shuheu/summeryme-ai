import { globalPrisma } from '../lib/dbClient.js';

import type { Context, Next } from 'hono';

export interface AuthUser {
  id: number;
  uid: string;
  name: string;
}

declare module 'hono' {
  interface ContextVariableMap {
    user: AuthUser;
  }
}

export async function requireAuth(c: Context, next: Next) {
  const uid = c.req.header('X-User-UID');

  if (!uid) {
    return c.json({ error: 'Unauthorized: Missing user UID' }, 401);
  }

  try {
    const user = await globalPrisma.user.findUnique({
      where: { uid },
    });

    if (!user) {
      return c.json({ error: 'Unauthorized: User not found' }, 401);
    }

    c.set('user', {
      id: user.id,
      uid: user.uid,
      name: user.name,
    });

    await next();
  } catch (error) {
    console.error('Auth middleware error:', error);
    return c.json({ error: 'Internal server error' }, 500);
  }
}
