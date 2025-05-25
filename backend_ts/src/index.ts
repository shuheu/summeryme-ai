import { serve } from '@hono/node-server';
import { Hono } from 'hono';

import { PrismaClient } from './prisma/generated/prisma/index.js';

const app = new Hono();
const prisma = new PrismaClient();

app.get('/', (c) => {
  return c.text('Hello Hono!');
});

// Todo CRUD エンドポイント

// 全てのTodoを取得
app.get('/todos', async (c) => {
  try {
    const todos = await prisma.todo.findMany({
      orderBy: { createdAt: 'desc' },
    });
    return c.json(todos);
  } catch {
    return c.json({ error: 'Todoの取得に失敗しました' }, 500);
  }
});

// 特定のTodoを取得
app.get('/todos/:id', async (c) => {
  try {
    const id = parseInt(c.req.param('id'));
    const todo = await prisma.todo.findUnique({
      where: { id },
    });

    if (!todo) {
      return c.json({ error: 'Todoが見つかりません' }, 404);
    }

    return c.json(todo);
  } catch {
    return c.json({ error: 'Todoの取得に失敗しました' }, 500);
  }
});

// 新しいTodoを作成
app.post('/todos', async (c) => {
  try {
    const body = await c.req.json();
    const { title, description } = body;

    if (!title) {
      return c.json({ error: 'タイトルは必須です' }, 400);
    }

    const todo = await prisma.todo.create({
      data: {
        title,
        description: description || null,
      },
    });

    return c.json(todo, 201);
  } catch {
    return c.json({ error: 'Todoの作成に失敗しました' }, 500);
  }
});

// Todoを更新
app.put('/todos/:id', async (c) => {
  try {
    const id = parseInt(c.req.param('id'));
    const body = await c.req.json();
    const { title, description, completed } = body;

    const existingTodo = await prisma.todo.findUnique({
      where: { id },
    });

    if (!existingTodo) {
      return c.json({ error: 'Todoが見つかりません' }, 404);
    }

    const todo = await prisma.todo.update({
      where: { id },
      data: {
        ...(title !== undefined && { title }),
        ...(description !== undefined && { description }),
        ...(completed !== undefined && { completed }),
      },
    });

    return c.json(todo);
  } catch {
    return c.json({ error: 'Todoの更新に失敗しました' }, 500);
  }
});

// Todoを削除
app.delete('/todos/:id', async (c) => {
  try {
    const id = parseInt(c.req.param('id'));

    const existingTodo = await prisma.todo.findUnique({
      where: { id },
    });

    if (!existingTodo) {
      return c.json({ error: 'Todoが見つかりません' }, 404);
    }

    await prisma.todo.delete({
      where: { id },
    });

    return c.json({ message: 'Todoが削除されました' });
  } catch {
    return c.json({ error: 'Todoの削除に失敗しました' }, 500);
  }
});

// Prismaクライアントの接続を適切に終了
process.on('SIGINT', async () => {
  await prisma.$disconnect();
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
