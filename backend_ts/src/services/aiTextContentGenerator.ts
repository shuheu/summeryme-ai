import { GoogleGenAI } from '@google/genai';

/**
 * AI テキストコンテンツ生成サービス
 * Google Gemini AI を使用してテキストコンテンツを生成する
 */
export class AiTextContentGenerator {
  /**
   * AiTextContentGenerator のコンストラクタ
   */
  constructor() {}

  /**
   * プロンプトに基づいてテキストコンテンツを生成する
   * @param {string} prompt - AI に渡すプロンプト文字列
   * @returns {Promise<string>} 生成されたテキストコンテンツ
   * @throws {Error} API キーが設定されていない場合や API 呼び出しが失敗した場合
   */
  async generate(prompt: string): Promise<string | undefined> {
    const ai = new GoogleGenAI({
      apiKey: process.env.GEMINI_API_KEY,
    });
    const config = {
      responseMimeType: 'text/plain',
    };
    const model = 'gemini-2.5-pro-preview-05-06';
    const contents = [
      {
        role: 'user',
        parts: [
          {
            text: `
              ${prompt}
            `,
          },
        ],
      },
    ];
    const response = await ai.models.generateContent({
      model,
      config,
      contents,
    });
    return response.text;
  }
}
