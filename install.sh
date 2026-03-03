#!/bin/bash
# Claude App Builder v3.0 - インストールスクリプト
# Usage: curl -fsSL https://raw.githubusercontent.com/3062-in-zamud/claude-app-builder/main/install.sh | bash
# または: bash install.sh

set -e

INSTALL_DIR="$HOME/.claude"
SKILL_DIR="$INSTALL_DIR/skills"
CMD_DIR="$INSTALL_DIR/commands"
LOCAL_DIR="$HOME/.claude-app-builder"
REPO_URL="https://github.com/3062-in-zamud/claude-app-builder"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 Claude App Builder v3.0 インストール開始"
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
# 全コマンドファイルをコピー
for cmd_file in "$SOURCE_DIR/commands/"*.md; do
  cmd_name=$(basename "$cmd_file")
  cp "$cmd_file" "$CMD_DIR/$cmd_name"
  echo "  ✅ /${cmd_name%.md} コマンド"
done
echo ""

# ===== 5. ~/.claude/CLAUDE.md に注記追加（重複チェック付き） =====
CLAUDE_MD="$INSTALL_DIR/CLAUDE.md"
if [ -f "$CLAUDE_MD" ] && ! grep -q "claude-app-builder" "$CLAUDE_MD" 2>/dev/null; then
  cat >> "$CLAUDE_MD" << 'EOF'

---
# claude-app-builder Plugin
# 0→MVP→MRR $50Kまで全自動化スキル。/app-builder で起動、/growth-engine で成長フェーズ。
# 詳細: ~/.claude-app-builder/README.md または ~/.claude/skills/app-builder/SKILL.md
EOF
  echo "📝 ~/.claude/CLAUDE.md を更新しました"
fi

echo ""
echo "═══════════════════════════════════"
echo "✅ Claude App Builder v3.0 インストール完了！"
echo ""
echo "使い方:"
echo "  /app-builder \"あなたのアイデア\"  - 0→MVPリリース（Stage A〜C）"
echo "  /growth-engine                   - MVP→MRR成長（Stage D〜F）"
echo ""
echo "個別スキル（Stage A〜C: 0→MVP）:"
echo "  /idea-to-spec \"アイデア\"    - 要件定義"
echo "  /brand-foundation           - ブランディング"
echo "  /stack-selector             - 技術スタック選定"
echo "  /visual-designer            - デザインシステム"
echo "  /market-research            - 競合調査"
echo "  /security-hardening         - セキュリティチェック"
echo "  /deploy-setup               - デプロイ"
echo ""
echo "個別スキル（Stage D〜F: MVP→MRR成長）:"
echo "  /pricing-strategy           - 価格戦略"
echo "  /payment-integration        - Stripe決済統合"
echo "  /onboarding-optimizer       - オンボーディング最適化"
echo "  /email-strategy             - メールマーケティング"
echo "  /ab-testing                 - A/Bテスト"
echo "  /conversion-funnel          - コンバージョンファネル"
echo "  /gdpr-compliance            - GDPR準拠"
echo "  /data-deletion              - データ削除パイプライン"
echo "  /retention-strategy         - リテンション戦略"
echo "  /incident-response          - インシデント対応"
echo "  /scaling-strategy           - スケーリング戦略"
echo "  /cost-optimization          - コスト最適化"
echo ""
echo "  ... 全コマンドは ~/.claude/commands/ を参照"
echo ""
echo "更新: bash ~/.claude-app-builder/update.sh"
echo "削除: bash ~/.claude-app-builder/uninstall.sh"
echo "═══════════════════════════════════"
