import { PrismaClient } from '../prisma/generated/prisma/index.js';

console.log('=== dbClient.ts initialization ===');
console.log('DATABASE_URL exists:', !!process.env.DATABASE_URL);
console.log('DATABASE_URL length:', process.env.DATABASE_URL?.length || 0);

// 環境変数が設定されていない場合の警告
if (!process.env.DATABASE_URL) {
  console.error('❌ DATABASE_URL is not set!');
  console.error(
    'Available environment variables:',
    Object.keys(process.env).sort(),
  );
}

/** グローバル空間に型を定義する（TypeScriptの場合） */
declare global {
  var prisma: PrismaClient | undefined;
}

/** PrismaClient のインスタンスを生成または再利用 */
export const getPrisma = (): PrismaClient => {
  console.log(
    'getPrisma called, DATABASE_URL exists:',
    !!process.env.DATABASE_URL,
  );

  // グローバル空間にPrismaClientのインスタンスがない場合は、新規生成する。
  if (!global.prisma) {
    try {
      console.log('Creating new PrismaClient instance...');
      global.prisma = new PrismaClient({
        log:
          process.env.NODE_ENV === 'development'
            ? ['query', 'info', 'warn', 'error']
            : ['error'],
        datasources: {
          db: {
            url: process.env.DATABASE_URL,
          },
        },
      });
      console.log('✅ PrismaClient created successfully');
    } catch (error) {
      console.error('❌ Failed to create PrismaClient:', error);
      throw error;
    }
  }
  return global.prisma;
};

/** シングルトンなGlobal PrismaClient */
export const globalPrisma = getPrisma();
