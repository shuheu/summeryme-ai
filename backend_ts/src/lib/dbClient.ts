import { PrismaClient } from '../prisma/generated/prisma/index.js';

console.log('=== dbClient.ts initialization ===');
console.log('DATABASE_URL exists:', !!process.env.DATABASE_URL);
console.log('DATABASE_URL length:', process.env.DATABASE_URL?.length || 0);
console.log('DB_PASSWORD exists:', !!process.env.DB_PASSWORD);

// DATABASE_URLの動的展開
const getDatabaseUrl = (): string => {
  const rawDatabaseUrl = process.env.DATABASE_URL;
  const dbPassword = process.env.DB_PASSWORD;

  if (!rawDatabaseUrl) {
    throw new Error('DATABASE_URL environment variable is not set');
  }

  if (!dbPassword) {
    throw new Error('DB_PASSWORD environment variable is not set');
  }

  // ${DB_PASSWORD}を実際のパスワードに置換
  const expandedUrl = rawDatabaseUrl.replace('${DB_PASSWORD}', dbPassword);

  console.log('Database URL expanded successfully');
  console.log(
    'Original URL contains placeholder:',
    rawDatabaseUrl.includes('${DB_PASSWORD}'),
  );
  console.log(
    'Expanded URL contains placeholder:',
    expandedUrl.includes('${DB_PASSWORD}'),
  );

  return expandedUrl;
};

// 環境変数が設定されていない場合の警告
if (!process.env.DATABASE_URL) {
  console.error('❌ DATABASE_URL is not set!');
  console.error(
    'Available environment variables:',
    Object.keys(process.env).sort(),
  );
}

if (!process.env.DB_PASSWORD) {
  console.error('❌ DB_PASSWORD is not set!');
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

      // DATABASE_URLを動的に展開
      const databaseUrl = getDatabaseUrl();

      global.prisma = new PrismaClient({
        log:
          process.env.NODE_ENV === 'development'
            ? ['query', 'info', 'warn', 'error']
            : ['error'],
        datasources: {
          db: {
            url: databaseUrl,
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
