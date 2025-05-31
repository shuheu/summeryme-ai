#!/bin/bash

echo "🔧 Flutterプロジェクトの自動修正を開始します..."

# 依存関係の取得
echo "📦 依存関係を取得中..."
flutter pub get

# コードフォーマット
echo "🎨 コードをフォーマット中..."
dart format .

# 自動修正の適用
echo "🔧 自動修正を適用中..."
dart fix --apply

# 静的解析
echo "🔍 静的解析を実行中..."
flutter analyze

echo "✅ 自動修正が完了しました！"
