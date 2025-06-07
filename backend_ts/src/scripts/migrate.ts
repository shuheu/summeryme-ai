import { execSync } from 'child_process';

console.log('=== Starting Prisma Migration ===');

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
  process.exit(1);
}

console.log('✅ All required database environment variables are set');
console.log('DB_HOST:', process.env.DB_HOST);
console.log('DB_PORT:', process.env.DB_PORT);
console.log('DB_USER:', process.env.DB_USER);
console.log('DB_NAME:', process.env.DB_NAME);
console.log('DB_PASSWORD exists:', !!process.env.DB_PASSWORD);
console.log('DB_SOCKET_PATH:', process.env.DB_SOCKET_PATH);

// DATABASE_URLの動的構築（dbClient.tsと同じロジック）
const buildDatabaseUrl = (): string => {
  const dbHost = process.env.DB_HOST!;
  const dbPort = process.env.DB_PORT!;
  const dbUser = process.env.DB_USER!;
  const dbPassword = process.env.DB_PASSWORD!;
  const dbName = process.env.DB_NAME!;
  const dbSocketPath = process.env.DB_SOCKET_PATH;

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

try {
  // DATABASE_URLを環境変数に設定
  const databaseUrl = buildDatabaseUrl();
  process.env.DATABASE_URL = databaseUrl;
  console.log('✅ DATABASE_URL constructed successfully');

  // Prismaクライアントの生成
  console.log('Generating Prisma client...');
  execSync('npx prisma generate', { stdio: 'inherit' });

  // マイグレーションの実行
  console.log('Running Prisma migrations...');
  execSync('npx prisma migrate deploy', { stdio: 'inherit' });

  console.log('✅ Migration completed successfully');
} catch (error) {
  console.error('❌ Migration failed:', error);
  process.exit(1);
}
