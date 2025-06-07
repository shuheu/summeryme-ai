import { GoogleGenAI } from '@google/genai';

export class AiTextContentGenerator {
  constructor() {}

  async generate(prompt: string) {
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
