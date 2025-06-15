#!/bin/bash

# Flutter Web デプロイスクリプト for Firebase Hosting
# 使用方法: ./scripts/deploy.sh [staging|production] [site_id]

set -e

# カラー出力用
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 引数チェック
ENVIRONMENT=${1:-staging}
CUSTOM_SITE_ID=${2:-}

if [[ ! "$ENVIRONMENT" =~ ^(staging|production)$ ]]; then
  echo -e "${RED}Error: 無効な環境指定です。'staging' または 'production' を指定してください。${NC}"
  exit 1
fi

# ✅ Site ID の設定
if [ -n "$CUSTOM_SITE_ID" ]; then
  SITE_ID="$CUSTOM_SITE_ID"
  echo -e "${YELLOW}🏷️  カスタムSite ID: $SITE_ID${NC}"
else
  # デフォルトのSite ID設定
  case $ENVIRONMENT in
  production)
    SITE_ID="summaryme-ai"
    ;;
  staging)
    SITE_ID="summaryme-ai-staging"
    ;;
  esac
fi

echo -e "${BLUE}🚀 Flutter Web デプロイを開始します...${NC}"
echo -e "${YELLOW}📦 環境: $ENVIRONMENT${NC}"
echo -e "${YELLOW}🏷️  Site ID: $SITE_ID${NC}"

# 現在のディレクトリがfrontendディレクトリかチェック
if [ ! -f "pubspec.yaml" ]; then
  echo -e "${RED}Error: frontendディレクトリから実行してください${NC}"
  exit 1
fi

# Flutter依存関係の取得
echo -e "${BLUE}📦 Flutter依存関係を取得中...${NC}"
flutter pub get

# テストの実行
# echo -e "${BLUE}🧪 テストを実行中...${NC}"
# flutter test

# Webビルドの実行
echo -e "${BLUE}🔨 Flutter Webをビルド中...${NC}"
flutter build web \
  --release \
  --base-href / \
  --dart-define=API_BASE_URL=$API_BASE_URL \
  --dart-define=FLUTTER_WEB_USE_SKIA=false # false で HTML レンダラー使用, 軽量、テキスト中心のアプリに向いている
# --dart-define=FLUTTER_WEB_USE_SKIA=true --dart-define=FLUTTER_WEB_CANVASKIT_URL=/canvaskit/ \  # true で CanvasKit (Skia) レンダラー使用 高品質グラフィック、複雑なアニメーション

echo "📦 Flutter Web build completed"
echo "🔍 Build size: $(du -sh build/web/ | cut -f1)"

# Firebase CLIの確認
if ! command -v firebase &>/dev/null; then
  echo -e "${RED}Error: Firebase CLIがインストールされていません${NC}"
  echo -e "${YELLOW}以下のコマンドでインストールしてください:${NC}"
  echo "npm install -g firebase-tools"
  exit 1
fi

# Firebase プロジェクトの確認
echo -e "${BLUE}🔍 Firebase プロジェクトを確認中...${NC}"
firebase projects:list

# ✅ Site ID が存在するかチェック
echo -e "${BLUE}🔍 Site ID '$SITE_ID' の存在確認中...${NC}"
if firebase hosting:sites:list | grep -q "$SITE_ID"; then
  echo -e "${GREEN}✅ Site ID '$SITE_ID' が見つかりました${NC}"
else
  echo -e "${YELLOW}⚠️  Site ID '$SITE_ID' が見つかりません。作成しますか? (y/N)${NC}"
  read -r response
  if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "${BLUE}🔨 Site '$SITE_ID' を作成中...${NC}"
    firebase hosting:sites:create "$SITE_ID"
  else
    echo -e "${RED}デプロイをキャンセルしました${NC}"
    exit 1
  fi
fi

# デプロイの実行
if [ "$ENVIRONMENT" = "production" ]; then
  echo -e "${YELLOW}⚠️  本番環境 (Site: $SITE_ID) にデプロイします。続行しますか? (y/N)${NC}"
  read -r response
  if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "${YELLOW}デプロイをキャンセルしました${NC}"
    exit 0
  fi
fi

echo -e "${BLUE}🚀 '$SITE_ID' にデプロイ中...${NC}"

firebase target:apply hosting $ENVIRONMENT $SITE_ID
firebase deploy --only hosting:$ENVIRONMENT

echo -e "${GREEN}✅ デプロイが完了しました！${NC}"
echo -e "${GREEN}🌍 URL: https://$SITE_ID.web.app${NC}"

# デプロイ統計
echo -e "${BLUE}📊 デプロイ統計:${NC}"
echo "🏷️  Site ID: $SITE_ID"
echo "🔍 API_BASE_URL: $API_BASE_URL"
echo "🌍 URL: https://$SITE_ID.web.app"
echo "📦 Environment: $ENVIRONMENT"

echo -e "${BLUE}📊 Firebase Hosting の統計情報:${NC}"
firebase hosting:sites:list
