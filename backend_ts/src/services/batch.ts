import {
  buildArticleSummaryPrompt,
  buildSummarizedTalkScriptPrompt,
  buildUserDailySummaryPrompt,
} from '@/utils/promptBuilder.js';

import { globalPrisma } from '../lib/dbClient.js';

import { AiTextContentGenerator } from './aiTextContentGenerator.js';
import { TextToSpeechGenerator } from './textToSpeechGenerator.js';

import type { SavedArticle, User } from '../prisma/generated/prisma/index.js';

/**
 * バッチ処理設定
 */
interface BatchProcessConfig {
  /** 処理対象のユーザーID */
  userId: number;
  /** 出力ディレクトリ */
  outputDir?: string;
  /** 並列処理数の制限 */
  concurrencyLimit?: number;
}

/**
 * 保存された記事（ユーザー情報付き）
 */
type SavedArticleWithUser = SavedArticle & {
  user: Pick<User, 'id' | 'uid' | 'name'>;
};

/**
 * バッチ処理結果
 */
interface BatchProcessResult {
  /** 処理された記事数 */
  processedArticles: number;
  /** 生成された音声ファイル名 */
  audioFileName?: string;
  /** 処理時間（ミリ秒） */
  processingTime: number;
}

/**
 * バッチ処理サービス
 */
export class BatchProcessService {
  private readonly aiTextGenerator: AiTextContentGenerator;
  private readonly textToSpeechGenerator: TextToSpeechGenerator;
  private readonly concurrencyLimit: number;

  constructor(concurrencyLimit: number = 3) {
    this.aiTextGenerator = new AiTextContentGenerator();
    this.textToSpeechGenerator = new TextToSpeechGenerator();
    this.concurrencyLimit = concurrencyLimit;

    // モックモードの場合はログ出力
    if (process.env.USE_MOCK_TTS === 'true') {
      console.log('🎭 音声生成モックモードで実行します');
    }
    if (process.env.USE_MOCK_SUMMERY_AI === 'true') {
      console.log('🤖 AI生成モックモードで実行します');
    }
  }

  /**
   * バッチ処理メイン関数
   */
  async execute(config: BatchProcessConfig): Promise<BatchProcessResult> {
    const startTime = Date.now();
    console.log(`バッチ処理開始 - ユーザーID: ${config.userId}`);

    try {
      // 記事データの取得
      const articles = await this.fetchUserArticles(config.userId);

      if (articles.length === 0) {
        console.log('処理対象の記事が見つかりませんでした');
        return {
          processedArticles: 0,
          processingTime: Date.now() - startTime,
        };
      }

      console.log(`${articles.length}件の記事を処理開始`);

      // 記事要約の並列処理
      await this.processArticleSummaries(articles);

      // トークスクリプト生成と音声ファイル作成
      const audioFileName = await this.generateTalkScriptAndAudio(
        articles,
        config.userId,
      );

      const processingTime = Date.now() - startTime;
      console.log(`バッチ処理完了 - 処理時間: ${processingTime}ms`);

      return {
        processedArticles: articles.length,
        audioFileName,
        processingTime,
      };
    } catch (error) {
      console.error('バッチ処理エラー:', error);
      throw new Error(
        `バッチ処理に失敗しました: ${error instanceof Error ? error.message : String(error)}`,
      );
    }
  }

  /**
   * ユーザーの保存記事を取得
   */
  private async fetchUserArticles(
    userId: number,
  ): Promise<SavedArticleWithUser[]> {
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

      console.log(`${articles.length}件の記事を取得しました`);
      return articles;
    } catch (error) {
      console.error('記事取得エラー:', error);
      throw new Error('記事の取得に失敗しました');
    }
  }

  /**
   * 記事要約の並列処理
   */
  private async processArticleSummaries(
    articles: SavedArticleWithUser[],
  ): Promise<void> {
    console.log('記事要約処理を開始します');

    // 並列処理数を制限しながら処理
    const chunks = this.chunkArray(articles, this.concurrencyLimit);

    for (const chunk of chunks) {
      const promises = chunk.map((article) =>
        this.processArticleSummary(article),
      );
      await Promise.allSettled(promises);
    }

    console.log('記事要約処理が完了しました');
  }

  /**
   * 単一記事の要約処理
   */
  private async processArticleSummary(
    article: SavedArticleWithUser,
  ): Promise<void> {
    try {
      const prompt = buildArticleSummaryPrompt(article.url);
      console.log(`記事要約生成開始 - ID: ${article.id}, URL: ${article.url}`);

      const aiGeneratedSummaryText =
        await this.aiTextGenerator.generate(prompt);

      if (!aiGeneratedSummaryText) {
        console.warn(`記事要約生成失敗 - ID: ${article.id}`);
        return;
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
    } catch (error) {
      console.error(`記事要約処理エラー - ID: ${article.id}:`, error);
      // 個別の記事処理エラーは全体処理を止めない
    }
  }

  /**
   * トークスクリプト生成と音声ファイル作成
   */
  private async generateTalkScriptAndAudio(
    articles: SavedArticleWithUser[],
    userId: number,
  ): Promise<string> {
    console.log('トークスクリプト生成を開始します');

    const urls = articles.map((article) => article.url);
    const prompt = buildSummarizedTalkScriptPrompt(urls);

    console.log(`トークスクリプト生成 - ${urls.length}件の記事を処理`);

    const aiGeneratedTalkScript = await this.aiTextGenerator.generate(prompt);

    if (!aiGeneratedTalkScript) {
      throw new Error('トークスクリプトの生成に失敗しました');
    }

    console.log('トークスクリプト生成完了、音声ファイル作成を開始します');

    const audioFileName = this.generateAudioFileName(userId, articles);
    const generatedAudioFiles = await this.textToSpeechGenerator.generate(
      aiGeneratedTalkScript,
      audioFileName,
    );

    console.log(
      `音声ファイル作成完了 - ${generatedAudioFiles.length}件のファイルが生成されました`,
    );

    // 最初の音声ファイルのGCS URIをaudioUrlとして使用
    const audioUrl =
      generatedAudioFiles.length > 0 ? generatedAudioFiles[0] : '';

    if (!audioUrl) {
      console.warn('音声ファイルが生成されませんでした');
    }

    // 日次要約を生成
    console.log('日次要約生成を開始します');
    const userDailySummary = await this.generateUserDailySummary(articles);

    // UserDailySummaryレコードを作成または更新
    await this.createOrUpdateUserDailySummary(
      userId,
      userDailySummary,
      audioUrl,
    );

    return audioFileName;
  }

  /**
   * 音声ファイル名生成
   */
  private generateAudioFileName(
    userId: number,
    articles: SavedArticleWithUser[],
  ): string {
    const timestamp = new Date().toISOString().slice(0, 10); // YYYY-MM-DD
    const articleIds = articles
      .slice(0, 5)
      .map((article) => article.id)
      .join('-'); // 最初の5つのIDのみ使用
    return `user-${userId}_${timestamp}_${articleIds}`;
  }

  /**
   * ユーザー向け日次要約を生成
   */
  private async generateUserDailySummary(
    articles: SavedArticleWithUser[],
  ): Promise<string> {
    try {
      const urls = articles.map((article) => article.url);
      const prompt = buildUserDailySummaryPrompt(urls);

      console.log(`日次要約生成 - ${urls.length}件の記事を処理`);

      const aiGeneratedSummary = await this.aiTextGenerator.generate(prompt);

      if (!aiGeneratedSummary) {
        throw new Error('日次要約の生成に失敗しました');
      }

      console.log('日次要約生成完了');
      return aiGeneratedSummary;
    } catch (error) {
      console.error('日次要約生成エラー:', error);
      throw new Error('日次要約の生成に失敗しました');
    }
  }

  /**
   * UserDailySummaryレコードを作成または更新
   */
  private async createOrUpdateUserDailySummary(
    userId: number,
    summary: string,
    audioFileName: string,
  ): Promise<void> {
    try {
      const today = new Date();
      today.setHours(0, 0, 0, 0); // 時刻を00:00:00に設定

      console.log(
        `UserDailySummary作成開始 - ユーザーID: ${userId}, 日付: ${today.toISOString().slice(0, 10)}`,
      );

      await globalPrisma.userDailySummary.upsert({
        where: {
          userId_generatedDate: {
            userId: userId,
            generatedDate: today,
          },
        },
        update: {
          summary: summary,
          audioUrl: audioFileName,
        },
        create: {
          userId: userId,
          summary: summary,
          audioUrl: audioFileName,
          generatedDate: today,
        },
      });

      console.log(`UserDailySummary保存完了 - ユーザーID: ${userId}`);
    } catch (error) {
      console.error(
        `UserDailySummary保存エラー - ユーザーID: ${userId}:`,
        error,
      );
      throw new Error('UserDailySummaryの保存に失敗しました');
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
 * メイン実行関数
 */
async function main(): Promise<void> {
  try {
    // 環境変数からユーザーIDを取得（デフォルト: 1）
    const userId = Number(process.env.BATCH_USER_ID) || 1;
    const concurrencyLimit = Number(process.env.BATCH_CONCURRENCY_LIMIT) || 3;

    const service = new BatchProcessService(concurrencyLimit);
    const result = await service.execute({ userId });

    console.log('=== バッチ処理結果 ===');
    console.log(`処理記事数: ${result.processedArticles}`);
    console.log(`音声ファイル: ${result.audioFileName || 'なし'}`);
    console.log(`処理時間: ${result.processingTime}ms`);
    console.log('==================');
  } catch (error) {
    console.error('メイン処理エラー:', error);
    process.exit(1);
  }
}

// スクリプトとして直接実行された場合のみメイン関数を実行
if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}
