#!/bin/bash
# Claude App Builder v3.1 - アンインストールスクリプト

set -euo pipefail
shopt -s nullglob

INSTALL_DIR="$HOME/.claude"
SKILL_DIR="$INSTALL_DIR/skills"
CMD_DIR="$INSTALL_DIR/commands"
LOCAL_DIR="$HOME/.claude-app-builder"
MANIFEST_DIR="$INSTALL_DIR/.claude-app-builder"
SKILL_MANIFEST="$MANIFEST_DIR/skills.txt"
CMD_MANIFEST="$MANIFEST_DIR/commands.txt"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR=""

if [ -d "$SCRIPT_DIR/skills" ] && [ -d "$SCRIPT_DIR/commands" ]; then
  SOURCE_DIR="$SCRIPT_DIR"
elif [ -d "$LOCAL_DIR/skills" ] && [ -d "$LOCAL_DIR/commands" ]; then
  SOURCE_DIR="$LOCAL_DIR"
fi

echo "🗑️  Claude App Builder アンインストール開始"
echo ""

remove_skill_link() {
  local skill="$1"
  local link_path="$SKILL_DIR/$skill"
  [ -L "$link_path" ] || return 0

  local target
  target="$(readlink "$link_path" 2>/dev/null || true)"

  if [[ "$target" == *"/claude-app-builder/skills/"* ]] || { [ -n "$SOURCE_DIR" ] && [[ "$target" == "$SOURCE_DIR/skills/"* ]]; }; then
    rm -f "$link_path"
    echo "  ✅ $skill"
  fi
}

remove_command_file() {
  local command_name="$1"
  local cmd_path="$CMD_DIR/$command_name.md"
  if [ -f "$cmd_path" ]; then
    rm -f "$cmd_path"
    echo "  ✅ /$command_name"
  fi
}

# スキル削除
echo "📦 スキルを削除中..."
if [ -f "$SKILL_MANIFEST" ]; then
  while IFS= read -r skill; do
    [ -n "$skill" ] || continue
    remove_skill_link "$skill"
  done < "$SKILL_MANIFEST"
elif [ -n "$SOURCE_DIR" ]; then
  for skill_dir in "$SOURCE_DIR/skills"/*; do
    [ -d "$skill_dir" ] || continue
    [ -f "$skill_dir/SKILL.md" ] || continue
    remove_skill_link "$(basename "$skill_dir")"
  done
fi

# 念のため、claude-app-builder 由来のシンボリックリンクを追加で掃除
for link_path in "$SKILL_DIR"/*; do
  [ -L "$link_path" ] || continue
  target="$(readlink "$link_path" 2>/dev/null || true)"
  if [[ "$target" == *"/claude-app-builder/skills/"* ]]; then
    rm -f "$link_path"
    echo "  ✅ $(basename "$link_path")"
  fi
done

# コマンド削除
echo ""
echo "⚡ コマンドを削除中..."
if [ -f "$CMD_MANIFEST" ]; then
  while IFS= read -r command_name; do
    [ -n "$command_name" ] || continue
    remove_command_file "$command_name"
  done < "$CMD_MANIFEST"
elif [ -n "$SOURCE_DIR" ]; then
  for cmd_file in "$SOURCE_DIR/commands"/*.md; do
    [ -f "$cmd_file" ] || continue
    cmd_name="$(basename "$cmd_file")"
    [ "$cmd_name" = "CLAUDE.md" ] && continue
    remove_command_file "${cmd_name%.md}"
  done
else
  echo "  ⚠️  参照元が見つからないため、コマンドは削除しません"
fi

# マニフェスト削除
if [ -d "$MANIFEST_DIR" ]; then
  rm -f "$SKILL_MANIFEST" "$CMD_MANIFEST"
  rmdir "$MANIFEST_DIR" 2>/dev/null || true
fi

# CLAUDE.md の注記削除
CLAUDE_MD="$INSTALL_DIR/CLAUDE.md"
if [ -f "$CLAUDE_MD" ] && grep -q "claude-app-builder" "$CLAUDE_MD"; then
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' '/# BEGIN claude-app-builder Plugin/,/# END claude-app-builder Plugin/d' "$CLAUDE_MD" 2>/dev/null || true
    # 旧バージョン向け互換削除
    sed -i '' '/# claude-app-builder Plugin/,+3d' "$CLAUDE_MD" 2>/dev/null || true
  else
    sed -i '/# BEGIN claude-app-builder Plugin/,/# END claude-app-builder Plugin/d' "$CLAUDE_MD" 2>/dev/null || true
    # 旧バージョン向け互換削除
    sed -i '/# claude-app-builder Plugin/,+3d' "$CLAUDE_MD" 2>/dev/null || true
  fi
  echo ""
  echo "📝 ~/.claude/CLAUDE.md を更新しました"
fi

# ローカルリポジトリ削除（確認あり）
if [ -d "$LOCAL_DIR" ]; then
  echo ""
  read -r -p "ローカルリポジトリ ($LOCAL_DIR) も削除しますか？ [y/N]: " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    rm -rf "$LOCAL_DIR"
    echo "  ✅ $LOCAL_DIR を削除"
  fi
fi

echo ""
echo "✅ アンインストール完了"
