import { globalPrisma } from '../lib/dbClient.js';

/**
 * バッチ処理メイン関数
 */
export async function batchProcess() {
  console.log('Batch process started');

  try {
    // 特定のユーザーID（実際の実装では引数で受け取るか、環境変数から取得）
    const userId = 1;

    try {
      const articles = await globalPrisma.savedArticle.findMany({
        where: {
          userId: userId,
        },
        include: {
          user: {
            select: {
              id: true,
              uid: true,
              name: true,
            },
          },
        },
        orderBy: {
          createdAt: 'desc',
        },
      });

      console.log(articles);

      return articles;
    } catch (error) {
      console.error('記事取得エラー:', error);
      throw error;
    }
  } catch (error) {
    console.error('Batch process error:', error);
    throw error;
  }
}

function main() {
  batchProcess();
}

main();
