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
  market-research implementation ci-setup seo-setup feedback-loop
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
# 全コマンドファイルを削除
for cmd_file in "$CMD_DIR"/*.md; do
  [ -f "$cmd_file" ] && rm -f "$cmd_file"
done
echo "  ✅ コマンドファイル削除完了"

# CLAUDE.md の注記削除
CLAUDE_MD="$INSTALL_DIR/CLAUDE.md"
if [ -f "$CLAUDE_MD" ] && grep -q "claude-app-builder" "$CLAUDE_MD"; then
  # claude-app-builder セクションを削除
  # macOS/Linux 両対応
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' '/^---$/,/^---$/{ /claude-app-builder/{ N; N; N; N; d; }; }' "$CLAUDE_MD" 2>/dev/null || true
  else
    sed -i '/^---$/,/^---$/{ /claude-app-builder/{ N; N; N; N; d; }; }' "$CLAUDE_MD" 2>/dev/null || true
  fi
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
