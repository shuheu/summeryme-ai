# TypeSpec 導入ガイド

このプロジェクトでは TypeSpec を使用して API 定義を管理しています。

## セットアップ完了内容

1. **TypeSpec パッケージのインストール**

   - `@typespec/compiler`
   - `@typespec/http`
   - `@typespec/rest`
   - `@typespec/openapi3`
   - `openapi-typescript`

2. **ファイル構成**
   ```
   backend_ts/
   ├── src/
   │   ├── typespec/
   │   │   ├── main.tsp         # TypeSpec定義ファイル
   │   │   └── package.json
   │   ├── types/
   │   │   └── api.generated.ts # 生成された型定義
   │   └── apis/
   │       ├── savedArticle.ts          # 既存の実装
   │       └── savedArticle.typespec.ts # TypeSpec型を使用した実装例
   ├── tspconfig.json           # TypeSpec設定
   └── tsp-output/              # 生成されたOpenAPIファイル
   ```

## 使用方法

### 1. API定義の更新

`src/typespec/main.tsp` ファイルを編集して API 定義を更新します。

### 2. 型定義の生成

```bash
# TypeSpecからOpenAPIとTypeScript型を生成
docker compose exec backend pnpm generate:types

# または個別に実行
docker compose exec backend pnpm typespec                    # OpenAPI生成のみ
npx openapi-typescript ./tsp-output/@typespec/openapi3/openapi.yaml -o ./src/types/api.generated.ts
```

### 3. 生成された型の使用

```typescript
import type { components } from '../types/api.generated.js';

// スキーマ型の使用
type SavedArticle = components['schemas']['SavedArticle'];
type ErrorResponse = components['schemas']['ErrorResponse'];
```

## 利点

1. **単一の真実の源泉**: TypeSpec で API を定義し、OpenAPI と TypeScript 型を自動生成
2. **型安全性**: フロントエンドとバックエンドで同じ型定義を共有可能
3. **ドキュメント生成**: OpenAPI 仕様から API ドキュメントを自動生成可能
4. **バリデーション**: TypeSpec のバリデーション機能で API 定義の整合性を保証

## 既存コードとの統合

既存の Zod バリデーションと TypeSpec 生成型を組み合わせて使用できます：

1. **リクエストバリデーション**: Zod スキーマを使用（実行時バリデーション）
2. **レスポンス型**: TypeSpec 生成型を使用（型安全性）

`src/apis/savedArticle.typespec.ts` に実装例があります。

## 今後の拡張

1. **認証の追加**: TypeSpec で認証スキームを定義
2. **エラーハンドリング**: 共通エラー型の定義と使用
3. **クライアントSDK生成**: TypeSpec から各言語のクライアントコードを生成
