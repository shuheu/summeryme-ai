import { buildArticleSummaryPrompt } from '@/utils/promptBuilder.js';

import { globalPrisma } from '../lib/dbClient.js';

import { AiTextContentGenerator } from './aiTextContentGenerator.js';

import type { SavedArticle, User } from '../prisma/generated/prisma/index.js';

/**
 * 記事要約処理設定
 */
interface ArticleSummaryConfig {
  /** 処理対象のユーザーID（allUsersがtrueの場合は無視される） */
  userId?: number;
  /** 全ユーザーを処理対象とするか */
  allUsers?: boolean;
  /** 並列処理数の制限 */
  concurrencyLimit?: number;
}

/**
 * 保存された記事（ユーザー情報付き）
 */
type SavedArticleWithUser = SavedArticle & {
  user: Pick<User, 'id'>;
};

/**
 * 記事要約処理結果
 */
interface ArticleSummaryResult {
  /** 処理された記事数 */
  processedArticles: number;
  /** 成功した記事数 */
  successfulArticles: number;
  /** 失敗した記事数 */
  failedArticles: number;
  /** 処理時間（ミリ秒） */
  processingTime: number;
}

/**
 * 記事要約サービス
 */
export class ArticleSummaryService {
  private readonly aiTextGenerator: AiTextContentGenerator;
  private readonly concurrencyLimit: number;

  constructor(concurrencyLimit: number = 3) {
    this.aiTextGenerator = new AiTextContentGenerator();
    this.concurrencyLimit = concurrencyLimit;

    // モックモードの場合はログ出力
    if (process.env.USE_MOCK_SUMMARY_AI === 'true') {
      console.log('🤖 AI生成モックモードで実行します（記事要約）');
    }
  }

  /**
   * 記事要約バッチ処理メイン関数
   */
  async execute(config: ArticleSummaryConfig): Promise<ArticleSummaryResult> {
    const startTime = Date.now();

    if (config.allUsers) {
      console.log('記事要約バッチ処理開始 - 全ユーザー対象');
    } else {
      console.log(`記事要約バッチ処理開始 - ユーザーID: ${config.userId}`);
    }

    try {
      // 要約が未生成の記事データの取得
      const articles = config.allUsers
        ? await this.fetchAllUsersUnsummarizedArticles()
        : await this.fetchUnsummarizedArticles(config.userId!);

      if (articles.length === 0) {
        console.log('要約対象の記事が見つかりませんでした');
        return {
          processedArticles: 0,
          successfulArticles: 0,
          failedArticles: 0,
          processingTime: Date.now() - startTime,
        };
      }

      console.log(`${articles.length}件の記事要約を処理開始`);

      // 記事要約の並列処理
      const result = await this.processArticleSummaries(articles);

      const processingTime = Date.now() - startTime;
      console.log(`記事要約バッチ処理完了 - 処理時間: ${processingTime}ms`);

      return {
        processedArticles: articles.length,
        successfulArticles: result.successfulArticles,
        failedArticles: result.failedArticles,
        processingTime,
      };
    } catch (error) {
      console.error('記事要約バッチ処理エラー:', error);
      throw new Error(
        `記事要約バッチ処理に失敗しました: ${error instanceof Error ? error.message : String(error)}`,
      );
    }
  }

  /**
   * 全ユーザーの要約未生成記事を取得
   */
  private async fetchAllUsersUnsummarizedArticles(): Promise<
    SavedArticleWithUser[]
  > {
    try {
      const articles = await globalPrisma.savedArticle.findMany({
        where: {
          savedArticleSummary: null, // 要約が未生成の記事のみ
        },
        include: {
          user: {
            select: {
              id: true,
            },
          },
        },
        orderBy: [
          { userId: 'asc' }, // ユーザーごとにグループ化
          { createdAt: 'desc' },
        ],
      });

      console.log(
        `${articles.length}件の要約未生成記事を取得しました（全ユーザー対象）`,
      );
      return articles;
    } catch (error) {
      console.error('要約未生成記事取得エラー（全ユーザー）:', error);
      throw new Error('要約未生成記事の取得に失敗しました');
    }
  }

  /**
   * 特定ユーザーの要約未生成記事を取得
   */
  private async fetchUnsummarizedArticles(
    userId: number,
  ): Promise<SavedArticleWithUser[]> {
    try {
      const articles = await globalPrisma.savedArticle.findMany({
        where: {
          userId: userId,
          savedArticleSummary: null, // 要約が未生成の記事のみ
        },
        include: {
          user: {
            select: {
              id: true,
            },
          },
        },
        orderBy: {
          createdAt: 'desc',
        },
      });

      console.log(`${articles.length}件の要約未生成記事を取得しました`);
      return articles;
    } catch (error) {
      console.error('要約未生成記事取得エラー:', error);
      throw new Error('要約未生成記事の取得に失敗しました');
    }
  }

  /**
   * 記事要約の並列処理
   */
  private async processArticleSummaries(
    articles: SavedArticleWithUser[],
  ): Promise<{ successfulArticles: number; failedArticles: number }> {
    console.log('記事要約処理を開始します');

    let successfulArticles = 0;
    let failedArticles = 0;

    // ユーザー単位での統計表示用
    const userStats = new Map<number, { success: number; failed: number }>();

    // 並列処理数を制限しながら処理
    const chunks = this.chunkArray(articles, this.concurrencyLimit);

    for (let i = 0; i < chunks.length; i++) {
      const chunk = chunks[i];
      console.log(
        `チャンク ${i + 1}/${chunks.length} 処理中 (${chunk.length}件)`,
      );

      const promises = chunk.map((article) =>
        this.processArticleSummary(article),
      );
      const results = await Promise.allSettled(promises);

      // 成功・失敗数をカウント & ユーザー別統計を更新
      results.forEach((result, index) => {
        const article = chunk[index];
        const userId = article.user.id;

        if (!userStats.has(userId)) {
          userStats.set(userId, { success: 0, failed: 0 });
        }
        const stats = userStats.get(userId)!;

        if (result.status === 'fulfilled' && result.value) {
          successfulArticles++;
          stats.success++;
        } else {
          failedArticles++;
          stats.failed++;
        }
      });
    }

    // ユーザー別統計を表示
    console.log('\n=== ユーザー別処理結果 ===');
    userStats.forEach((stats, userId) => {
      const total = stats.success + stats.failed;
      console.log(`ユーザー (ID: ${userId}): 成功 ${stats.success}/${total}件`);
    });

    console.log(
      `\n記事要約処理が完了しました - 成功: ${successfulArticles}件, 失敗: ${failedArticles}件`,
    );

    return { successfulArticles, failedArticles };
  }

  /**
   * 単一記事の要約処理
   */
  private async processArticleSummary(
    article: SavedArticleWithUser,
  ): Promise<boolean> {
    try {
      const prompt = buildArticleSummaryPrompt(article.url);
      console.log(`記事要約生成開始 - ID: ${article.id}, URL: ${article.url}`);

      const aiGeneratedSummaryText =
        await this.aiTextGenerator.generate(prompt);

      if (!aiGeneratedSummaryText) {
        console.warn(`記事要約生成失敗 - ID: ${article.id}`);
        return false;
      }

      await globalPrisma.savedArticleSummary.upsert({
        where: {
          savedArticleId: article.id,
        },
        update: {
          summary: aiGeneratedSummaryText,
        },
        create: {
          savedArticleId: article.id,
          summary: aiGeneratedSummaryText,
        },
      });

      console.log(`記事要約保存完了 - ID: ${article.id}`);
      return true;
    } catch (error) {
      console.error(`記事要約処理エラー - ID: ${article.id}:`, error);
      return false;
    }
  }

  /**
   * 配列を指定サイズのチャンクに分割
   */
  private chunkArray<T>(array: T[], chunkSize: number): T[][] {
    const chunks: T[][] = [];
    for (let i = 0; i < array.length; i += chunkSize) {
      chunks.push(array.slice(i, i + chunkSize));
    }
    return chunks;
  }
}

/**
 * 記事要約バッチメイン実行関数
 */
async function main(): Promise<void> {
  try {
    const concurrencyLimit = Number(process.env.BATCH_CONCURRENCY_LIMIT) || 3;
    const service = new ArticleSummaryService(concurrencyLimit);

    // デフォルトで全ユーザー処理
    const result = await service.execute({ allUsers: true });

    console.log('=== 記事要約バッチ処理結果 ===');
    console.log(`処理記事数: ${result.processedArticles}`);
    console.log(`成功記事数: ${result.successfulArticles}`);
    console.log(`失敗記事数: ${result.failedArticles}`);
    console.log(`処理時間: ${result.processingTime}ms`);
    console.log('=========================');
  } catch (error) {
    console.error('記事要約バッチメイン処理エラー:', error);
    process.exit(1);
  }
}

// スクリプトとして直接実行された場合のみメイン関数を実行
if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}
