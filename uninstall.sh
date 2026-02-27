#!/bin/bash
# Claude App Builder - アンインストールスクリプト

set -e

INSTALL_DIR="$HOME/.claude"
SKILL_DIR="$INSTALL_DIR/skills"
CMD_DIR="$INSTALL_DIR/commands"
LOCAL_DIR="$HOME/.claude-app-builder"

echo "🗑️  Claude App Builder アンインストール開始"
echo ""

# スキル削除
SKILLS=(
  app-builder idea-to-spec brand-foundation stack-selector
  visual-designer documentation-suite landing-page-builder
  legal-docs-generator project-scaffold github-repo-setup
  security-hardening monitoring-setup release-checklist deploy-setup
)

echo "📦 スキルを削除中..."
for skill in "${SKILLS[@]}"; do
  if [ -L "$SKILL_DIR/$skill" ]; then
    rm -f "$SKILL_DIR/$skill"
    echo "  ✅ $skill"
  fi
done

# コマンド削除
echo ""
echo "⚡ コマンドを削除中..."
rm -f "$CMD_DIR/app-builder.md"
echo "  ✅ /app-builder コマンド"

# CLAUDE.md の注記削除
CLAUDE_MD="$INSTALL_DIR/CLAUDE.md"
if [ -f "$CLAUDE_MD" ] && grep -q "claude-app-builder" "$CLAUDE_MD"; then
  # claude-app-builder セクションを削除
  sed -i '' '/^---$/,/^---$/{ /claude-app-builder/{ N; N; N; N; d; }; }' "$CLAUDE_MD" 2>/dev/null || true
  echo ""
  echo "📝 ~/.claude/CLAUDE.md を更新しました"
fi

# ローカルリポジトリ削除（確認あり）
if [ -d "$LOCAL_DIR" ]; then
  echo ""
  read -p "ローカルリポジトリ ($LOCAL_DIR) も削除しますか？ [y/N]: " confirm
  if [[ "$confirm" =~ ^[Yy]$ ]]; then
    rm -rf "$LOCAL_DIR"
    echo "  ✅ $LOCAL_DIR を削除"
  fi
fi

echo ""
echo "✅ アンインストール完了"
