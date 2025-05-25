import { app } from './index'; // Assuming your Hono app instance is exported as 'app'
import { PrismaClient } from './prisma/generated/prisma/index.js';
// import { describe, test, expect, vi, beforeEach } from 'vitest'; // Removed vitest imports


// Mock Prisma
jest.mock('./prisma/generated/prisma/index.js', () => {
  const mockPrismaClient = {
    todo: {
      findMany: jest.fn(),
      findUnique: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
      delete: jest.fn(),
    },
    $disconnect: jest.fn(),
  };
  return { PrismaClient: jest.fn(() => mockPrismaClient) };
});

const prismaMock = new PrismaClient();

describe('Todo API', () => {
  beforeEach(() => {
    // Reset mocks before each test
    // vi.clearAllMocks(); // Replaced with jest.clearAllMocks()
    jest.clearAllMocks();
  });

  describe('GET /todos', () => {
    test('should return all todos', async () => {
      const mockTodos = [
        { id: 1, title: 'Test Todo 1', description: 'Description 1', completed: false, createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() },
        { id: 2, title: 'Test Todo 2', description: 'Description 2', completed: true, createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() },
      ];
      (prismaMock.todo.findMany as jest.Mock).mockResolvedValue(mockTodos);

      const res = await app.request('/todos');
      expect(res.status).toBe(200);
      const responseJson = await res.json();
      // Normalize dates for comparison
      expect(responseJson).toEqual(mockTodos.map(todo => ({...todo, createdAt: expect.any(String), updatedAt: expect.any(String)})));
      expect(prismaMock.todo.findMany).toHaveBeenCalledTimes(1);
      expect(prismaMock.todo.findMany).toHaveBeenCalledWith({ orderBy: { createdAt: 'desc' } });
    });

    test('should return 500 if there is an error', async () => {
      (prismaMock.todo.findMany as jest.Mock).mockRejectedValue(new Error('Test Error'));

      const res = await app.request('/todos');
      expect(res.status).toBe(500);
      expect(await res.json()).toEqual({ error: 'Todoの取得に失敗しました' });
    });
  });

  describe('GET /todos/:id', () => {
    test('should return a specific todo if found', async () => {
      const mockTodo = { id: 1, title: 'Test Todo 1', description: 'Description 1', completed: false, createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() };
      (prismaMock.todo.findUnique as jest.Mock).mockResolvedValue(mockTodo);

      const res = await app.request('/todos/1');
      expect(res.status).toBe(200);
      // Normalize dates for comparison
      expect(await res.json()).toEqual({...mockTodo, createdAt: expect.any(String), updatedAt: expect.any(String)});
      expect(prismaMock.todo.findUnique).toHaveBeenCalledTimes(1);
      expect(prismaMock.todo.findUnique).toHaveBeenCalledWith({ where: { id: 1 } });
    });

    test('should return 404 if todo not found', async () => {
      (prismaMock.todo.findUnique as jest.Mock).mockResolvedValue(null);

      const res = await app.request('/todos/999');
      expect(res.status).toBe(404);
      expect(await res.json()).toEqual({ error: 'Todoが見つかりません' });
    });

    test('should return 500 if there is an error', async () => {
      (prismaMock.todo.findUnique as jest.Mock).mockRejectedValue(new Error('Test Error'));

      const res = await app.request('/todos/1');
      expect(res.status).toBe(500);
      expect(await res.json()).toEqual({ error: 'Todoの取得に失敗しました' });
    });
  });

  describe('POST /todos', () => {
    test('should create a new todo and return it', async () => {
      const newTodoData = { title: 'New Todo', description: 'New Description' };
      // Ensure createdAt and updatedAt are strings for consistent comparison
      const createdTodo = { id: 3, ...newTodoData, completed: false, createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() };
      (prismaMock.todo.create as jest.Mock).mockResolvedValue(createdTodo);

      const res = await app.request('/todos', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(newTodoData),
      });

      expect(res.status).toBe(201);
      const responseJson = await res.json();
      expect(responseJson.title).toBe(createdTodo.title);
      expect(responseJson.description).toBe(createdTodo.description);
      expect(responseJson.completed).toBe(false);
      // Compare date fields using expect.any(String)
      expect(responseJson.createdAt).toEqual(expect.any(String));
      expect(responseJson.updatedAt).toEqual(expect.any(String));
      expect(prismaMock.todo.create).toHaveBeenCalledTimes(1);
      expect(prismaMock.todo.create).toHaveBeenCalledWith({
        data: { title: newTodoData.title, description: newTodoData.description },
      });
    });

    test('should return 400 if title is missing', async () => {
      const newTodoData = { description: 'Missing title' };
      const res = await app.request('/todos', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(newTodoData),
      });

      expect(res.status).toBe(400);
      expect(await res.json()).toEqual({ error: 'タイトルは必須です' });
      expect(prismaMock.todo.create).not.toHaveBeenCalled();
    });

    test('should return 500 if there is an error during creation', async () => {
      const newTodoData = { title: 'Error Todo', description: 'Error Description' };
      (prismaMock.todo.create as jest.Mock).mockRejectedValue(new Error('Test Error'));

      const res = await app.request('/todos', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(newTodoData),
      });

      expect(res.status).toBe(500);
      expect(await res.json()).toEqual({ error: 'Todoの作成に失敗しました' });
    });
  });

  describe('PUT /todos/:id', () => {
    test('should update an existing todo and return it', async () => {
      const existingTodo = { id: 1, title: 'Old Title', description: 'Old Description', completed: false, createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() };
      const updatedData = { title: 'Updated Title', completed: true };
      // Ensure date fields are strings for consistent comparison
      const updatedTodo = { ...existingTodo, ...updatedData, updatedAt: new Date().toISOString() };

      (prismaMock.todo.findUnique as jest.Mock).mockResolvedValue(existingTodo);
      (prismaMock.todo.update as jest.Mock).mockResolvedValue(updatedTodo);

      const res = await app.request('/todos/1', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(updatedData),
      });

      expect(res.status).toBe(200);
      const responseJson = await res.json();
      expect(responseJson.title).toBe(updatedTodo.title);
      expect(responseJson.completed).toBe(updatedTodo.completed);
      // Compare date fields using expect.any(String)
      expect(responseJson.createdAt).toEqual(expect.any(String));
      expect(responseJson.updatedAt).toEqual(expect.any(String));

      expect(prismaMock.todo.findUnique).toHaveBeenCalledTimes(1);
      expect(prismaMock.todo.findUnique).toHaveBeenCalledWith({ where: { id: 1 } });
      expect(prismaMock.todo.update).toHaveBeenCalledTimes(1);
      expect(prismaMock.todo.update).toHaveBeenCalledWith({
        where: { id: 1 },
        data: updatedData,
      });
    });

    test('should return 404 if todo to update is not found', async () => {
      (prismaMock.todo.findUnique as jest.Mock).mockResolvedValue(null);
      const updatedData = { title: 'Updated Title' };

      const res = await app.request('/todos/999', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(updatedData),
      });

      expect(res.status).toBe(404);
      expect(await res.json()).toEqual({ error: 'Todoが見つかりません' });
      expect(prismaMock.todo.update).not.toHaveBeenCalled();
    });

    test('should return 500 if there is an error during update', async () => {
      const existingTodo = { id: 1, title: 'Old Title', completed: false, createdAt: new Date().toISOString(), updatedAt: new Date().toISOString() };
      (prismaMock.todo.findUnique as jest.Mock).mockResolvedValue(existingTodo);
      (prismaMock.todo.update as jest.Mock).mockRejectedValue(new Error('Test Error'));
      const updatedData = { title: 'Updated Title' };

      const res = await app.request('/todos/1', {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(updatedData),
      });

      expect(res.status).toBe(500);
      expect(await res.json()).toEqual({ error: 'Todoの更新に失敗しました' });
    });
  });

  describe('DELETE /todos/:id', () => {
    test('should delete an existing todo and return a success message', async () => {
      const existingTodo = { id: 1, title: 'Todo to delete', completed: false, createdAt: new Date(), updatedAt: new Date() };
      (prismaMock.todo.findUnique as jest.Mock).mockResolvedValue(existingTodo);
      (prismaMock.todo.delete as jest.Mock).mockResolvedValue(existingTodo); // delete usually returns the deleted object

      const res = await app.request('/todos/1', {
        method: 'DELETE',
      });

      expect(res.status).toBe(200);
      expect(await res.json()).toEqual({ message: 'Todoが削除されました' });
      expect(prismaMock.todo.findUnique).toHaveBeenCalledTimes(1);
      expect(prismaMock.todo.findUnique).toHaveBeenCalledWith({ where: { id: 1 } });
      expect(prismaMock.todo.delete).toHaveBeenCalledTimes(1);
      expect(prismaMock.todo.delete).toHaveBeenCalledWith({ where: { id: 1 } });
    });

    test('should return 404 if todo to delete is not found', async () => {
      (prismaMock.todo.findUnique as jest.Mock).mockResolvedValue(null);

      const res = await app.request('/todos/999', {
        method: 'DELETE',
      });

      expect(res.status).toBe(404);
      expect(await res.json()).toEqual({ error: 'Todoが見つかりません' });
      expect(prismaMock.todo.delete).not.toHaveBeenCalled();
    });

    test('should return 500 if there is an error during deletion', async () => {
      const existingTodo = { id: 1, title: 'Error Todo', completed: false, createdAt: new Date(), updatedAt: new Date() };
      (prismaMock.todo.findUnique as jest.Mock).mockResolvedValue(existingTodo);
      (prismaMock.todo.delete as jest.Mock).mockRejectedValue(new Error('Test Error'));

      const res = await app.request('/todos/1', {
        method: 'DELETE',
      });

      expect(res.status).toBe(500);
      expect(await res.json()).toEqual({ error: 'Todoの削除に失敗しました' });
    });
  });
});
