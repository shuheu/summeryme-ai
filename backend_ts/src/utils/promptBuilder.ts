export function buildArticleSummaryPrompt(url: string): string {
  return `以下のURLの記事を要約してください:
  ${url}
  要約のルール:
  - 要約は日本語で行ってください。
  - 要約は500文字以内で行ってください。
  - レスポンスには要約のみを返してください。`;
}

export function buildSummarizedTalkScriptPrompt(urls: string[]): string {
  return `以下の複数のURLの記事をそれぞれ要約し、それらの要約内容を元にして、2人の人物が対話する形式のトークスクリプトを生成してください。
各URL:
${urls.join('\n')}
トークスクリプトのルール:
- Speaker1とSpeaker2の2人が会話する形式にしてください。
- 各セリフの前に「Speaker1: 」または「Speaker2: 」を必ず入れてください。
- 要約内容は全ての記事を網羅するようにしてください。
- 台本は日本語で記述してください。
- レスポンスには生成された台本のみを返してください。`;
}

export function buildUserDailySummaryPrompt(urls: string[]): string {
  return `以下の複数のURLから記事を分析し、ユーザー向けの日次要約を生成してください。
各URL:
${urls.join('\n')}
日次要約のルール:
- 各記事の重要なポイントを簡潔にまとめてください。
- 関連性のある記事がある場合は、それらの共通点や違いを指摘してください。
- 要約は日本語で記述してください。
- 要約全体で800文字以内にまとめてください。
- 情報量が多い場合は、最も重要な内容を優先してください。
- レスポンスには要約のみを返してください。`;
}
