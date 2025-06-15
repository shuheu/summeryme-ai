import { Storage } from '@google-cloud/storage';

/**
 * 音声ファイルのURL情報
 */
interface AudioFileInfo {
  /** ファイル名 */
  fileName: string;
  /** 署名付きURL */
  signedUrl: string;
  /** ファイルサイズ（バイト） */
  size: number;
  /** ファイルの最終更新日時 */
  lastModified: Date;
  /** ファイルの存在確認 */
  exists: boolean;
}

/**
 * 音声URL管理サービス
 * Google Cloud Storageの音声ファイルに対する署名付きURLを生成・管理する
 */
export class AudioUrlService {
  /** GCS クライアント */
  private readonly gcsClient: Storage;
  /** 音声ファイルアップロード先のバケット名 */
  private readonly bucketName: string;
  /** 署名付きURLの有効期限（デフォルト: 1時間） */
  private readonly urlExpirationMinutes: number;

  /**
   * AudioUrlService のコンストラクタ
   * @param {number} urlExpirationMinutes - 署名付きURLの有効期限（分）
   */
  constructor(urlExpirationMinutes: number = 60) {
    this.gcsClient = new Storage();
    this.bucketName = process.env.GCS_AUDIO_BUCKET || '';
    this.urlExpirationMinutes = urlExpirationMinutes;

    if (!this.bucketName) {
      throw new Error('GCS_AUDIO_BUCKET環境変数が設定されていません');
    }
  }

  /**
   * ユーザーのデイリーサマリーに関連する音声ファイルのURLを取得
   * @param {string | number} userId - ユーザーID
   * @param {string | number} dailySummaryId - デイリーサマリーID
   * @returns {Promise<AudioFileInfo[]>} 音声ファイル情報の配列
   */
  async getAudioUrlsForDailySummary(
    userId: string | number,
    dailySummaryId: string | number,
  ): Promise<AudioFileInfo[]> {
    try {
      const bucket = this.gcsClient.bucket(this.bucketName);
      const prefix = `audio/${String(userId)}/tts-${String(dailySummaryId)}_`;

      // 指定されたプレフィックスに一致するファイルを検索
      const [files] = await bucket.getFiles({
        prefix: prefix,
      });

      const audioFiles: AudioFileInfo[] = [];

      for (const file of files) {
        const [metadata] = await file.getMetadata();
        const [exists] = await file.exists();

        if (exists) {
          // 署名付きURLを生成
          const [signedUrl] = await file.getSignedUrl({
            action: 'read',
            expires: Date.now() + this.urlExpirationMinutes * 60 * 1000,
            responseType: 'audio/wav',
          });

          audioFiles.push({
            fileName: file.name,
            signedUrl: signedUrl,
            size: parseInt(String(metadata.size || '0'), 10),
            lastModified: new Date(metadata.timeCreated || Date.now()),
            exists: true,
          });
        }
      }

      // ファイル名でソート（順序を保証）
      audioFiles.sort((a, b) => a.fileName.localeCompare(b.fileName));

      console.log(
        `音声ファイル ${audioFiles.length} 件の署名付きURLを生成しました (userId: ${String(userId)}, dailySummaryId: ${String(dailySummaryId)})`,
      );

      return audioFiles;
    } catch (error) {
      console.error('音声URL取得エラー:', error);
      throw new Error(`音声ファイルのURL取得に失敗しました: ${error}`);
    }
  }

  /**
   * 特定の音声ファイルの署名付きURLを取得
   * @param {string} gcsUri - GCS URI (gs://bucket/path/to/file.wav形式)
   * @returns {Promise<AudioFileInfo | null>} 音声ファイル情報、存在しない場合はnull
   */
  async getSignedUrlForFile(gcsUri: string): Promise<AudioFileInfo | null> {
    try {
      // GCS URIからファイルパスを抽出
      const filePath = gcsUri.replace(`gs://${this.bucketName}/`, '');
      const bucket = this.gcsClient.bucket(this.bucketName);
      const file = bucket.file(filePath);

      const [exists] = await file.exists();
      if (!exists) {
        console.warn(`音声ファイルが存在しません: ${gcsUri}`);
        return null;
      }

      const [metadata] = await file.getMetadata();

      // 署名付きURLを生成
      const [signedUrl] = await file.getSignedUrl({
        action: 'read',
        expires: Date.now() + this.urlExpirationMinutes * 60 * 1000,
        responseType: 'audio/wav',
      });

      return {
        fileName: file.name,
        signedUrl: signedUrl,
        size: parseInt(String(metadata.size || '0'), 10),
        lastModified: new Date(metadata.timeCreated || Date.now()),
        exists: true,
      };
    } catch (error) {
      console.error(`音声ファイルURL取得エラー ${gcsUri}:`, error);
      return null;
    }
  }

  /**
   * 複数のGCS URIに対して署名付きURLを一括取得
   * @param {string[]} gcsUris - GCS URIの配列
   * @returns {Promise<AudioFileInfo[]>} 音声ファイル情報の配列（存在するファイルのみ）
   */
  async getSignedUrlsForFiles(gcsUris: string[]): Promise<AudioFileInfo[]> {
    const audioFiles: AudioFileInfo[] = [];

    for (const gcsUri of gcsUris) {
      const audioFile = await this.getSignedUrlForFile(gcsUri);
      if (audioFile) {
        audioFiles.push(audioFile);
      }
    }

    return audioFiles;
  }

  /**
   * 音声ファイルの存在確認
   * @param {string | number} userId - ユーザーID
   * @param {string | number} dailySummaryId - デイリーサマリーID
   * @returns {Promise<boolean>} 音声ファイルが存在するかどうか
   */
  async hasAudioFiles(
    userId: string | number,
    dailySummaryId: string | number,
  ): Promise<boolean> {
    try {
      const bucket = this.gcsClient.bucket(this.bucketName);
      const prefix = `audio/${String(userId)}/tts-${String(dailySummaryId)}_`;

      const [files] = await bucket.getFiles({
        prefix: prefix,
        maxResults: 1, // 存在確認なので1件でOK
      });

      return files.length > 0;
    } catch (error) {
      console.error('音声ファイル存在確認エラー:', error);
      return false;
    }
  }

  /**
   * ユーザーの音声ファイル一覧を取得
   * @param {string | number} userId - ユーザーID
   * @returns {Promise<AudioFileInfo[]>} ユーザーの全音声ファイル情報
   */
  async getUserAudioFiles(userId: string | number): Promise<AudioFileInfo[]> {
    try {
      const bucket = this.gcsClient.bucket(this.bucketName);
      const prefix = `audio/${String(userId)}/`;

      const [files] = await bucket.getFiles({
        prefix: prefix,
      });

      const audioFiles: AudioFileInfo[] = [];

      for (const file of files) {
        const [metadata] = await file.getMetadata();
        const [exists] = await file.exists();

        if (exists) {
          const [signedUrl] = await file.getSignedUrl({
            action: 'read',
            expires: Date.now() + this.urlExpirationMinutes * 60 * 1000,
            responseType: 'audio/wav',
          });

          audioFiles.push({
            fileName: file.name,
            signedUrl: signedUrl,
            size: parseInt(String(metadata.size || '0'), 10),
            lastModified: new Date(metadata.timeCreated || Date.now()),
            exists: true,
          });
        }
      }

      // 最新順でソート
      audioFiles.sort(
        (a, b) => b.lastModified.getTime() - a.lastModified.getTime(),
      );

      return audioFiles;
    } catch (error) {
      console.error('ユーザー音声ファイル取得エラー:', error);
      throw new Error(`ユーザーの音声ファイル取得に失敗しました: ${error}`);
    }
  }

  /**
   * 音声ファイルを削除
   * @param {string} gcsUri - 削除するファイルのGCS URI
   * @returns {Promise<boolean>} 削除が成功したかどうか
   */
  async deleteAudioFile(gcsUri: string): Promise<boolean> {
    try {
      const filePath = gcsUri.replace(`gs://${this.bucketName}/`, '');
      const bucket = this.gcsClient.bucket(this.bucketName);
      const file = bucket.file(filePath);

      const [exists] = await file.exists();
      if (!exists) {
        console.warn(`削除対象のファイルが存在しません: ${gcsUri}`);
        return false;
      }

      await file.delete();
      console.log(`音声ファイルを削除しました: ${gcsUri}`);
      return true;
    } catch (error) {
      console.error(`音声ファイル削除エラー ${gcsUri}:`, error);
      return false;
    }
  }

  /**
   * 署名付きURLの有効期限を取得
   * @returns {number} 有効期限（分）
   */
  getUrlExpirationMinutes(): number {
    return this.urlExpirationMinutes;
  }
}
