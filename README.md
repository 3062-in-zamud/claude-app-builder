# Claude App Builder

> アイデアを入力するだけで **0 → MVP 世界公開**まで全自動化する Claude Code プラグイン

> **注意**: プログラミングの基礎知識（コードレビュー・デバッグ）を前提とします

## インストール

### 方法1: スクリプトインストール（推奨）

```bash
curl -fsSL https://raw.githubusercontent.com/3062-in-zamud/claude-app-builder/main/install.sh | bash
```

または直接クローン:

```bash
git clone https://github.com/3062-in-zamud/claude-app-builder ~/.claude-app-builder
bash ~/.claude-app-builder/install.sh
```

次回 Claude Code 起動時から `/app-builder` が使えます。

## 初回セットアップ（プラグイン使用前）

1. [Vercel アカウント作成](https://vercel.com/signup) → `vercel login`
2. [Supabase アカウント作成](https://supabase.com) → `supabase login`
3. [GitHub CLI セットアップ](https://cli.github.com/) → `gh auth login`

### 無料プランの制限事項

| サービス | 制限 | 商用利用推奨プラン |
|---------|------|-----------------|
| Vercel Hobby | **commercial use 禁止** | Pro ($20/月) |
| Supabase Free | 500MB DB・2PJ・7日非アクティブで一時停止 | Pro ($25/月) |

### 方法2: Claude Code プラグインシステム

> **注意**: Claude Code のプラグインシステムはマーケットプレイスへの登録が必要です。
> 現時点では公式マーケットプレイスへの申請中のため、`install.sh` をご利用ください。

```bash
claude plugin install claude-app-builder
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

**ユーザー介入ポイント（全6回）:**
1. アイデア入力（起動時）
2. 競合サービス名の入力（Phase 0.5、スキップ可能）
3. **要件定義・ブランディングの承認**（承認ゲート1）← 修正要望を伝えられます
4. Vercel/Supabase 無料プラン制限事項の確認（Phase 1内）
5. `.env.local` への API キー入力（Phase 7前）
6. **本番URL動作確認**（承認ゲート2）

### 個別スキルを直接呼び出す

```
/idea-to-spec "月次の家計を可視化するダッシュボード"
/brand-foundation
/landing-page-builder
/security-hardening
/deploy-setup
```

## ワークフロー

```
Phase 0:   ユーザーリサーチ (user-research) ← 推奨
Phase 0.5: 市場調査 (market-research) ← 推奨
Phase 1:   要件定義 (idea-to-spec) → ブランディング (brand-foundation) ← 順次
           ↓ ユーザー承認ゲート1
Phase 2:   技術スタック選定 (stack-selector) + デザインシステム (visual-designer)
Phase 3:   GitHub リポジトリ準備 + CI設定 (project-scaffold, ci-setup, github-repo-setup)
Phase 4:   ドキュメント + LP + 法務 + SEO
Phase 5:   TDD 実装 + テスト + 計測イベント (analytics-events)
Phase 5.5: AI生成コードセキュリティ強化 ← Opus が担当
Phase 6:   Sentry + Lighthouse CI + 36項目チェックリスト
Phase 7:   Vercel + Supabase デプロイ + ローンチ素材生成
Phase 8:   リリース報告 + フィードバック設計
```

## スキル一覧

| スキル | Phase | モデル | 役割 |
|--------|-------|--------|------|
| `app-builder` | 全体 | **Opus** | オーケストレーター |
| `user-research` | 0 | Sonnet | ペルソナ・インタビューガイド・仮説検証 |
| `market-research` | 0.5 | Sonnet | 競合調査・市場分析 |
| `idea-to-spec` | 1 | Sonnet | アイデア→requirements.md |
| `brand-foundation` | 1 | **Opus** | ブランド戦略 |
| `stack-selector` | 2 | Sonnet | 技術スタック選定 |
| `visual-designer` | 2 | **Opus** | デザインシステム（WCAG AA） |
| `documentation-suite` | 4 | Sonnet | README + ARCHITECTURE |
| `landing-page-builder` | 4 | Sonnet | LP + OGP + メタタグ |
| `legal-docs-generator` | 4 | Sonnet | プライバシー・利用規約 |
| `seo-setup` | 4 | Sonnet | サイトマップ・robots.txt・JSON-LD |
| `project-scaffold` | 3 | Haiku | Next.js / CLI テンプレート展開 |
| `github-repo-setup` | 3 | Sonnet | Branch Protection + Dependabot |
| `ci-setup` | 3 | Sonnet | GitHub Actions CI設定 |
| `implementation` | 5 | Sonnet | TDD実装・テスト |
| `analytics-events` | 5 | Sonnet | 計測イベント設計・Vercel Analytics実装 |
| `security-hardening` | 5.5 | **Opus** | IDOR / RLS / シークレット自動スキャン |
| `monitoring-setup` | 6 | Sonnet | Sentry + Vercel Analytics + Lighthouse CI |
| `release-checklist` | 6 | Sonnet | 全項目チェック（CRITICAL明記） |
| `deploy-setup` | 7 | Haiku | Vercel + Supabase デプロイ |
| `feedback-loop` | 8 | Sonnet | フィードバック設計 |

## スコープ外（v1）

以下は v1 の対象外です：

- Stripe 等の決済統合（v2 予定）
- メール送信（Resend / SendGrid）（v2 予定）
- A/Bテスト（PostHog / Vercel Edge Config）（v2 予定）
  ※ Vercel Edge Config は Vercel Pro 以上が必要
- カスタムドメイン設定は deploy-setup に案内として含む
- モバイルアプリ（React Native / Expo）は `stack-selector` で選択可能だが、
  `/app-builder` フルフローはWebアプリのみ対応

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
claude plugin update claude-app-builder

# スクリプトインストールの場合
bash ~/.claude-app-builder/update.sh
```

## アンインストール

```bash
# プラグインシステムでインストールした場合
claude plugin uninstall claude-app-builder

# スクリプトインストールの場合
bash ~/.claude-app-builder/uninstall.sh
```

## ライセンス

MIT
