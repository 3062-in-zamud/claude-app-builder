#!/bin/bash
# Claude App Builder - インストールスクリプト
# Usage: curl -fsSL https://raw.githubusercontent.com/3062-in-zamud/claude-app-builder/main/install.sh | bash
# または: bash install.sh

set -e

INSTALL_DIR="$HOME/.claude"
SKILL_DIR="$INSTALL_DIR/skills"
CMD_DIR="$INSTALL_DIR/commands"
LOCAL_DIR="$HOME/.claude-app-builder"
REPO_URL="https://github.com/3062-in-zamud/claude-app-builder"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Claude App Builder インストール開始"
echo ""

# ===== 1. 前提ツール確認 =====
check_tool() {
  if command -v "$1" >/dev/null 2>&1; then
    echo "  ✅ $1"
  else
    echo "  ⚠️  $1 が見つかりません → $2"
  fi
}

echo "📋 前提ツール確認:"
check_tool gh       "https://cli.github.com/"
check_tool vercel   "npm install -g vercel"
check_tool supabase "npm install -g supabase"
check_tool node     "https://nodejs.org/"
check_tool git      "https://git-scm.com/"
echo ""

# ===== 2. ソースの取得 =====
if [ -d "$SCRIPT_DIR/skills" ]; then
  # ローカルインストール（リポジトリからの直接実行）
  SOURCE_DIR="$SCRIPT_DIR"
  echo "📁 ローカルインストール: $SOURCE_DIR"
else
  # リモートインストール（クローン）
  echo "📥 リポジトリをクローン中..."
  if [ -d "$LOCAL_DIR" ]; then
    echo "   既存インストールを更新中..."
    git -C "$LOCAL_DIR" pull --quiet
  else
    git clone "$REPO_URL" "$LOCAL_DIR" --quiet
  fi
  SOURCE_DIR="$LOCAL_DIR"
  echo "   完了: $LOCAL_DIR"
fi
echo ""

# ===== 3. ~/.claude/skills/ にインストール =====
echo "📦 スキルをインストール中..."
mkdir -p "$SKILL_DIR"

for skill_dir in "$SOURCE_DIR/skills"/*/; do
  skill_name=$(basename "$skill_dir")
  ln -sfn "$skill_dir" "$SKILL_DIR/$skill_name"
  echo "  ✅ $skill_name"
done
echo ""

# ===== 4. ~/.claude/commands/ にコマンド追加 =====
echo "⚡ コマンドをインストール中..."
mkdir -p "$CMD_DIR"
cp "$SOURCE_DIR/commands/app-builder.md" "$CMD_DIR/app-builder.md"
echo "  ✅ /app-builder コマンド"
echo ""

# ===== 5. ~/.claude/CLAUDE.md に注記追加（重複チェック付き） =====
CLAUDE_MD="$INSTALL_DIR/CLAUDE.md"
if [ -f "$CLAUDE_MD" ] && ! grep -q "claude-app-builder" "$CLAUDE_MD" 2>/dev/null; then
  cat >> "$CLAUDE_MD" << 'EOF'

---
# claude-app-builder Plugin
# 0→MVPリリース自動化スキル。/app-builder で起動。
# 詳細: ~/.claude-app-builder/README.md または ~/.claude/skills/app-builder/SKILL.md
EOF
  echo "📝 ~/.claude/CLAUDE.md を更新しました"
fi

echo ""
echo "═══════════════════════════════════"
echo "✅ インストール完了！"
echo ""
echo "使い方:"
echo "  /app-builder \"あなたのアイデア\""
echo ""
echo "個別スキル:"
echo "  /idea-to-spec \"アイデア\"    - 要件定義のみ"
echo "  /brand-foundation           - ブランディングのみ"
echo "  /security-hardening         - セキュリティチェックのみ"
echo "  /deploy-setup               - デプロイのみ"
echo ""
echo "更新: bash ~/.claude-app-builder/update.sh"
echo "削除: bash ~/.claude-app-builder/uninstall.sh"
echo "═══════════════════════════════════"
