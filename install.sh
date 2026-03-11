#!/bin/bash
# Claude App Builder v0.1 - インストールスクリプト
# Usage: curl -fsSL https://raw.githubusercontent.com/3062-in-zamud/claude-app-builder/main/install.sh | bash
# または: bash install.sh

set -euo pipefail
shopt -s nullglob

INSTALL_DIR="$HOME/.claude"
SKILL_DIR="$INSTALL_DIR/skills"
CMD_DIR="$INSTALL_DIR/commands"
MANIFEST_DIR="$INSTALL_DIR/.claude-app-builder"
SKILL_MANIFEST="$MANIFEST_DIR/skills.txt"
CMD_MANIFEST="$MANIFEST_DIR/commands.txt"
LOCAL_DIR="$HOME/.claude-app-builder"
REPO_URL="https://github.com/3062-in-zamud/claude-app-builder"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR=""

# ===== ヘルパー関数 =====

die() {
  echo "❌ エラー (L${BASH_LINENO[0]}): $1" >&2
  exit 1
}

cleanup_on_error() {
  local exit_code=$?
  if [ $exit_code -ne 0 ] && [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
    echo ""
    echo "❌ インストール中にエラーが発生しました。ロールバックを実行します..."

    # マニフェストディレクトリの復元
    if [ -d "$BACKUP_DIR/manifest" ]; then
      rm -rf "$MANIFEST_DIR"
      cp -a "$BACKUP_DIR/manifest" "$MANIFEST_DIR"
      echo "  ✅ マニフェストを復元しました"
    fi

    # スキルリンクの復元
    if [ -f "$BACKUP_DIR/skill_links.txt" ]; then
      while IFS=$'\t' read -r link_name link_target; do
        [ -n "$link_name" ] || continue
        rm -f "$SKILL_DIR/$link_name"
        if [ -n "$link_target" ]; then
          ln -sfn "$link_target" "$SKILL_DIR/$link_name"
        fi
      done < "$BACKUP_DIR/skill_links.txt"
      echo "  ✅ スキルリンクを復元しました"
    fi

    # コマンドファイルの復元
    if [ -d "$BACKUP_DIR/commands" ]; then
      for cmd_backup in "$BACKUP_DIR/commands"/*.md; do
        [ -f "$cmd_backup" ] || continue
        cp "$cmd_backup" "$CMD_DIR/"
      done
      echo "  ✅ コマンドファイルを復元しました"
    fi

    # CLAUDE.md の復元
    if [ -f "$BACKUP_DIR/CLAUDE.md" ]; then
      cp "$BACKUP_DIR/CLAUDE.md" "$INSTALL_DIR/CLAUDE.md"
      echo "  ✅ CLAUDE.md を復元しました"
    fi

    echo ""
    echo "ロールバック完了。インストール前の状態に戻しました。"
  fi

  # バックアップディレクトリの削除
  if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
    rm -rf "$BACKUP_DIR"
  fi
}

trap 'cleanup_on_error' EXIT

create_backup() {
  BACKUP_DIR=$(mktemp -d)

  # マニフェストディレクトリのバックアップ
  if [ -d "$MANIFEST_DIR" ]; then
    cp -a "$MANIFEST_DIR" "$BACKUP_DIR/manifest"
  fi

  # 既存スキルリンクのバックアップ（リンク名とターゲットのペア）
  if [ -d "$SKILL_DIR" ]; then
    : > "$BACKUP_DIR/skill_links.txt"
    for link_path in "$SKILL_DIR"/*; do
      [ -L "$link_path" ] || continue
      local target
      target="$(readlink "$link_path" 2>/dev/null || true)"
      if [[ "$target" == *"/claude-app-builder/skills/"* ]]; then
        echo "$(basename "$link_path")"$'\t'"$target" >> "$BACKUP_DIR/skill_links.txt"
      fi
    done
  fi

  # コマンドファイルのバックアップ
  if [ -d "$CMD_DIR" ] && [ -f "$CMD_MANIFEST" ]; then
    mkdir -p "$BACKUP_DIR/commands"
    while IFS= read -r cmd_name; do
      [ -n "$cmd_name" ] || continue
      [ -f "$CMD_DIR/$cmd_name.md" ] && cp "$CMD_DIR/$cmd_name.md" "$BACKUP_DIR/commands/"
    done < "$CMD_MANIFEST"
  fi

  # CLAUDE.md のバックアップ
  if [ -f "$INSTALL_DIR/CLAUDE.md" ]; then
    cp "$INSTALL_DIR/CLAUDE.md" "$BACKUP_DIR/CLAUDE.md"
  fi
}

detect_existing_install() {
  if [ -d "$MANIFEST_DIR" ] && [ -f "$SKILL_MANIFEST" ]; then
    local skill_count
    skill_count=$(wc -l < "$SKILL_MANIFEST" 2>/dev/null | tr -d ' ')
    echo "📦 既存インストールを検出しました（スキル数: ${skill_count}）"
    echo "   更新インストールを実行します..."
    echo ""
    return 0
  elif [ -d "$LOCAL_DIR" ]; then
    echo "📦 既存のローカルリポジトリを検出しました: $LOCAL_DIR"
    echo "   更新インストールを実行します..."
    echo ""
    return 0
  fi
  return 1
}

echo "🚀 Claude App Builder v0.1 インストール開始"
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
check_tool gh "https://cli.github.com/"
check_tool supabase "npm install -g supabase"
check_tool vercel "npm install -g vercel（Vercelデプロイ時）"
check_tool wrangler "npm install -g wrangler（Cloudflareデプロイ時）"
check_tool node "https://nodejs.org/"
check_tool git "https://git-scm.com/"
echo ""

# ===== 2. 既存インストール検出 =====
detect_existing_install || true

# ===== 3. バックアップ作成 =====
create_backup

# ===== 4. ソースの取得 =====
if [ -d "$SCRIPT_DIR/skills" ] && [ -d "$SCRIPT_DIR/commands" ]; then
  # ローカルインストール（リポジトリからの直接実行）
  SOURCE_DIR="$SCRIPT_DIR"
  echo "📁 ローカルインストール: $SOURCE_DIR"
else
  # リモートインストール（クローン）
  echo "📥 リポジトリをクローン中..."
  if [ -d "$LOCAL_DIR" ]; then
    echo "   既存リポジトリを更新中..."
    git -C "$LOCAL_DIR" pull --quiet || die "リポジトリの更新に失敗しました: $LOCAL_DIR"
  else
    git clone "$REPO_URL" "$LOCAL_DIR" --quiet || die "リポジトリのクローンに失敗しました: $REPO_URL"
  fi
  SOURCE_DIR="$LOCAL_DIR"
  echo "   完了: $LOCAL_DIR"
fi
echo ""

# ===== 5. ~/.claude/skills/ にインストール =====
echo "📦 スキルをインストール中..."
mkdir -p "$SKILL_DIR" "$MANIFEST_DIR"
: > "$SKILL_MANIFEST"

skill_count=0
for skill_dir in "$SOURCE_DIR/skills"/*; do
  [ -d "$skill_dir" ] || continue
  [ -f "$skill_dir/SKILL.md" ] || continue

  skill_name=$(basename "$skill_dir")
  ln -sfn "$skill_dir" "$SKILL_DIR/$skill_name" || die "スキル '$skill_name' のリンク作成に失敗しました"
  echo "$skill_name" >> "$SKILL_MANIFEST"
  echo "  ✅ $skill_name"
  skill_count=$((skill_count + 1))
done
sort -u -o "$SKILL_MANIFEST" "$SKILL_MANIFEST"
echo "   合計: ${skill_count} スキル"
echo ""

# ===== 6. ~/.claude/commands/ にコマンド追加 =====
echo "⚡ コマンドをインストール中..."
mkdir -p "$CMD_DIR"
: > "$CMD_MANIFEST"

cmd_count=0
for cmd_file in "$SOURCE_DIR/commands"/*.md; do
  [ -f "$cmd_file" ] || continue
  cmd_name=$(basename "$cmd_file")
  [ "$cmd_name" = "CLAUDE.md" ] && continue

  cp "$cmd_file" "$CMD_DIR/$cmd_name" || die "コマンド '$cmd_name' のコピーに失敗しました"
  echo "${cmd_name%.md}" >> "$CMD_MANIFEST"
  echo "  ✅ /${cmd_name%.md} コマンド"
  cmd_count=$((cmd_count + 1))
done
sort -u -o "$CMD_MANIFEST" "$CMD_MANIFEST"
echo "   合計: ${cmd_count} コマンド"
echo ""

# ===== 7. ~/.claude/CLAUDE.md に注記追加（重複チェック付き） =====
CLAUDE_MD="$INSTALL_DIR/CLAUDE.md"
if [ -f "$CLAUDE_MD" ] && ! grep -q "claude-app-builder" "$CLAUDE_MD" 2>/dev/null; then
  cat >> "$CLAUDE_MD" << 'EOF_APPEND'

# BEGIN claude-app-builder Plugin
---
# claude-app-builder Plugin
# 0→MVP→MRR $50Kまで全自動化スキル。/app-builder で起動、/growth-engine で成長フェーズ。
# デプロイ先: Vercel / Cloudflare Pages（deployment_provider で選択）
# 詳細: ~/.claude-app-builder/README.md または ~/.claude/skills/app-builder/SKILL.md
# END claude-app-builder Plugin
EOF_APPEND
  echo "📝 ~/.claude/CLAUDE.md を更新しました" || die "CLAUDE.md の更新に失敗しました"
fi

# インストール成功 — バックアップを不要にする（trap で削除される）
echo ""
echo "═══════════════════════════════════"
echo "✅ Claude App Builder v0.1 インストール完了！"
echo "   スキル数: ${skill_count} 個 / コマンド数: ${cmd_count} 個"
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
