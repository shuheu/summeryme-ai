import type { PrismaClient } from '../prisma/generated/prisma/index.js';

export interface ProcessingResult {
  success: boolean;
  processedCount: number;
  errors: Array<{ id: number; error: string }>;
  duration: number;
}

export class ArticleProcessorService {
  constructor(private _prisma: PrismaClient) {}

  /**
   * 未要約の記事を取得
   */
  // async getUnprocessedArticles(limit: number = 10) {
  //   try {
  //     const articles = await this._prisma.savedArticle.findMany({
  //       where: {
  //         savedArticleSummary: null,
  //       },
  //       orderBy: {
  //         createdAt: 'asc',
  //       },
  //       take: limit,
  //       include: {
  //         user: {
  //           select: {
  //             id: true,
  //             name: true,
  //           },
  //         },
  //       },
  //     });

  //     return articles;
  //   } catch (error) {
  //     console.error('未処理記事の取得に失敗しました:', error);
  //     throw new Error('未処理記事の取得に失敗しました');
  //   }
  // }

  // /**
  //  * 記事の要約を生成・保存（バッチ処理対応）
  //  */
  // async processArticlesBatch(limit: number = 10): Promise<ProcessingResult> {
  //   const startTime = Date.now();
  //   const errors: Array<{ id: number; error: string }> = [];
  //   let processedCount = 0;

  //   try {
  //     const articles = await this.getUnprocessedArticles(limit);

  //     if (articles.length === 0) {
  //       return {
  //         success: true,
  //         processedCount: 0,
  //         errors: [],
  //         duration: Date.now() - startTime,
  //       };
  //     }

  //     console.log(`${articles.length}件の記事を処理開始`);

  //     // 並列処理で効率化（ただし、API制限を考慮して制限）
  //     const batchSize = 3;
  //     for (let i = 0; i < articles.length; i += batchSize) {
  //       const batch = articles.slice(i, i + batchSize);

  //       await Promise.allSettled(
  //         batch.map(async (article) => {
  //           try {
  //             // TODO: 実際のAI要約処理を実装
  //             // const summary = await this.generateAISummary(article.url);
  //             const mockSummary = `【AI要約】${article.title}\n\nこの記事の主要なポイントを要約した内容です。実際の実装では、記事のコンテンツを取得してAIで要約処理を行います。`;

  //             await this._prisma.savedArticleSummary.create({
  //               data: {
  //                 savedArticleId: article.id,
  //                 summary: mockSummary,
  //               },
  //             });

  //             processedCount++;
  //             console.log(`記事ID ${article.id} の要約を生成しました`);
  //           } catch (error) {
  //             const errorMessage = error instanceof Error ? error.message : '不明なエラー';
  //             errors.push({ id: article.id, error: errorMessage });
  //             console.error(`記事ID ${article.id} の処理に失敗:`, error);
  //           }
  //         })
  //       );
  //     }

  //     return {
  //       success: errors.length === 0,
  //       processedCount,
  //       errors,
  //       duration: Date.now() - startTime,
  //     };
  //   } catch (error) {
  //     console.error('記事バッチ処理に失敗しました:', error);
  //     throw error;
  //   }
  // }

  // /**
  //  * 日次要約生成の対象ユーザーを取得
  //  */
  // async getUsersForDailySummary(targetDate: Date) {
  //   const startOfDay = new Date(targetDate);
  //   startOfDay.setHours(0, 0, 0, 0);

  //   const endOfDay = new Date(targetDate);
  //   endOfDay.setHours(23, 59, 59, 999);

  //   // 指定日に要約済み記事があるユーザーを取得
  //   const users = await this._prisma.user.findMany({
  //     where: {
  //       savedArticles: {
  //         some: {
  //           createdAt: {
  //             gte: startOfDay,
  //             lte: endOfDay,
  //           },
  //           savedArticleSummary: {
  //             isNot: null,
  //           },
  //         },
  //       },
  //     },
  //     include: {
  //       _count: {
  //         select: {
  //           savedArticles: {
  //             where: {
  //               createdAt: {
  //                 gte: startOfDay,
  //                 lte: endOfDay,
  //               },
  //               savedArticleSummary: {
  //                 isNot: null,
  //               },
  //             },
  //           },
  //         },
  //       },
  //     },
  //   });

  //   return users;
  // }

  // /**
  //  * 日次要約とpodcast音声生成（バッチ処理対応）
  //  */
  // async generateDailySummariesBatch(targetDate: Date): Promise<ProcessingResult> {
  //   const startTime = Date.now();
  //   const errors: Array<{ id: number; error: string }> = [];
  //   let processedCount = 0;

  //   try {
  //     const users = await this.getUsersForDailySummary(targetDate);

  //     if (users.length === 0) {
  //       console.log(`${targetDate.toISOString().split('T')[0]} には処理対象のユーザーがいません`);
  //       return {
  //         success: true,
  //         processedCount: 0,
  //         errors: [],
  //         duration: Date.now() - startTime,
  //       };
  //     }

  //     console.log(`${users.length}人のユーザーの日次要約を処理開始`);

  //     for (const user of users) {
  //       try {
  //         // 既に日次要約が存在するかチェック
  //         const existingSummary = await this._prisma.userDailySummary.findUnique({
  //           where: {
  //             userId_generatedDate: {
  //               userId: user.id,
  //               generatedDate: targetDate,
  //             },
  //           },
  //         });

  //         if (existingSummary) {
  //           console.log(`ユーザーID ${user.id} の日次要約は既に存在します`);
  //           continue;
  //         }

  //         const dailySummary = await this.generateUserDailySummary(user.id, targetDate);

  //         if (dailySummary) {
  //           // TODO: 実際のpodcast音声生成処理を実装
  //           // const audioUrl = await this.generatePodcastAudio(dailySummary.summary);
  //           const mockAudioUrl = `https://storage.googleapis.com/your-bucket/audio/${dailySummary.id}_${targetDate.toISOString().split('T')[0]}.mp3`;

  //           await this._prisma.userDailySummary.update({
  //             where: { id: dailySummary.id },
  //             data: { audioUrl: mockAudioUrl },
  //           });

  //           processedCount++;
  //           console.log(`ユーザーID ${user.id} の日次要約とpodcast音声を生成しました`);
  //         }
  //       } catch (error) {
  //         const errorMessage = error instanceof Error ? error.message : '不明なエラー';
  //         errors.push({ id: user.id, error: errorMessage });
  //         console.error(`ユーザーID ${user.id} の日次要約生成に失敗:`, error);
  //       }
  //     }

  //     return {
  //       success: errors.length === 0,
  //       processedCount,
  //       errors,
  //       duration: Date.now() - startTime,
  //     };
  //   } catch (error) {
  //     console.error('日次要約バッチ処理に失敗しました:', error);
  //     throw error;
  //   }
  // }

  // /**
  //  * 個別ユーザーの日次要約生成
  //  */
  // private async generateUserDailySummary(userId: number, targetDate: Date) {
  //   const startOfDay = new Date(targetDate);
  //   startOfDay.setHours(0, 0, 0, 0);

  //   const endOfDay = new Date(targetDate);
  //   endOfDay.setHours(23, 59, 59, 999);

  //   const articles = await this._prisma.savedArticle.findMany({
  //     where: {
  //       userId,
  //       createdAt: {
  //         gte: startOfDay,
  //         lte: endOfDay,
  //       },
  //       savedArticleSummary: {
  //         isNot: null,
  //       },
  //     },
  //     include: {
  //       savedArticleSummary: true,
  //     },
  //     orderBy: {
  //       createdAt: 'asc',
  //     },
  //   });

  //   if (articles.length === 0) {
  //     return null;
  //   }

  //   // 記事要約を結合して日次要約を作成
  //   const combinedSummary = this.createCombinedSummary(articles);

  //   const dailySummary = await this._prisma.userDailySummary.create({
  //     data: {
  //       userId,
  //       summary: combinedSummary,
  //       generatedDate: targetDate,
  //     },
  //   });

  //   return dailySummary;
  // }

  // /**
  //  * 複数記事の要約を結合
  //  */
  // private createCombinedSummary(articles: any[]): string {
  //   const header = `本日の記事要約（${articles.length}件）\n\n`;

  //   const summaries = articles.map((article, index) => {
  //     return `${index + 1}. 【${article.title}】\n${article.savedArticleSummary?.summary}\n`;
  //   }).join('\n');

  //   return header + summaries;
  // }
}
