import { writeFile } from 'fs';
import { mkdir } from 'fs/promises';
import { join } from 'path';

import { GoogleGenAI } from '@google/genai';
import mime from 'mime';

/**
 * WAV 形式への変換オプション
 */
interface WavConversionOptions {
  /** チャンネル数 */
  numChannels: number;
  /** サンプリングレート (Hz) */
  sampleRate: number;
  /** ビット深度 */
  bitsPerSample: number;
}

/**
 * テキスト読み上げ音声生成サービス
 * Google Gemini AI を使用してテキストを音声に変換する
 */
export class TextToSpeechGenerator {
  /** 音声ファイルの保存先ディレクトリ */
  private readonly outputDir: string;

  /**
   * TextToSpeechGenerator のコンストラクタ
   * @param {string} outputDir - 音声ファイルの保存先ディレクトリ（デフォルト: 'output/audio'）
   */
  constructor(outputDir: string = 'output/audio') {
    this.outputDir = outputDir;
  }

  /**
   * テキスト読み上げ音声を生成する
   * 現在の実装では音声ファイルはローカルファイルシステムに保存される
   * @param {string} talkScript - 読み上げるテキストスクリプト
   * @param {string | number} id - ファイル名に含めるID
   * @returns {Promise<string[]>} 生成された音声ファイルのパス一覧
   * @throws {Error} API キーが設定されていない場合や API 呼び出しが失敗した場合
   */
  async generate(talkScript: string, id: string | number): Promise<string[]> {
    // 出力ディレクトリを事前に作成
    await this.ensureOutputDirectory();

    const ai = new GoogleGenAI({
      apiKey: process.env.GEMINI_API_KEY,
    });
    const config = {
      temperature: 1,
      responseModalities: ['audio'],
      speechConfig: {
        multiSpeakerVoiceConfig: {
          speakerVoiceConfigs: [
            {
              speaker: 'Speaker1',
              voiceConfig: {
                prebuiltVoiceConfig: {
                  voiceName: 'Zephyr',
                },
              },
            },
            {
              speaker: 'Speaker2',
              voiceConfig: {
                prebuiltVoiceConfig: {
                  voiceName: 'Puck',
                },
              },
            },
          ],
        },
      },
    };
    const model = 'gemini-2.5-flash-preview-tts';
    const contents = [
      {
        role: 'user',
        parts: [
          {
            text: `
            Read aloud in a warm, welcoming tone
            ${talkScript}
          `,
          },
        ],
      },
    ];

    const response = await ai.models.generateContentStream({
      model,
      config,
      contents,
    });

    let fileIndex = 0;
    const generatedFiles: string[] = [];

    for await (const chunk of response) {
      if (
        !chunk.candidates ||
        !chunk.candidates[0].content ||
        !chunk.candidates[0].content.parts
      ) {
        continue;
      }
      if (chunk.candidates?.[0]?.content?.parts?.[0]?.inlineData) {
        const fileName = `tts-${id}_${fileIndex++}`;
        const inlineData = chunk.candidates[0].content.parts[0].inlineData;
        let fileExtension = mime.getExtension(inlineData.mimeType || '');
        let buffer = Buffer.from(inlineData.data || '', 'base64');
        if (!fileExtension) {
          fileExtension = 'wav';
          buffer = this.convertToWav(
            inlineData.data || '',
            inlineData.mimeType || '',
          );
        }
        const fullFileName = `${fileName}.${fileExtension}`;
        await this.saveBinaryFile(fullFileName, buffer);
        generatedFiles.push(join(this.outputDir, fullFileName));
      } else {
        console.log(chunk.text);
      }
    }

    return generatedFiles;
  }

  /**
   * 出力ディレクトリが存在することを確認し、存在しない場合は作成する
   * @private
   */
  private async ensureOutputDirectory(): Promise<void> {
    try {
      await mkdir(this.outputDir, { recursive: true });
    } catch (error) {
      console.error(
        `出力ディレクトリの作成に失敗しました: ${this.outputDir}`,
        error,
      );
      throw error;
    }
  }

  /**
   * バイナリファイルをローカルファイルシステムに保存する
   * @param {string} fileName - 保存するファイル名
   * @param {Buffer} content - 保存するバイナリデータ
   * @private
   */
  private async saveBinaryFile(
    fileName: string,
    content: Buffer,
  ): Promise<void> {
    const filePath = join(this.outputDir, fileName);

    return new Promise((resolve, reject) => {
      writeFile(filePath, content, (err) => {
        if (err) {
          console.error(`ファイル保存エラー ${filePath}:`, err);
          reject(err);
          return;
        }
        console.log(`音声ファイルが保存されました: ${filePath}`);
        resolve();
      });
    });
  }

  /**
   * 生の音声データを WAV 形式に変換する
   * @param {string} rawData - Base64 エンコードされた生の音声データ
   * @param {string} mimeType - 元の音声データの MIME タイプ
   * @returns {Buffer} WAV 形式に変換されたバイナリデータ
   * @private
   */
  private convertToWav(rawData: string, mimeType: string) {
    const options = this.parseMimeType(mimeType);
    const wavHeader = this.createWavHeader(rawData.length, options);
    const buffer = Buffer.from(rawData, 'base64');

    return Buffer.concat([wavHeader, buffer]);
  }

  /**
   * MIME タイプから WAV 変換オプションを解析する
   * @param {string} mimeType - 解析する MIME タイプ
   * @returns {WavConversionOptions} WAV 変換オプション
   * @private
   */
  private parseMimeType(mimeType: string): WavConversionOptions {
    const [fileType, ...params] = mimeType.split(';').map((s) => s.trim());
    const [_, format] = fileType.split('/');

    const options: Partial<WavConversionOptions> = {
      numChannels: 1,
    };

    if (format && format.startsWith('L')) {
      const bits = parseInt(format.slice(1), 10);
      if (!isNaN(bits)) {
        options.bitsPerSample = bits;
      }
    }

    for (const param of params) {
      const [key, value] = param.split('=').map((s) => s.trim());
      if (key === 'rate') {
        options.sampleRate = parseInt(value, 10);
      }
    }

    return options as WavConversionOptions;
  }

  /**
   * WAV ファイルのヘッダーを作成する
   * @param {number} dataLength - 音声データの長さ（バイト）
   * @param {WavConversionOptions} options - WAV 変換オプション
   * @returns {Buffer} WAV ヘッダーのバイナリデータ
   * @private
   */
  private createWavHeader(
    dataLength: number,
    options: WavConversionOptions,
  ): Buffer {
    const { numChannels, sampleRate, bitsPerSample } = options;

    // http://soundfile.sapp.org/doc/WaveFormat

    const byteRate = (sampleRate * numChannels * bitsPerSample) / 8;
    const blockAlign = (numChannels * bitsPerSample) / 8;
    const buffer = Buffer.alloc(44);

    buffer.write('RIFF', 0); // ChunkID
    buffer.writeUInt32LE(36 + dataLength, 4); // ChunkSize
    buffer.write('WAVE', 8); // Format
    buffer.write('fmt ', 12); // Subchunk1ID
    buffer.writeUInt32LE(16, 16); // Subchunk1Size (PCM)
    buffer.writeUInt16LE(1, 20); // AudioFormat (1 = PCM)
    buffer.writeUInt16LE(numChannels, 22); // NumChannels
    buffer.writeUInt32LE(sampleRate, 24); // SampleRate
    buffer.writeUInt32LE(byteRate, 28); // ByteRate
    buffer.writeUInt16LE(blockAlign, 32); // BlockAlign
    buffer.writeUInt16LE(bitsPerSample, 34); // BitsPerSample
    buffer.write('data', 36); // Subchunk2ID
    buffer.writeUInt32LE(dataLength, 40); // Subchunk2Size

    return buffer;
  }
}
