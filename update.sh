#!/bin/bash
# Claude App Builder v0.1 - 更新スクリプト

set -euo pipefail
shopt -s nullglob

LOCAL_DIR="$HOME/.claude-app-builder"
INSTALL_DIR="$HOME/.claude"
SKILL_DIR="$INSTALL_DIR/skills"
CMD_DIR="$INSTALL_DIR/commands"
MANIFEST_DIR="$INSTALL_DIR/.claude-app-builder"
SKILL_MANIFEST="$MANIFEST_DIR/skills.txt"
CMD_MANIFEST="$MANIFEST_DIR/commands.txt"

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
mkdir -p "$SKILL_DIR" "$MANIFEST_DIR"
: > "$SKILL_MANIFEST"

for skill_dir in "$LOCAL_DIR/skills"/*; do
  [ -d "$skill_dir" ] || continue
  [ -f "$skill_dir/SKILL.md" ] || continue

  skill_name=$(basename "$skill_dir")
  ln -sfn "$skill_dir" "$SKILL_DIR/$skill_name"
  echo "$skill_name" >> "$SKILL_MANIFEST"
  echo "  ✅ $skill_name"
done
sort -u -o "$SKILL_MANIFEST" "$SKILL_MANIFEST"

# コマンド更新
echo ""
echo "⚡ コマンドを更新中..."
mkdir -p "$CMD_DIR"
: > "$CMD_MANIFEST"

for cmd_file in "$LOCAL_DIR/commands"/*.md; do
  [ -f "$cmd_file" ] || continue
  cmd_name=$(basename "$cmd_file")
  [ "$cmd_name" = "CLAUDE.md" ] && continue

  cp "$cmd_file" "$CMD_DIR/$cmd_name"
  echo "${cmd_name%.md}" >> "$CMD_MANIFEST"
  echo "  ✅ /${cmd_name%.md} コマンド"
done
sort -u -o "$CMD_MANIFEST" "$CMD_MANIFEST"

echo ""
echo "✅ Claude App Builder v0.1 更新完了！"
echo "   スキル数: $(wc -l < "$SKILL_MANIFEST" | tr -d ' ') 個"
echo "   コマンド数: $(wc -l < "$CMD_MANIFEST" | tr -d ' ') 個"
