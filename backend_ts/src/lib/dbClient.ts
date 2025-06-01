import { PrismaClient } from '../prisma/generated/prisma/index.js';

/** グローバル空間に型を定義する（TypeScriptの場合） */
declare global {
  var prisma: PrismaClient | undefined;
}

/** PrismaClient のインスタンスを生成または再利用 */
export const getPrisma = (): PrismaClient => {
  // グローバル空間にPrismaClientのインスタンスがない場合は、新規生成する。
  if (!global.prisma) {
    global.prisma = new PrismaClient();
  }
  return global.prisma;
};

/** シングルトンなGlobal PrismaClient */
export const globalPrisma = getPrisma();
