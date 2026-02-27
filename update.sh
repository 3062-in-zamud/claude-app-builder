#!/bin/bash
# Claude App Builder - 更新スクリプト

set -e

LOCAL_DIR="$HOME/.claude-app-builder"
INSTALL_DIR="$HOME/.claude"
SKILL_DIR="$INSTALL_DIR/skills"
CMD_DIR="$INSTALL_DIR/commands"

echo "🔄 Claude App Builder 更新開始"
echo ""

if [ ! -d "$LOCAL_DIR" ]; then
  echo "❌ インストールが見つかりません: $LOCAL_DIR"
  echo "   先に install.sh を実行してください"
  exit 1
fi

# リポジトリ更新
echo "📥 最新版を取得中..."
git -C "$LOCAL_DIR" pull

# スキル再リンク
echo ""
echo "📦 スキルを更新中..."
mkdir -p "$SKILL_DIR"
for skill_dir in "$LOCAL_DIR/skills"/*/; do
  skill_name=$(basename "$skill_dir")
  ln -sfn "$skill_dir" "$SKILL_DIR/$skill_name"
  echo "  ✅ $skill_name"
done

# コマンド更新
echo ""
echo "⚡ コマンドを更新中..."
for cmd_file in "$LOCAL_DIR/commands/"*.md; do
  cmd_name=$(basename "$cmd_file")
  cp "$cmd_file" "$CMD_DIR/$cmd_name"
  echo "  ✅ /${cmd_name%.md} コマンド"
done

echo ""
echo "✅ 更新完了！"
