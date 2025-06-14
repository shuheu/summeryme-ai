import { writeFile } from 'fs';
import { mkdir } from 'fs/promises';
import { join } from 'path';
import { setTimeout } from 'timers';

import { GoogleGenAI } from '@google/genai';
import { Storage } from '@google-cloud/storage';
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
 * Google Gemini AI を使用してテキストを音声に変換し、Google Cloud Storage にアップロードする
 */
export class TextToSpeechGenerator {
  /** GCS クライアント */
  private readonly gcsClient: Storage;
  /** 音声ファイルアップロード先のバケット名 */
  private readonly bucketName: string;
  /** ローカルディレクトリ（一時保存用） */
  private readonly localOutputDir: string;
  /** モックモードかどうか */
  private readonly isMockMode: boolean;

  /**
   * TextToSpeechGenerator のコンストラクタ
   * @param {string} localOutputDir - 一時保存用ローカルディレクトリ（デフォルト: 'output/audio'）
   */
  constructor(localOutputDir: string = 'output/audio') {
    this.gcsClient = new Storage();
    this.bucketName = process.env.GCS_AUDIO_BUCKET || '';
    this.localOutputDir = localOutputDir;
    this.isMockMode = process.env.USE_MOCK_TTS === 'true';

    if (!this.bucketName && !this.isMockMode) {
      throw new Error('GCS_AUDIO_BUCKET環境変数が設定されていません');
    }
  }

  /**
   * テキスト読み上げ音声を生成し、GCSにアップロードする
   * @param {string} talkScript - 読み上げるテキストスクリプト
   * @param {string | number} id - ファイル名に含めるID
   * @param {string | number} userId - ユーザーID（フォルダ構成用）
   * @returns {Promise<string[]>} 生成された音声ファイルのGCS URI一覧
   * @throws {Error} API キーが設定されていない場合や API 呼び出しが失敗した場合
   */
  async generate(
    talkScript: string,
    id: string | number,
    userId: string | number,
  ): Promise<string[]> {
    // モックモードの場合はダミーファイルを返す
    if (this.isMockMode) {
      return this.generateMockAudioFiles(talkScript, id, userId);
    }

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
        const gcsPath = await this.uploadToGCS(fullFileName, buffer, userId);
        generatedFiles.push(gcsPath);
      } else {
        console.log(chunk.text);
      }
    }

    return generatedFiles;
  }

  /**
   * バイナリデータをGCSにアップロードする
   * @param {string} fileName - アップロードするファイル名
   * @param {Buffer} content - アップロードするバイナリデータ
   * @param {string | number} userId - ユーザーID（フォルダ構成用）
   * @returns {Promise<string>} アップロードされたファイルのGCS URI
   * @private
   */
  private async uploadToGCS(
    fileName: string,
    content: Buffer,
    userId: string | number,
  ): Promise<string> {
    try {
      const bucket = this.gcsClient.bucket(this.bucketName);
      const gcsFileName = `audio/${userId}/${fileName}`;
      const file = bucket.file(gcsFileName);

      // ファイルをGCSにアップロード
      await file.save(content, {
        metadata: {
          contentType: 'audio/wav',
          cacheControl: 'public, max-age=86400', // 1日キャッシュ
        },
        resumable: false, // 小さなファイルの場合は直接アップロード
      });

      const gcsUri = `gs://${this.bucketName}/${gcsFileName}`;
      console.log(`音声ファイルがGCSにアップロードされました: ${gcsUri}`);

      return gcsUri;
    } catch (error) {
      console.error(`GCSアップロードエラー ${fileName}:`, error);
      throw new Error(`GCSへのアップロードに失敗しました: ${fileName}`);
    }
  }

  /**
   * 開発用のモック音声ファイルを生成する
   * 実際のファイルは作成せず、ダミーのGCS URIを返す
   * @param {string} talkScript - 読み上げるテキストスクリプト
   * @param {string | number} id - ファイル名に含めるID
   * @param {string | number} userId - ユーザーID（フォルダ構成用）
   * @returns {Promise<string[]>} モック音声ファイルのGCS URI一覧
   * @private
   */
  private async generateMockAudioFiles(
    talkScript: string,
    id: string | number,
    userId: string | number,
  ): Promise<string[]> {
    console.log('🎭 モックモード: ダミー音声ファイルを生成します');
    console.log(`テキスト長: ${talkScript.length}文字`);

    // テキストの長さに基づいてダミーファイル数を決定（1000文字ごとに1ファイル）
    const estimatedFileCount = Math.max(1, Math.ceil(talkScript.length / 1000));
    const mockFiles: string[] = [];

    for (let i = 0; i < estimatedFileCount; i++) {
      const fileName = `tts-${id}_${i}.wav`;
      const mockGcsUri = `gs://mock-bucket/audio/${userId}/${fileName}`;
      mockFiles.push(mockGcsUri);

      console.log(`🎭 モック音声ファイル: ${mockGcsUri}`);
    }

    // 少し遅延を追加して実際の処理時間をシミュレート
    await new Promise((resolve) => setTimeout(resolve, 500));

    console.log(`🎭 モック音声生成完了: ${mockFiles.length}ファイル作成`);
    return mockFiles;
  }

  /**
   * バイナリファイルをローカルファイルシステムに保存する
   * 注意：この関数は後方互換性のため保持していますが、GCS使用時は使用されません
   * @param {string} fileName - 保存するファイル名
   * @param {Buffer} content - 保存するバイナリデータ
   * @private
   */
  private async saveBinaryFile(
    fileName: string,
    content: Buffer,
  ): Promise<void> {
    const filePath = join(this.localOutputDir, fileName);

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

  /**
   * ダミーのWAVファイルを作成してGCSにアップロードする（モック用）
   * @param {string} gcsUri - アップロード先のGCS URI
   * @private
   */
  private async createMockWavFile(gcsUri: string): Promise<void> {
    // モックモードでは実際のファイル作成は行わない
    console.log(`🎭 モックファイル作成: ${gcsUri}`);
  }
}
