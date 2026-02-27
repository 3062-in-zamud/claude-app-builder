# Claude App Builder

> アイデアを入力するだけで **0 → MVP 世界公開**まで全自動化する Claude Code プラグイン

## インストール

### 方法1: Claude Code プラグインシステム（推奨）

```bash
claude plugins install github:3062-in-zamud/claude-app-builder
```

これだけ。次回 Claude Code 起動時から `/app-builder` が使えます。

### 方法2: スクリプトインストール（代替）

```bash
curl -fsSL https://raw.githubusercontent.com/3062-in-zamud/claude-app-builder/main/install.sh | bash
```

または直接クローン:

```bash
git clone https://github.com/3062-in-zamud/claude-app-builder ~/.claude-app-builder
bash ~/.claude-app-builder/install.sh
```

### 前提ツール

| ツール | 用途 | インストール |
|--------|------|------------|
| [gh](https://cli.github.com/) | GitHub操作 | `brew install gh` |
| [vercel](https://vercel.com/cli) | デプロイ | `npm install -g vercel` |
| [supabase](https://supabase.com/docs/reference/cli) | DB管理 | `npm install -g supabase` |
| Node.js 18+ | 実行環境 | [nodejs.org](https://nodejs.org/) |

## 使い方

### フル自動（0 → デプロイ）

```
/app-builder "ユーザーが自分の読んだ本を記録してレビューを書けるSNS"
```

```
/app-builder "フリーランサー向け請求書管理ツール"
```

**ユーザーの介入は3点のみ**:
1. アイデア入力
2. 要件定義の確認・承認（Phase 1後）
3. デプロイ後の本番確認

### 個別スキルを直接呼び出す

```
/idea-to-spec "月次の家計を可視化するダッシュボード"
/brand-foundation
/landing-page-builder
/security-hardening
/deploy-setup
```

## ワークフロー（8フェーズ）

```
Phase 1:   要件定義 (idea-to-spec) + ブランディング (brand-foundation)
           ↓ ユーザー承認（1回のみ）
Phase 2:   技術スタック選定 (stack-selector) + デザインシステム (visual-designer)
Phase 3:   ドキュメント + LP + 法務
Phase 4:   GitHub リポジトリ準備
Phase 5:   TDD 実装 + コードレビュー
Phase 5.5: AI生成コードセキュリティ強化 ← Opus が担当
Phase 6:   Sentry + Lighthouse CI + 34項目チェックリスト
Phase 7:   Vercel + Supabase デプロイ + ローンチ素材生成
Phase 8:   リリース報告（URL + セキュリティ確認済みマーク）
```

## スキル一覧（14個）

| スキル | Phase | モデル | 役割 |
|--------|-------|--------|------|
| `app-builder` | 全体 | **Opus** | オーケストレーター |
| `idea-to-spec` | 1 | Sonnet | アイデア→requirements.md |
| `brand-foundation` | 1 | **Opus** | ブランド戦略 |
| `stack-selector` | 2 | Sonnet | 技術スタック選定 |
| `visual-designer` | 2 | **Opus** | デザインシステム（WCAG AA） |
| `documentation-suite` | 3 | Sonnet | README + ARCHITECTURE |
| `landing-page-builder` | 3 | Sonnet | LP + OGP + メタタグ |
| `legal-docs-generator` | 3 | Haiku | プライバシー・利用規約 |
| `project-scaffold` | 4 | Haiku | Next.js / CLI テンプレート展開 |
| `github-repo-setup` | 4 | Sonnet | Branch Protection + Dependabot |
| `security-hardening` | 5.5 | **Opus** | IDOR / RLS / シークレット自動スキャン |
| `monitoring-setup` | 6 | Sonnet | Sentry + Vercel Analytics + Lighthouse CI |
| `release-checklist` | 6 | Sonnet | 全項目チェック（CRITICAL明記） |
| `deploy-setup` | 7 | Haiku | Vercel + Supabase デプロイ |

## セキュリティ

`security-hardening` スキルは AI 生成コード特有の脆弱性を検査します（Opus 担当）:

- **IDOR**: 全APIで所有者確認
- **Supabase RLS**: 全テーブル有効化確認
- **Service Role Key**: フロントエンド混入チェック
- **シークレット漏洩**: TruffleHog で全コミットスキャン
- **CSRF / JWT / Rate Limiting**: セキュリティベストプラクティス確認

CRITICAL 問題がある場合はデプロイに進めません。

詳細: [SECURITY.md](SECURITY.md)

## アップデート

```bash
# プラグインシステムでインストールした場合
claude plugins update claude-app-builder

# スクリプトインストールの場合
bash ~/.claude-app-builder/update.sh
```

## アンインストール

```bash
# プラグインシステムでインストールした場合
claude plugins uninstall claude-app-builder

# スクリプトインストールの場合
bash ~/.claude-app-builder/uninstall.sh
```

## ライセンス

MIT
