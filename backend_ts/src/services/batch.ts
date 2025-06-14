import {
  buildArticleSummaryPrompt,
  buildSummarizedTalkScriptPrompt,
} from '@/utils/promptBuilder.js';

import { globalPrisma } from '../lib/dbClient.js';

import { AiTextContentGenerator } from './aiTextContentGenerator.js';
import { TextToSpeechGenerator } from './textToSpeechGenerator.js';

/**
 * バッチ処理メイン関数
 */
export async function batchProcess() {
  console.log('Batch process started');

  try {
    // 特定のユーザーID（実際の実装では引数で受け取るか、環境変数から取得）
    const userId = 1;
    // TODO: 条件絞る。
    // TODO: リアルユーザー取得

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

      const aiTextContentGenerator = new AiTextContentGenerator();

      articles.forEach(async (article) => {
        // FIXME: N+1 api, db
        const prompt = buildArticleSummaryPrompt(article.url);
        console.log('🚀 ~ batchProcess ~ prompt:', prompt);
        // const aiGeneratedSummaryText =
        //   await aiTextContentGenerator.generate(prompt);

        const aiGeneratedSummaryText = 'test';
        console.log(
          '🚀 ~ batchProcess ~ aiGeneratedText:',
          aiGeneratedSummaryText,
        );

        if (!aiGeneratedSummaryText) {
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
      });

      const prompt = buildSummarizedTalkScriptPrompt(
        articles.map((article) => article.url),
      );
      console.log('🚀 ~ batchProcess ~ prompt:', prompt);

      const aiGeneratedTalkScript =
        await aiTextContentGenerator.generate(prompt);
      console.log(
        '🚀 ~ batchProcess ~ aiGeneratedText:',
        aiGeneratedTalkScript,
      );
      if (!aiGeneratedTalkScript) {
        return;
      }

      const textToSpeechGenerator = new TextToSpeechGenerator();
      const codeFileName = `user-${userId}_${articles
        .map((article) => article.id)
        .join('-')}`;
      await textToSpeechGenerator.generate(aiGeneratedTalkScript, codeFileName);
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
