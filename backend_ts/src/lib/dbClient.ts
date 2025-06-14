import { PrismaClient } from '../prisma/generated/prisma/index.js';

console.log('=== dbClient.ts initialization ===');

// 必要な環境変数の存在確認
const requiredEnvVars = [
  'DB_HOST',
  'DB_PORT',
  'DB_USER',
  'DB_PASSWORD',
  'DB_NAME',
];
const missingEnvVars = requiredEnvVars.filter(
  (varName) => !process.env[varName],
);

if (missingEnvVars.length > 0) {
  console.error('❌ Missing required environment variables:', missingEnvVars);
} else {
  console.log('✅ All required database environment variables are set');
}

console.log('DB_HOST:', process.env.DB_HOST);
console.log('DB_PORT:', process.env.DB_PORT);
console.log('DB_USER:', process.env.DB_USER);
console.log('DB_NAME:', process.env.DB_NAME);
console.log('DB_PASSWORD exists:', !!process.env.DB_PASSWORD);
console.log('DB_SOCKET_PATH:', process.env.DB_SOCKET_PATH);

// DATABASE_URLの動的構築
const buildDatabaseUrl = (): string => {
  const dbHost = process.env.DB_HOST;
  const dbPort = process.env.DB_PORT;
  const dbUser = process.env.DB_USER;
  const dbPassword = process.env.DB_PASSWORD;
  const dbName = process.env.DB_NAME;
  const dbSocketPath = process.env.DB_SOCKET_PATH;

  // 必須環境変数のチェック
  if (!dbHost || !dbPort || !dbUser || !dbPassword || !dbName) {
    const missing = [];
    if (!dbHost) missing.push('DB_HOST');
    if (!dbPort) missing.push('DB_PORT');
    if (!dbUser) missing.push('DB_USER');
    if (!dbPassword) missing.push('DB_PASSWORD');
    if (!dbName) missing.push('DB_NAME');

    throw new Error(
      `Missing required database environment variables: ${missing.join(', ')}`,
    );
  }

  // Cloud SQL Proxy（Unix Socket）を使用する場合
  if (dbSocketPath) {
    const socketUrl = `mysql://${dbUser}:${dbPassword}@localhost/${dbName}?socket=${dbSocketPath}`;
    console.log('Using Cloud SQL Proxy connection (Unix Socket)');
    console.log('Socket path:', dbSocketPath);
    return socketUrl;
  }

  // 通常のTCP接続を使用する場合（ローカル開発など）
  const tcpUrl = `mysql://${dbUser}:${dbPassword}@${dbHost}:${dbPort}/${dbName}`;
  console.log('Using TCP connection');
  console.log('Host:', dbHost, 'Port:', dbPort);
  return tcpUrl;
};

/** グローバル空間に型を定義する（TypeScriptの場合） */
declare global {
  var prisma: PrismaClient | undefined;
}

/** PrismaClient のインスタンスを生成または再利用 */
export const getPrisma = (): PrismaClient => {
  console.log('getPrisma called, checking database environment variables...');

  // グローバル空間にPrismaClientのインスタンスがない場合は、新規生成する。
  if (!global.prisma) {
    try {
      console.log('Creating new PrismaClient instance...');

      // DATABASE_URLを動的に構築
      const databaseUrl = buildDatabaseUrl();

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
    } finally {
      console.log('=== dbClient.ts initialization end ===\n\n');
    }
  }
  return global.prisma;
};

/** シングルトンなGlobal PrismaClient */
export const globalPrisma = getPrisma();
