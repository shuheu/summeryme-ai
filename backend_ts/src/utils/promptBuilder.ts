export function buildArticleSummaryPrompt(url: string): {
  systemInstruction: string;
  prompt: string;
} {
  const systemInstruction = `あなたは要約のエキスパートであり、URLから記事の簡潔な要約を作成できます。要約は正確で、記事の要点を捉えており、指定されたルール、長さと言語の制約を遵守しています。`;
  const prompt = `以下のURLにある記事を要約してください。

${url}

- 要約にあたっては、以下のルールに従ってください。
- URLにアクセスできない場合、またはURLの記事を読み取れない場合は、その旨を明確に伝えてください。その場合、要約は実行しないでください。
- 要約は必ず日本語で記述してください。使用する言語は、フォーマルでプロフェッショナルなものとします。
- 要約は必ず800文字以内としてください。
- 回答は必ず要約のみを含めてください。導入や結論の記述は不要です。
- 要約は、提供されたURLにあるメインの記事の内容に焦点を当ててください。記事が他の記事を参照している場合、要約は主にメインの記事の内容を扱い、参照されている記事の内容は扱いません。
- 要約する前に、URLの内容が正確に読み取られ、理解されていることを確認してください。
- 要約は、記事の3つのキーポイントから始めてください。キーポイントの後、記事の内容の要約を提供してください。

出力形式
キーポイント:
<3つの重要なキーポイント>

要約:
<記事の要約>`;
  return {
    systemInstruction,
    prompt,
  };
}

export function buildSummarizedTalkScriptPrompt(urls: string[]): {
  systemInstruction: string;
  prompt: string;
} {
  const systemInstruction = `あなたはトークスクリプトのエキスパートであり、複数のURLから記事を要約し、それらの要約内容を元にして、2人の人物が対話する形式のトークスクリプトを生成できます。`;
  const prompt = `以下の複数のURLの記事をそれぞれ要約し、それらの要約内容を元にして、2人の人物が対話する形式のトークスクリプトを生成してください。
各URL:
${urls.join('\n')}
トークスクリプトのルール:
- Speaker1とSpeaker2の2人が会話する形式にしてください。
- 各セリフの前に「Speaker1: 」または「Speaker2: 」を必ず入れてください。
- 要約内容は全ての記事を網羅するようにしてください。
- 台本は日本語で記述してください。
- レスポンスには生成された台本のみを返してください。`;

  return {
    systemInstruction,
    prompt,
  };
}

export function buildUserDailySummaryPrompt(urls: string[]): {
  systemInstruction: string;
  prompt: string;
} {
  const systemInstruction = `あなたは日次要約のエキスパートであり、複数のURLから記事を分析し、ユーザー向けの日次要約を生成できます。`;
  const prompt = `以下の複数のURLから記事を分析し、ユーザー向けの日次要約を生成してください。
各URL:
${urls.join('\n')}
日次要約のルール:
- 各記事の重要なポイントを簡潔にまとめてください。
- 関連性のある記事がある場合は、それらの共通点や違いを指摘してください。
- 要約は日本語で記述してください。
- 要約全体で800文字以内にまとめてください。
- 情報量が多い場合は、最も重要な内容を優先してください。
- レスポンスには要約のみを返してください。`;

  return {
    systemInstruction,
    prompt,
  };
}
