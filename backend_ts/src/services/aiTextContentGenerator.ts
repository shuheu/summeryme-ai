import { setTimeout } from 'timers';

import { GoogleGenAI } from '@google/genai';

/**
 * AI テキストコンテンツ生成サービス
 * Google Gemini AI を使用してテキストコンテンツを生成する
 */
export class AiTextContentGenerator {
  /** モックモードかどうか */
  private readonly isMockMode: boolean;

  /**
   * AiTextContentGenerator のコンストラクタ
   */
  constructor() {
    this.isMockMode = process.env.USE_MOCK_SUMMARY_AI === 'true';
  }

  /**
   * プロンプトに基づいてテキストコンテンツを生成する
   * @param {string} prompt - AI に渡すプロンプト文字列
   * @returns {Promise<string>} 生成されたテキストコンテンツ
   * @throws {Error} API キーが設定されていない場合や API 呼び出しが失敗した場合
   */
  async generate(prompt: string): Promise<string | undefined> {
    // モックモードの場合はダミーテキストを返す
    if (this.isMockMode) {
      return this.generateMockContent(prompt);
    }

    const ai = new GoogleGenAI({
      apiKey: process.env.GEMINI_API_KEY,
    });
    const tools = [{ urlContext: {} }];
    const config = {
      responseMimeType: 'text/plain',
      tools,
    };
    const model = 'gemini-2.5-pro';
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

  /**
   * 開発用のモックコンテンツを生成する
   * プロンプトの内容に応じて適切なダミーテキストを返す
   * @param {string} prompt - AI に渡すプロンプト文字列
   * @returns {Promise<string>} モックコンテンツ
   * @private
   */
  private async generateMockContent(prompt: string): Promise<string> {
    console.log('🤖 AI生成モックモード: ダミーコンテンツを生成します');

    // 少し遅延を追加して実際の処理時間をシミュレート
    await new Promise((resolve) => setTimeout(resolve, 1000));

    // プロンプトの内容に応じてダミーテキストを生成
    if (prompt.includes('記事の要約') || prompt.includes('要約して')) {
      return this.generateMockArticleSummary();
    }

    if (prompt.includes('トークスクリプト') || prompt.includes('会話形式')) {
      return this.generateMockTalkScript();
    }

    if (prompt.includes('日次要約') || prompt.includes('今日の記事')) {
      return this.generateMockDailySummary();
    }

    // デフォルトのモックコンテンツ
    return `🤖 [モックコンテンツ]
プロンプト: ${prompt.substring(0, 100)}...

これはAI生成のモックテキストです。実際の処理では、Google Gemini AIが適切なコンテンツを生成します。`;
  }

  /**
   * 記事要約のモックコンテンツを生成
   * @returns {string} モック記事要約
   * @private
   */
  private generateMockArticleSummary(): string {
    const mockSummaries = [
      '🤖 [モック記事要約] この記事では、最新の技術トレンドについて詳しく解説されています。主要なポイントとして、新しいフレームワークの導入、パフォーマンス向上の手法、そして将来の展望が挙げられています。',
      '🤖 [モック記事要約] 今回の記事は、ビジネス戦略に関する興味深い洞察を提供しています。市場分析、競合他社の動向、そして成功事例を通じて、実践的なアプローチが紹介されています。',
      '🤖 [モック記事要約] この記事では、健康とライフスタイルに関する重要な情報が共有されています。科学的根拠に基づいた提案と、日常生活に取り入れやすい実践的なアドバイスが含まれています。',
    ];

    return mockSummaries[Math.floor(Math.random() * mockSummaries.length)];
  }

  /**
   * トークスクリプトのモックコンテンツを生成
   * @returns {string} モックトークスクリプト
   * @private
   */
  private generateMockTalkScript(): string {
    return `Speaker 1: We're seeing a noticeable shift in consumer preferences across several sectors. What seems to be driving this change?
Speaker 2: It appears to be a combination of factors, including greater awareness of sustainability issues and a growing demand for personalized experiences.`;
  }

  /**
   * 日次要約のモックコンテンツを生成
   * @returns {string} モック日次要約
   * @private
   */
  private generateMockDailySummary(): string {
    const today = new Date().toLocaleDateString('ja-JP');

    return `🤖 [モック日次要約] ${today}

今日の注目記事まとめ

## 主要なトピック
- 技術革新と開発ツールの進化
- ビジネス戦略とデジタル変革
- 健康とライフスタイルの新知見

## ポイント
1. 新しい技術フレームワークが開発効率を大幅に向上
2. 市場の変化に対応した戦略的アプローチが重要
3. 科学的根拠に基づいた健康管理の重要性

## まとめ
今日の記事から、変化の激しい現代において、最新情報のキャッチアップと適応力の重要性が浮き彫りになりました。継続的な学習と柔軟な思考が成功の鍵となります。

明日もお楽しみに！`;
  }
}
