import {
  buildSummarizedTalkScriptPrompt,
  buildUserDailySummaryPrompt,
} from '@/utils/promptBuilder.js';

import { globalPrisma } from '../lib/dbClient.js';

import { AiTextContentGenerator } from './aiTextContentGenerator.js';
import { TextToSpeechGenerator } from './textToSpeechGenerator.js';

import type { SavedArticle, User } from '../prisma/generated/prisma/index.js';

/**
 * 日次要約処理設定
 * @interface DailySummaryConfig
 */
interface DailySummaryConfig {
  /**
   * 処理対象のユーザーID
   * @type {number}
   */
  userId: number;
  /**
   * 対象日付（省略時は今日）
   * @type {Date} [targetDate]
   */
  targetDate?: Date;
  /**
   * 出力ディレクトリ
   * @type {string} [outputDir]
   */
  outputDir?: string;
}

/**
 * 保存された記事（ユーザー情報付き）
 * @typedef {SavedArticle & { user: Pick<User, 'id' | 'uid' | 'name'> }} SavedArticleWithUser
 */
type SavedArticleWithUser = SavedArticle & {
  user: Pick<User, 'id' | 'uid' | 'name'>;
};

/**
 * 日次要約処理結果
 * @interface DailySummaryResult
 */
interface DailySummaryResult {
  /**
   * 処理された記事数
   * @type {number}
   */
  processedArticles: number;
  /**
   * 生成された音声ファイル名
   * @type {string} [audioFileName]
   */
  audioFileName?: string;
  /**
   * 日次要約が生成されたか
   * @type {boolean}
   */
  dailySummaryGenerated: boolean;
  /**
   * 処理時間（ミリ秒）
   * @type {number}
   */
  processingTime: number;
}

/**
 * 日次要約サービス
 * @class DailySummaryService
 * @description ユーザーの保存記事から日次要約を生成し、音声ファイルを作成するサービス
 */
export class DailySummaryService {
  private readonly aiTextGenerator: AiTextContentGenerator;
  private readonly textToSpeechGenerator: TextToSpeechGenerator;

  /**
   * DailySummaryServiceのコンストラクタ
   * @constructor
   */
  constructor() {
    this.aiTextGenerator = new AiTextContentGenerator();
    this.textToSpeechGenerator = new TextToSpeechGenerator();

    // モックモードの場合はログ出力
    if (process.env.USE_MOCK_TTS === 'true') {
      console.log('🎭 音声生成モックモードで実行します');
    }
    if (process.env.USE_MOCK_SUMMARY_AI === 'true') {
      console.log('🎭 AI生成モックモードで実行します（日次要約）');
    }
  }

  /**
   * 日次要約バッチ処理メイン関数
   * @async
   * @param {DailySummaryConfig} config - 日次要約処理設定
   * @returns {Promise<DailySummaryResult>} 処理結果
   * @throws {Error} 処理に失敗した場合
   */
  async execute(config: DailySummaryConfig): Promise<DailySummaryResult> {
    const startTime = Date.now();
    console.log(`日次要約バッチ処理開始 - ユーザーID: ${config.userId}`);

    try {
      const targetDate = config.targetDate || new Date();

      // 既に当日の日次要約が存在するかチェック
      const existingSummary = await this.checkExistingDailySummary(
        config.userId,
        targetDate,
      );

      if (existingSummary) {
        console.log('要約対象がないため、処理をスキップします');
        return {
          processedArticles: 0,
          audioFileName: existingSummary.audioUrl || undefined,
          dailySummaryGenerated: false,
          processingTime: Date.now() - startTime,
        };
      }

      // 記事データの取得
      const articles = await this.fetchArticles(config.userId);

      if (articles.length === 0) {
        console.log('未処理の記事が見つかりませんでした');
        return {
          processedArticles: 0,
          dailySummaryGenerated: false,
          processingTime: Date.now() - startTime,
        };
      }

      console.log(`${articles.length}件の未処理記事から日次要約を生成開始`);

      // ステップ1: ユーザー向け日次要約を生成
      console.log('ステップ1: 日次要約生成を開始します');
      const userDailySummary = await this.generateUserDailySummary(articles);

      // ステップ2: 日次要約をDBに保存（音声URLなしで初期作成）
      console.log('ステップ2: 日次要約をDBに保存します');
      await this.createUserDailySummary(
        config.userId,
        userDailySummary,
        articles,
      );

      // ステップ3: トークスクリプト生成と音声ファイル作成
      console.log('ステップ3: 音声ファイル生成を開始します');
      const audioFileName = await this.generateTalkScriptAndAudio(
        articles,
        config.userId,
      );

      // ステップ4: 音声URLでDBをアップデート
      console.log('ステップ4: 音声URLでDBをアップデートします');
      await this.updateUserDailySummaryWithAudio(config.userId, audioFileName);

      const processingTime = Date.now() - startTime;
      console.log(`日次要約バッチ処理完了 - 処理時間: ${processingTime}ms`);

      return {
        processedArticles: articles.length,
        audioFileName,
        dailySummaryGenerated: true,
        processingTime,
      };
    } catch (error) {
      console.error('日次要約バッチ処理エラー:', error);
      throw new Error(
        `日次要約バッチ処理に失敗しました: ${error instanceof Error ? error.message : String(error)}`,
      );
    }
  }

  /**
   * 既存の日次要約をチェック
   * @async
   * @private
   * @param {number} userId - ユーザーID
   * @param {Date} targetDate - 対象日付
   * @returns {Promise<{ audioUrl: string | null } | null>} 既存の日次要約情報またはnull
   */
  private async checkExistingDailySummary(
    userId: number,
    targetDate: Date,
  ): Promise<{ audioUrl: string | null } | null> {
    try {
      const startOfDay = new Date(targetDate);
      startOfDay.setHours(0, 0, 0, 0);

      const existingSummary = await globalPrisma.userDailySummary.findUnique({
        where: {
          userId_generatedDate: {
            userId: userId,
            generatedDate: startOfDay,
          },
        },
        select: {
          audioUrl: true,
        },
      });

      return existingSummary;
    } catch (error) {
      console.error('既存日次要約チェックエラー:', error);
      return null;
    }
  }

  /**
   * ユーザーの未処理記事を取得
   * @async
   * @private
   * @param {number} userId - ユーザーID
   * @returns {Promise<SavedArticleWithUser[]>} 未処理記事の配列（最大5件）
   * @throws {Error} 記事の取得に失敗した場合
   */
  private async fetchArticles(userId: number): Promise<SavedArticleWithUser[]> {
    try {
      const articles = await globalPrisma.savedArticle.findMany({
        where: {
          userId: userId,
          userDailySummarySavedArticles: {
            none: {}, // 日次要約に含まれていない記事
          },
        },
        include: {
          user: {
            select: {
              id: true,
              uid: true,
              name: true,
            },
          },
          savedArticleSummary: true, // 要約は任意（存在しない場合もある）
        },
        orderBy: {
          createdAt: 'asc', // 古い順
        },
        take: 5, // 最大5件まで
      });

      console.log(`${articles.length}件の未処理記事を取得しました`);
      return articles;
    } catch (error) {
      console.error('記事取得エラー:', error);
      throw new Error('記事の取得に失敗しました');
    }
  }

  /**
   * トークスクリプト生成と音声ファイル作成
   * @async
   * @private
   * @param {SavedArticleWithUser[]} articles - 処理対象の記事
   * @param {number} userId - ユーザーID
   * @returns {Promise<string>} 生成された音声ファイル名
   * @throws {Error} トークスクリプトの生成に失敗した場合
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

    const audioFileName = this.generateAudioFileName();
    const generatedAudioFiles = await this.textToSpeechGenerator.generate(
      aiGeneratedTalkScript,
      audioFileName,
      userId,
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

    return audioFileName;
  }

  /**
   * 音声ファイル名生成
   * @private
   * @returns {string} タイムスタンプとランダム文字列を含むファイル名
   */
  private generateAudioFileName(): string {
    const timestamp = new Date()
      .toISOString()
      .replace(/[-:T]/g, '')
      .slice(0, 14); // YYYYMMDDHHmmss
    const randomString = Math.random().toString(36).substring(2, 15);
    return `${timestamp}_${randomString}`;
  }

  /**
   * ユーザー向け日次要約を生成
   * @async
   * @private
   * @param {SavedArticleWithUser[]} articles - 要約対象の記事
   * @returns {Promise<string>} 生成された日次要約
   * @throws {Error} 日次要約の生成に失敗した場合
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
   * UserDailySummaryレコードを作成（音声URLなし）
   * @async
   * @private
   * @param {number} userId - ユーザーID
   * @param {string} summary - 生成された日次要約
   * @param {SavedArticleWithUser[]} articles - 要約に含まれる記事
   * @returns {Promise<void>}
   * @throws {Error} UserDailySummaryの保存に失敗した場合
   */
  private async createUserDailySummary(
    userId: number,
    summary: string,
    articles: SavedArticleWithUser[],
  ): Promise<void> {
    try {
      const today = new Date();
      today.setHours(0, 0, 0, 0); // 時刻を00:00:00に設定

      console.log(
        `UserDailySummary作成開始 - ユーザーID: ${userId}, 日付: ${today.toISOString().slice(0, 10)}`,
      );

      // トランザクションでUserDailySummaryとUserDailySummarySavedArticleを作成
      await globalPrisma.$transaction(async (prisma) => {
        // UserDailySummaryを作成
        const userDailySummary = await prisma.userDailySummary.create({
          data: {
            userId: userId,
            summary: summary,
            generatedDate: today,
            audioUrl: null, // 初期は音声URLなし
          },
        });

        console.log(`UserDailySummary作成完了 - ID: ${userDailySummary.id}`);

        // UserDailySummarySavedArticleレコードを作成
        if (articles.length > 0) {
          const userDailySummarySavedArticles = articles.map((article) => ({
            userDailySummaryId: userDailySummary.id,
            savedArticleId: article.id,
          }));

          await prisma.userDailySummarySavedArticle.createMany({
            data: userDailySummarySavedArticles,
          });

          console.log(
            `UserDailySummarySavedArticle作成完了 - ${articles.length}件の関連記事を保存`,
          );
        }
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
   * UserDailySummaryレコードの音声URLを更新
   * @async
   * @private
   * @param {number} userId - ユーザーID
   * @param {string} audioFileName - 音声ファイル名
   * @returns {Promise<void>}
   * @throws {Error} UserDailySummaryの音声URL更新に失敗した場合
   */
  private async updateUserDailySummaryWithAudio(
    userId: number,
    audioFileName: string,
  ): Promise<void> {
    try {
      const today = new Date();
      today.setHours(0, 0, 0, 0); // 時刻を00:00:00に設定

      console.log(
        `UserDailySummary音声URL更新開始 - ユーザーID: ${userId}, 音声ファイル: ${audioFileName}`,
      );

      await globalPrisma.userDailySummary.update({
        where: {
          userId_generatedDate: {
            userId: userId,
            generatedDate: today,
          },
        },
        data: {
          audioUrl: audioFileName,
        },
      });

      console.log(`UserDailySummary音声URL更新完了 - ユーザーID: ${userId}`);
    } catch (error) {
      console.error(
        `UserDailySummary音声URL更新エラー - ユーザーID: ${userId}:`,
        error,
      );
      throw new Error('UserDailySummaryの音声URL更新に失敗しました');
    }
  }
}

/**
 * 日次要約バッチメイン実行関数
 * @async
 * @function main
 * @description 全ユーザーを対象に未処理記事があるユーザーの日次要約をバッチ処理で生成
 * @returns {Promise<void>}
 */
async function main(): Promise<void> {
  console.log('日次要約バッチ処理開始 (全ユーザー対象 - チャンク処理)');
  const service = new DailySummaryService();
  let totalSuccessCount = 0;
  let totalFailureCount = 0;
  const chunkSize = 10;

  try {
    const users = await globalPrisma.user.findMany({
      where: {
        savedArticles: {
          some: {
            userDailySummarySavedArticles: {
              none: {}, // user_daily_summary_saved_articlesに含まれていない
            },
          },
        },
      },
      select: { id: true },
      orderBy: { id: 'asc' },
    });
    if (users.length === 0) {
      console.log('処理対象のユーザーが見つかりませんでした。');
      return;
    }

    console.log(
      `${users.length}人のユーザーを${chunkSize}件ずつのチャンクで処理します。`,
    );

    for (let i = 0; i < users.length; i += chunkSize) {
      const chunk = users.slice(i, i + chunkSize);
      console.log(
        `チャンク ${Math.floor(i / chunkSize) + 1} の処理を開始 (ユーザー ${i + 1} から ${Math.min(i + chunkSize, users.length)})`,
      );

      let chunkSuccessCount = 0;
      let chunkFailureCount = 0;

      for (const user of chunk) {
        try {
          console.log(`  ユーザーID: ${user.id} の処理を開始します。`);

          const result = await service.execute({ userId: user.id });

          console.log(
            `  === ユーザーID: ${user.id} の日次要約バッチ処理結果 ===`,
          );
          console.log(`    処理記事数: ${result.processedArticles}`);
          console.log(`    音声ファイル: ${result.audioFileName || 'なし'}`);
          console.log(
            `    日次要約生成: ${result.dailySummaryGenerated ? '成功' : '既存またはスキップ'}`,
          );
          console.log(`    処理時間: ${result.processingTime}ms`);
          console.log('  ===================================');
          totalSuccessCount++;
          chunkSuccessCount++;
        } catch (error) {
          console.error(
            `  ユーザーID: ${user.id} の処理中にエラーが発生しました:`,
            error,
          );
          totalFailureCount++;
          chunkFailureCount++;
        }
      }
      console.log(
        `チャンク ${Math.floor(i / chunkSize) + 1} の処理完了 - 成功: ${chunkSuccessCount}, 失敗: ${chunkFailureCount}`,
      );
    }
  } catch (error) {
    console.error('日次要約バッチ処理の全体でエラーが発生しました:', error);
    // 全体エラーの場合、ここで終了する
    process.exit(1);
  } finally {
    console.log('=== 全ユーザーの日次要約バッチ処理完了 (チャンク処理) ===');
    console.log(`総成功ユーザー数: ${totalSuccessCount}`);
    console.log(`総失敗ユーザー数: ${totalFailureCount}`);
    console.log('==================================================');
    // process.exit(0); // 通常は不要
  }
}

// スクリプトとして直接実行された場合のみメイン関数を実行
if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}
